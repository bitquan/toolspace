/// VATS Local Test Suite
/// Tests for Video → Audio → Transcript processing and Credits System v2
@TestOn('vm || browser')
@Tags(['local'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:toolspace/billing/billing_types.dart';

void main() {
  group('VATS Local Tests', () {
    group('Credits System v2 - Core Logic', () {
      test('should calculate credits needed for audio duration correctly', () {
        // Test various durations - 1 credit = 1 minute, rounded up
        expect(CreditsBilling.creditsForDuration(const Duration(seconds: 30)), equals(1));
        expect(CreditsBilling.creditsForDuration(const Duration(seconds: 60)), equals(1));
        expect(CreditsBilling.creditsForDuration(const Duration(seconds: 90)), equals(2));
        expect(CreditsBilling.creditsForDuration(const Duration(minutes: 5)), equals(5));
        expect(CreditsBilling.creditsForDuration(const Duration(minutes: 10, seconds: 30)),
            equals(11));
        expect(CreditsBilling.creditsForDuration(const Duration(hours: 1)), equals(60));
      });

      test('should create correct credits billing for different plans', () {
        final freeCredits = CreditsBilling.forPlan(PlanId.free);
        expect(freeCredits.plan, equals(PlanId.free));
        expect(freeCredits.planMinutes, equals(10)); // 10 minutes for free
        expect(freeCredits.creditsRemaining, equals(10));
        expect(freeCredits.creditsUsed, equals(0));

        final proCredits = CreditsBilling.forPlan(PlanId.pro);
        expect(proCredits.plan, equals(PlanId.pro));
        expect(proCredits.planMinutes, equals(600)); // 10 hours for pro
        expect(proCredits.creditsRemaining, equals(600));

        final proPlusCredits = CreditsBilling.forPlan(PlanId.proPlus);
        expect(proPlusCredits.plan, equals(PlanId.proPlus));
        expect(proPlusCredits.planMinutes, equals(1800)); // 30 hours for pro plus
      });

      test('should deduct credits correctly', () {
        final credits = CreditsBilling.forPlan(PlanId.pro);

        // Deduct 50 credits
        final afterDeduction = credits.deductCredits(50);

        expect(afterDeduction.creditsRemaining, equals(550)); // 600 - 50
        expect(afterDeduction.creditsUsed, equals(50));
        expect(afterDeduction.plan, equals(PlanId.pro));
        expect(afterDeduction.planMinutes, equals(600)); // Unchanged
      });

      test('should not allow negative credits', () {
        final credits = CreditsBilling.forPlan(PlanId.free); // 10 minutes

        // Try to deduct more than available
        final afterDeduction = credits.deductCredits(50);

        expect(afterDeduction.creditsRemaining, equals(0)); // Clamped to 0
        expect(afterDeduction.creditsUsed, equals(50)); // Still recorded
      });

      test('should check if user has enough credits', () {
        final credits = CreditsBilling.forPlan(PlanId.pro); // 600 minutes

        expect(credits.hasCredits(100), isTrue);
        expect(credits.hasCredits(600), isTrue);
        expect(credits.hasCredits(601), isFalse);

        // After using some credits
        final usedCredits = credits.deductCredits(500);
        expect(usedCredits.hasCredits(100), isTrue);
        expect(usedCredits.hasCredits(101), isFalse);
      });

      test('should refill credits correctly', () {
        var credits = CreditsBilling.forPlan(PlanId.pro);

        // Use some credits
        credits = credits.deductCredits(300);
        expect(credits.creditsRemaining, equals(300));
        expect(credits.creditsUsed, equals(300));

        // Refill
        final refilled = credits.refillCredits();
        expect(refilled.creditsRemaining, equals(600)); // Reset to plan amount
        expect(refilled.creditsUsed, equals(0)); // Reset usage
        expect(refilled.plan, equals(PlanId.pro)); // Unchanged
      });

      test('should detect when refill is needed', () {
        final now = DateTime.now();

        // Credits with future refill date
        final futureRefill = CreditsBilling(
          plan: PlanId.pro,
          planMinutes: 600,
          creditsRemaining: 100,
          creditsUsed: 500,
          lastRefill: now.subtract(const Duration(days: 20)),
          nextRefillDate: now.add(const Duration(days: 10)),
        );
        expect(futureRefill.needsRefill, isFalse);

        // Credits with past refill date
        final pastRefill = CreditsBilling(
          plan: PlanId.pro,
          planMinutes: 600,
          creditsRemaining: 100,
          creditsUsed: 500,
          lastRefill: now.subtract(const Duration(days: 40)),
          nextRefillDate: now.subtract(const Duration(days: 5)),
        );
        expect(pastRefill.needsRefill, isTrue);
      });
    });

    group('VATS Job Status Management', () {
      test('should create VATS job with correct initial state', () {
        final job = VATSJob(
          id: 'test-job-1',
          userId: 'user-123',
          fileName: 'test_video.mp4',
          videoUrl: 'https://example.com/video.mp4',
          status: VATSJobStatus.uploading,
          createdAt: DateTime.now(),
        );

        expect(job.id, equals('test-job-1'));
        expect(job.fileName, equals('test_video.mp4'));
        expect(job.status, equals(VATSJobStatus.uploading));
        expect(job.progressPercent, equals(0));
        expect(job.errorMessage, isNull);
        expect(job.transcriptText, isNull);
      });

      test('should update job status correctly', () {
        var job = VATSJob(
          id: 'test-job-1',
          userId: 'user-123',
          fileName: 'test.mp4',
          videoUrl: 'https://example.com/video.mp4',
          status: VATSJobStatus.uploading,
          createdAt: DateTime.now(),
        );

        // Update to converting
        job = job.copyWith(
          status: VATSJobStatus.converting,
          progressPercent: 25,
          audioUrl: 'https://example.com/audio.mp3',
        );

        expect(job.status, equals(VATSJobStatus.converting));
        expect(job.progressPercent, equals(25));
        expect(job.audioUrl, equals('https://example.com/audio.mp3'));

        // Update to completed
        job = job.copyWith(
          status: VATSJobStatus.completed,
          progressPercent: 100,
          completedAt: DateTime.now(),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          creditsUsed: 6,
          transcriptText: 'This is the transcript text.',
          srtContent: '1\n00:00:00,000 --> 00:00:05,000\nThis is the transcript text.',
        );

        expect(job.status, equals(VATSJobStatus.completed));
        expect(job.progressPercent, equals(100));
        expect(job.completedAt, isNotNull);
        expect(job.audioDuration!.inMinutes, equals(5));
        expect(job.creditsUsed, equals(6));
        expect(job.transcriptText, contains('transcript'));
        expect(job.srtContent, contains('-->'));
      });

      test('should handle job failure correctly', () {
        var job = VATSJob(
          id: 'test-job-fail',
          userId: 'user-123',
          fileName: 'fail.mp4',
          videoUrl: 'https://example.com/video.mp4',
          status: VATSJobStatus.transcribing,
          progressPercent: 75,
          createdAt: DateTime.now(),
        );

        // Update to failed
        job = job.copyWith(
          status: VATSJobStatus.failed,
          errorMessage: 'Transcription service unavailable',
        );

        expect(job.status, equals(VATSJobStatus.failed));
        expect(job.errorMessage, equals('Transcription service unavailable'));
        expect(job.progressPercent, equals(75)); // Preserved from before failure
      });

      test('should serialize and deserialize VATS job correctly', () {
        final originalJob = VATSJob(
          id: 'serialize-test',
          userId: 'user-456',
          fileName: 'serialization_test.mov',
          videoUrl: 'https://example.com/video.mov',
          audioUrl: 'https://example.com/audio.m4a',
          status: VATSJobStatus.completed,
          progressPercent: 100,
          createdAt: DateTime.parse('2025-10-09T10:30:00Z'),
          completedAt: DateTime.parse('2025-10-09T10:32:30Z'),
          audioDuration: const Duration(minutes: 2, seconds: 15),
          creditsUsed: 3,
          transcriptText: 'Sample transcript content',
          srtContent: '1\n00:00:00,000 --> 00:00:02,000\nSample transcript content',
        );

        // Serialize to JSON
        final json = originalJob.toJson();

        // Deserialize from JSON
        final deserializedJob = VATSJob.fromJson(json);

        expect(deserializedJob.id, equals(originalJob.id));
        expect(deserializedJob.fileName, equals(originalJob.fileName));
        expect(deserializedJob.status, equals(originalJob.status));
        expect(
            deserializedJob.audioDuration!.inSeconds, equals(originalJob.audioDuration!.inSeconds));
        expect(deserializedJob.creditsUsed, equals(originalJob.creditsUsed));
        expect(deserializedJob.transcriptText, equals(originalJob.transcriptText));
      });
    });

    group('VATS Job Status Display Names', () {
      test('should provide correct display names for all statuses', () {
        expect(VATSJobStatus.uploading.displayName, equals('Uploading video...'));
        expect(VATSJobStatus.converting.displayName, equals('Converting to audio...'));
        expect(VATSJobStatus.transcribing.displayName, equals('Transcribing audio...'));
        expect(VATSJobStatus.completed.displayName, equals('Completed'));
        expect(VATSJobStatus.failed.displayName, equals('Failed'));
      });
    });

    group('Plan ID Management', () {
      test('should convert plan IDs correctly', () {
        expect(PlanId.free.id, equals('free'));
        expect(PlanId.pro.id, equals('pro'));
        expect(PlanId.proPlus.id, equals('pro_plus'));

        expect(PlanId.fromString('free'), equals(PlanId.free));
        expect(PlanId.fromString('pro'), equals(PlanId.pro));
        expect(PlanId.fromString('pro_plus'), equals(PlanId.proPlus));
        expect(PlanId.fromString('unknown'), equals(PlanId.free)); // Default fallback
      });
    });

    group('Credits System JSON Serialization', () {
      test('should serialize and deserialize credits billing correctly', () {
        final originalCredits = CreditsBilling(
          plan: PlanId.pro,
          planMinutes: 600,
          creditsRemaining: 450,
          creditsUsed: 150,
          lastRefill: DateTime.parse('2025-10-01T00:00:00Z'),
          nextRefillDate: DateTime.parse('2025-11-01T00:00:00Z'),
          autoRefill: true,
        );

        // Serialize to JSON
        final json = originalCredits.toJson();

        // Deserialize from JSON
        final deserializedCredits = CreditsBilling.fromJson(json);

        expect(deserializedCredits.plan, equals(originalCredits.plan));
        expect(deserializedCredits.planMinutes, equals(originalCredits.planMinutes));
        expect(deserializedCredits.creditsRemaining, equals(originalCredits.creditsRemaining));
        expect(deserializedCredits.creditsUsed, equals(originalCredits.creditsUsed));
        expect(deserializedCredits.autoRefill, equals(originalCredits.autoRefill));
        expect(deserializedCredits.lastRefill.toIso8601String(),
            equals(originalCredits.lastRefill.toIso8601String()));
      });
    });
  });
}
