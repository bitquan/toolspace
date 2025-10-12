/// VATS Service - Video → Audio → Transcript processing.
///
/// Handles:
/// - Video upload to Firebase Storage
/// - Audio conversion using FFmpeg (simulated locally)
/// - Transcription via Whisper API (mocked for local)
/// - Progress tracking via Firestore
/// - SRT and Markdown output generation
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../billing/billing_types.dart';
import '../../billing/credits_service.dart';
import '../../core/services/debug_logger.dart';

class VATSService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final CreditsService _creditsService;

  // Streams
  final _jobController = StreamController<VATSJob>.broadcast();

  VATSService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    required CreditsService creditsService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _creditsService = creditsService;

  /// Stream of VATS job updates
  Stream<VATSJob> get jobUpdatesStream => _jobController.stream;

  /// Get all user's VATS jobs
  Future<List<VATSJob>> getUserJobs() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users/${user.uid}/vats_jobs')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VATSJob.fromJson(doc.data()))
          .toList();
    } catch (e) {
      DebugLogger.error('Failed to get user jobs: $e');
      return [];
    }
  }

  /// Get specific job by ID
  Future<VATSJob?> getJob(String jobId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .doc('users/${user.uid}/vats_jobs/$jobId')
          .get();

      if (doc.exists) {
        return VATSJob.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      DebugLogger.error('Failed to get job $jobId: $e');
      return null;
    }
  }

  /// Start video processing job
  Future<String?> processVideo(
    Uint8List videoData,
    String fileName,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      DebugLogger.error('No authenticated user for video processing');
      return null;
    }

    final jobId = DateTime.now().millisecondsSinceEpoch.toString();
    
    try {
      // Create initial job record
      final job = VATSJob(
        id: jobId,
        userId: user.uid,
        fileName: fileName,
        videoUrl: '', // Will be updated after upload
        status: VATSJobStatus.uploading,
        createdAt: DateTime.now(),
      );

      await _updateJob(job);
      DebugLogger.info('🎬 Started VATS job: $jobId for $fileName');

      // Start processing pipeline
      _processVideoPipeline(job, videoData);
      
      return jobId;
    } catch (e) {
      DebugLogger.error('Failed to start video processing: $e');
      return null;
    }
  }

  /// Process video through complete pipeline
  Future<void> _processVideoPipeline(VATSJob job, Uint8List videoData) async {
    try {
      // Step 1: Upload video
      final videoUrl = await _uploadVideo(job.id, videoData);
      if (videoUrl == null) {
        await _updateJob(job.copyWith(
          status: VATSJobStatus.failed,
          errorMessage: 'Failed to upload video',
        ));
        return;
      }

      final updatedJob = job.copyWith(
        videoUrl: videoUrl,
        status: VATSJobStatus.converting,
        progressPercent: 25,
      );
      await _updateJob(updatedJob);

      // Step 2: Convert to audio
      final audioResult = await _convertToAudio(job.id, videoData);
      if (audioResult == null) {
        await _updateJob(updatedJob.copyWith(
          status: VATSJobStatus.failed,
          errorMessage: 'Failed to convert video to audio',
        ));
        return;
      }

      final (audioUrl, audioDuration) = audioResult;
      final creditsNeeded = CreditsBilling.creditsForDuration(audioDuration);

      // Check credits before transcription
      if (!await _creditsService.hasCreditsFor(creditsNeeded)) {
        await _updateJob(updatedJob.copyWith(
          status: VATSJobStatus.failed,
          errorMessage: 'Insufficient credits for transcription (need $creditsNeeded minutes)',
        ));
        return;
      }

      final convertedJob = updatedJob.copyWith(
        audioUrl: audioUrl,
        audioDuration: audioDuration,
        status: VATSJobStatus.transcribing,
        progressPercent: 50,
      );
      await _updateJob(convertedJob);

      // Step 3: Transcribe audio
      final transcriptResult = await _transcribeAudio(audioUrl, audioDuration);
      if (transcriptResult == null) {
        await _updateJob(convertedJob.copyWith(
          status: VATSJobStatus.failed,
          errorMessage: 'Failed to transcribe audio',
        ));
        return;
      }

      final (transcriptText, srtContent) = transcriptResult;

      // Deduct credits
      final creditsDeducted = await _creditsService.deductCreditsFor(
        audioDuration,
        job.id,
      );

      if (!creditsDeducted) {
        await _updateJob(convertedJob.copyWith(
          status: VATSJobStatus.failed,
          errorMessage: 'Failed to deduct credits',
        ));
        return;
      }

      // Step 4: Complete job
      final completedJob = convertedJob.copyWith(
        status: VATSJobStatus.completed,
        progressPercent: 100,
        completedAt: DateTime.now(),
        creditsUsed: creditsNeeded,
        transcriptText: transcriptText,
        srtContent: srtContent,
      );
      await _updateJob(completedJob);

      DebugLogger.info('✅ VATS job completed: ${job.id}');
    } catch (e) {
      DebugLogger.error('Video pipeline failed: $e');
      await _updateJob(job.copyWith(
        status: VATSJobStatus.failed,
        errorMessage: 'Unexpected error: $e',
      ));
    }
  }

  /// Upload video to Firebase Storage
  Future<String?> _uploadVideo(String jobId, Uint8List videoData) async {
    try {
      final user = _auth.currentUser!;
      final ref = _storage.ref('users/${user.uid}/videos/$jobId.mp4');
      
      await ref.putData(videoData);
      final downloadUrl = await ref.getDownloadURL();
      
      DebugLogger.info('📤 Video uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      DebugLogger.error('Video upload failed: $e');
      return null;
    }
  }

  /// Convert video to audio (simulated FFmpeg)
  Future<(String, Duration)?> _convertToAudio(String jobId, Uint8List videoData) async {
    try {
      // In production, this would use FFmpeg
      // For local development, we simulate the conversion
      
      if (kDebugMode) {
        // Simulate conversion delay
        await Future.delayed(const Duration(seconds: 2));
        
        // Create mock audio data (just copy video data for simulation)
        final user = _auth.currentUser!;
        final audioRef = _storage.ref('users/${user.uid}/audio/$jobId.mp3');
        
        // Upload the same data as "audio" for simulation
        await audioRef.putData(videoData);
        final audioUrl = await audioRef.getDownloadURL();
        
        // Simulate audio duration (random between 30s - 5min for testing)
        final mockDurationSeconds = 30 + (DateTime.now().millisecond % 270);
        final audioDuration = Duration(seconds: mockDurationSeconds);
        
        DebugLogger.info('🎵 Audio conversion completed (simulated): ${audioDuration.inMinutes}m ${audioDuration.inSeconds % 60}s');
        return (audioUrl, audioDuration);
      } else {
        // In production, implement actual FFmpeg conversion
        throw UnimplementedError('FFmpeg conversion not implemented for production');
      }
    } catch (e) {
      DebugLogger.error('Audio conversion failed: $e');
      return null;
    }
  }

  /// Transcribe audio using Whisper API (mocked for local)
  Future<(String, String)?> _transcribeAudio(String audioUrl, Duration duration) async {
    try {
      if (kDebugMode) {
        // Simulate transcription delay based on audio length
        final transcriptionTime = (duration.inSeconds * 0.1).clamp(1.0, 10.0);
        await Future.delayed(Duration(seconds: transcriptionTime.round()));
        
        // Mock transcript content
        final mockTranscript = _generateMockTranscript(duration);
        final srtContent = _generateSRTFromTranscript(mockTranscript, duration);
        
        DebugLogger.info('📝 Transcription completed (mocked): ${mockTranscript.length} characters');
        return (mockTranscript, srtContent);
      } else {
        // In production, call actual Whisper API
        return await _callWhisperAPI(audioUrl);
      }
    } catch (e) {
      DebugLogger.error('Transcription failed: $e');
      return null;
    }
  }

  /// Generate mock transcript for local testing
  String _generateMockTranscript(Duration duration) {
    final sentences = [
      'Welcome to this video transcription.',
      'This is a demonstration of the VATS system.',
      'Video to Audio to Transcript processing is now complete.',
      'The system uses FFmpeg for audio conversion.',
      'Whisper API provides accurate speech-to-text transcription.',
      'Credits are deducted based on audio duration.',
      'One credit equals one minute of processed audio.',
      'The system supports SRT and Markdown export formats.',
      'Thank you for using the Toolspace VATS system.',
    ];

    final minutesOfContent = duration.inMinutes.clamp(1, 10);
    final selectedSentences = <String>[];
    
    for (int i = 0; i < minutesOfContent * 2; i++) {
      selectedSentences.add(sentences[i % sentences.length]);
    }

    return selectedSentences.join(' ');
  }

  /// Generate SRT content from transcript
  String _generateSRTFromTranscript(String transcript, Duration duration) {
    final sentences = transcript.split('. ').where((s) => s.isNotEmpty).toList();
    final srtEntries = <String>[];
    
    final secondsPerSentence = duration.inSeconds / sentences.length;
    
    for (int i = 0; i < sentences.length; i++) {
      final startTime = Duration(seconds: (i * secondsPerSentence).round());
      final endTime = Duration(seconds: ((i + 1) * secondsPerSentence).round());
      
      srtEntries.add([
        '${i + 1}',
        '${_formatSRTTime(startTime)} --> ${_formatSRTTime(endTime)}',
        sentences[i].trim() + (i < sentences.length - 1 ? '.' : ''),
        '',
      ].join('\n'));
    }
    
    return srtEntries.join('\n');
  }

  /// Format duration for SRT timestamp
  String _formatSRTTime(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    
    return '$hours:$minutes:$seconds,$milliseconds';
  }

  /// Call actual Whisper API (for production)
  Future<(String, String)?> _callWhisperAPI(String audioUrl) async {
    // This would be implemented for production
    // For now, return null to force local simulation
    DebugLogger.warning('Whisper API not implemented - use debug mode for simulation');
    return null;
  }

  /// Update job in Firestore
  Future<void> _updateJob(VATSJob job) async {
    try {
      await _firestore
          .doc('users/${job.userId}/vats_jobs/${job.id}')
          .set(job.toJson());
      
      _jobController.add(job);
    } catch (e) {
      DebugLogger.error('Failed to update job ${job.id}: $e');
    }
  }

  /// Export transcript as Markdown
  String exportAsMarkdown(VATSJob job) {
    final buffer = StringBuffer();
    buffer.writeln('# Video Transcript: ${job.fileName}');
    buffer.writeln();
    buffer.writeln('**Processed:** ${job.createdAt.toIso8601String()}');
    if (job.audioDuration != null) {
      buffer.writeln('**Duration:** ${job.audioDuration!.inMinutes}m ${job.audioDuration!.inSeconds % 60}s');
    }
    if (job.creditsUsed != null) {
      buffer.writeln('**Credits Used:** ${job.creditsUsed}');
    }
    buffer.writeln();
    buffer.writeln('## Transcript');
    buffer.writeln();
    buffer.writeln(job.transcriptText ?? 'No transcript available');
    
    return buffer.toString();
  }

  /// Listen to job updates for specific user
  Stream<List<VATSJob>> watchUserJobs() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users/${user.uid}/vats_jobs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VATSJob.fromJson(doc.data()))
            .toList());
  }

  /// Listen to specific job updates
  Stream<VATSJob?> watchJob(String jobId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .doc('users/${user.uid}/vats_jobs/$jobId')
        .snapshots()
        .map((snapshot) => snapshot.exists 
            ? VATSJob.fromJson(snapshot.data()!)
            : null);
  }

  void dispose() {
    _jobController.close();
  }
}
