/// Billing types matching backend schema.
///
/// Keep in sync with functions/src/types/billing.ts
library;

/// Subscription plan IDs
enum PlanId {
  free,
  pro,
  proPlus;

  String get id {
    switch (this) {
      case PlanId.free:
        return 'free';
      case PlanId.pro:
        return 'pro';
      case PlanId.proPlus:
        return 'pro_plus';
    }
  }

  static PlanId fromString(String id) {
    switch (id) {
      case 'free':
        return PlanId.free;
      case 'pro':
        return PlanId.pro;
      case 'pro_plus':
        return PlanId.proPlus;
      default:
        return PlanId.free;
    }
  }
}

/// Subscription status
enum SubscriptionStatus {
  free,
  active,
  trialing,
  pastDue,
  canceled,
  unpaid,
  incomplete,
  incompleteExpired;

  String get id {
    switch (this) {
      case SubscriptionStatus.free:
        return 'free';
      case SubscriptionStatus.active:
        return 'active';
      case SubscriptionStatus.trialing:
        return 'trialing';
      case SubscriptionStatus.pastDue:
        return 'past_due';
      case SubscriptionStatus.canceled:
        return 'canceled';
      case SubscriptionStatus.unpaid:
        return 'unpaid';
      case SubscriptionStatus.incomplete:
        return 'incomplete';
      case SubscriptionStatus.incompleteExpired:
        return 'incomplete_expired';
    }
  }

  static SubscriptionStatus fromString(String status) {
    switch (status) {
      case 'free':
        return SubscriptionStatus.free;
      case 'active':
        return SubscriptionStatus.active;
      case 'trialing':
        return SubscriptionStatus.trialing;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'unpaid':
        return SubscriptionStatus.unpaid;
      case 'incomplete':
        return SubscriptionStatus.incomplete;
      case 'incomplete_expired':
        return SubscriptionStatus.incompleteExpired;
      default:
        return SubscriptionStatus.free;
    }
  }

  bool get isActive => this == SubscriptionStatus.active || this == SubscriptionStatus.trialing;
}

/// Support level
enum SupportLevel {
  community,
  email,
  priority;

  String get id {
    switch (this) {
      case SupportLevel.community:
        return 'community';
      case SupportLevel.email:
        return 'email';
      case SupportLevel.priority:
        return 'priority';
    }
  }

  static SupportLevel fromString(String level) {
    switch (level) {
      case 'community':
        return SupportLevel.community;
      case 'email':
        return SupportLevel.email;
      case 'priority':
        return SupportLevel.priority;
      default:
        return SupportLevel.community;
    }
  }
}

/// Plan entitlements
class Entitlements {
  final int heavyOpsPerDay;
  final int lightOpsPerDay;
  final int maxFileSize; // bytes
  final int maxBatchSize;
  final bool priorityQueue;
  final SupportLevel supportLevel;
  final bool canExportBatch;
  final bool advancedFeatures;

  const Entitlements({
    required this.heavyOpsPerDay,
    required this.lightOpsPerDay,
    required this.maxFileSize,
    required this.maxBatchSize,
    required this.priorityQueue,
    required this.supportLevel,
    required this.canExportBatch,
    required this.advancedFeatures,
  });

  factory Entitlements.fromJson(Map<String, dynamic> json) {
    return Entitlements(
      heavyOpsPerDay: json['heavyOpsPerDay'] as int,
      lightOpsPerDay: json['lightOpsPerDay'] as int,
      maxFileSize: json['maxFileSize'] as int,
      maxBatchSize: json['maxBatchSize'] as int,
      priorityQueue: json['priorityQueue'] as bool,
      supportLevel: SupportLevel.fromString(json['supportLevel'] as String),
      canExportBatch: json['canExportBatch'] as bool,
      advancedFeatures: json['advancedFeatures'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heavyOpsPerDay': heavyOpsPerDay,
      'lightOpsPerDay': lightOpsPerDay,
      'maxFileSize': maxFileSize,
      'maxBatchSize': maxBatchSize,
      'priorityQueue': priorityQueue,
      'supportLevel': supportLevel.id,
      'canExportBatch': canExportBatch,
      'advancedFeatures': advancedFeatures,
    };
  }

  /// Get human-readable file size limit
  String get maxFileSizeFormatted {
    if (maxFileSize < 1024) return '$maxFileSize B';
    if (maxFileSize < 1024 * 1024) {
      return '${(maxFileSize / 1024).toStringAsFixed(0)} KB';
    }
    return '${(maxFileSize / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}

/// Billing profile (Firestore: users/{uid}/billing/profile)
class BillingProfile {
  final String? stripeCustomerId;
  final PlanId planId;
  final SubscriptionStatus status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? trialEnd;
  final bool cancelAtPeriodEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BillingProfile({
    this.stripeCustomerId,
    required this.planId,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialEnd,
    required this.cancelAtPeriodEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillingProfile.free() {
    final now = DateTime.now();
    return BillingProfile(
      planId: PlanId.free,
      status: SubscriptionStatus.free,
      cancelAtPeriodEnd: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory BillingProfile.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse timestamp
    DateTime? safeParseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is double && !value.isNaN && value.isFinite) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      return null; // Invalid timestamp
    }

    return BillingProfile(
      stripeCustomerId: json['stripeCustomerId'] as String?,
      planId: PlanId.fromString(json['planId'] as String? ?? 'free'),
      status: SubscriptionStatus.fromString(json['status'] as String? ?? 'free'),
      currentPeriodStart: safeParseTimestamp(json['currentPeriodStart']),
      currentPeriodEnd: safeParseTimestamp(json['currentPeriodEnd']),
      trialEnd: safeParseTimestamp(json['trialEnd']),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      createdAt: safeParseTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: safeParseTimestamp(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stripeCustomerId': stripeCustomerId,
      'planId': planId.id,
      'status': status.id,
      'currentPeriodStart': currentPeriodStart?.millisecondsSinceEpoch,
      'currentPeriodEnd': currentPeriodEnd?.millisecondsSinceEpoch,
      'trialEnd': trialEnd?.millisecondsSinceEpoch,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  bool get isPaidPlan => planId != PlanId.free;
  bool get isActive => status.isActive;

  /// Check if subscription is in grace period after expiration
  bool get isInGracePeriod {
    if (currentPeriodEnd == null) return false;
    final now = DateTime.now();
    const gracePeriod = Duration(days: 3); // matches backend
    return now.isAfter(currentPeriodEnd!) && now.isBefore(currentPeriodEnd!.add(gracePeriod));
  }
}

/// Usage record (Firestore: users/{uid}/usage/{yyyy-mm-dd})
class UsageRecord {
  final String date; // yyyy-mm-dd
  final int heavyOps;
  final int lightOps;
  final int filesProcessed;
  final int bytesProcessed;
  final DateTime lastUpdated;

  const UsageRecord({
    required this.date,
    required this.heavyOps,
    required this.lightOps,
    required this.filesProcessed,
    required this.bytesProcessed,
    required this.lastUpdated,
  });

  factory UsageRecord.empty(String date) {
    return UsageRecord(
      date: date,
      heavyOps: 0,
      lightOps: 0,
      filesProcessed: 0,
      bytesProcessed: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory UsageRecord.fromJson(Map<String, dynamic> json) {
    return UsageRecord(
      date: json['date'] as String,
      heavyOps: json['heavyOps'] as int? ?? 0,
      lightOps: json['lightOps'] as int? ?? 0,
      filesProcessed: json['filesProcessed'] as int? ?? 0,
      bytesProcessed: json['bytesProcessed'] as int? ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'heavyOps': heavyOps,
      'lightOps': lightOps,
      'filesProcessed': filesProcessed,
      'bytesProcessed': bytesProcessed,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  UsageRecord copyWith({
    int? heavyOps,
    int? lightOps,
    int? filesProcessed,
    int? bytesProcessed,
  }) {
    return UsageRecord(
      date: date,
      heavyOps: heavyOps ?? this.heavyOps,
      lightOps: lightOps ?? this.lightOps,
      filesProcessed: filesProcessed ?? this.filesProcessed,
      bytesProcessed: bytesProcessed ?? this.bytesProcessed,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Credits System v2 - Billing profile with minute-based credits
/// Firestore: users/{uid}/billing
class CreditsBilling {
  final PlanId plan;
  final int planMinutes; // Total minutes allocated per month for this plan
  final int creditsRemaining; // Remaining credits (1 credit = 1 minute)
  final int creditsUsed; // Credits used this month
  final DateTime lastRefill; // Last time credits were refilled
  final DateTime? nextRefillDate; // When credits will refill next
  final bool autoRefill; // Whether to auto-refill monthly

  const CreditsBilling({
    required this.plan,
    required this.planMinutes,
    required this.creditsRemaining,
    required this.creditsUsed,
    required this.lastRefill,
    this.nextRefillDate,
    this.autoRefill = true,
  });

  factory CreditsBilling.fromJson(Map<String, dynamic> json) {
    return CreditsBilling(
      plan: PlanId.fromString(json['plan'] as String),
      planMinutes: json['planMinutes'] as int,
      creditsRemaining: json['creditsRemaining'] as int,
      creditsUsed: json['creditsUsed'] as int,
      lastRefill: DateTime.parse(json['lastRefill'] as String),
      nextRefillDate:
          json['nextRefillDate'] != null ? DateTime.parse(json['nextRefillDate'] as String) : null,
      autoRefill: json['autoRefill'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.id,
      'planMinutes': planMinutes,
      'creditsRemaining': creditsRemaining,
      'creditsUsed': creditsUsed,
      'lastRefill': lastRefill.toIso8601String(),
      'nextRefillDate': nextRefillDate?.toIso8601String(),
      'autoRefill': autoRefill,
    };
  }

  /// Create default credits billing for a plan
  factory CreditsBilling.forPlan(PlanId plan) {
    final now = DateTime.now();
    final planMinutes = _getPlanMinutes(plan);
    return CreditsBilling(
      plan: plan,
      planMinutes: planMinutes,
      creditsRemaining: planMinutes,
      creditsUsed: 0,
      lastRefill: now,
      nextRefillDate: DateTime(now.year, now.month + 1, 1), // Next month
      autoRefill: true,
    );
  }

  static int _getPlanMinutes(PlanId plan) {
    switch (plan) {
      case PlanId.free:
        return 10; // 10 minutes per month for free
      case PlanId.pro:
        return 600; // 10 hours per month for pro
      case PlanId.proPlus:
        return 1800; // 30 hours per month for pro plus
    }
  }

  /// Check if user has enough credits for operation
  bool hasCredits(int minutesRequired) {
    return creditsRemaining >= minutesRequired;
  }

  /// Calculate credits needed for audio duration
  static int creditsForDuration(Duration audioDuration) {
    // 1 credit = 1 minute, round up to next minute
    return (audioDuration.inSeconds / 60).ceil();
  }

  /// Deduct credits for operation
  CreditsBilling deductCredits(int credits) {
    final newRemaining = (creditsRemaining - credits).clamp(0, planMinutes);
    final newUsed = creditsUsed + credits;

    return CreditsBilling(
      plan: plan,
      planMinutes: planMinutes,
      creditsRemaining: newRemaining,
      creditsUsed: newUsed,
      lastRefill: lastRefill,
      nextRefillDate: nextRefillDate,
      autoRefill: autoRefill,
    );
  }

  /// Check if it's time for monthly refill
  bool get needsRefill {
    if (nextRefillDate == null) return false;
    return DateTime.now().isAfter(nextRefillDate!);
  }

  /// Refill credits for new month
  CreditsBilling refillCredits() {
    final now = DateTime.now();
    return CreditsBilling(
      plan: plan,
      planMinutes: planMinutes,
      creditsRemaining: planMinutes, // Reset to full allocation
      creditsUsed: 0, // Reset usage
      lastRefill: now,
      nextRefillDate: DateTime(now.year, now.month + 1, 1),
      autoRefill: autoRefill,
    );
  }
}

/// VATS Job Status - tracks video processing progress
enum VATSJobStatus {
  uploading,
  converting,
  transcribing,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case VATSJobStatus.uploading:
        return 'Uploading video...';
      case VATSJobStatus.converting:
        return 'Converting to audio...';
      case VATSJobStatus.transcribing:
        return 'Transcribing audio...';
      case VATSJobStatus.completed:
        return 'Completed';
      case VATSJobStatus.failed:
        return 'Failed';
    }
  }
}

/// VATS Job - tracks video to transcript conversion
/// Firestore: users/{uid}/vats_jobs/{jobId}
class VATSJob {
  final String id;
  final String userId;
  final String fileName;
  final String videoUrl; // Storage URL
  final String? audioUrl; // Converted audio URL
  final VATSJobStatus status;
  final int progressPercent;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Duration? audioDuration;
  final int? creditsUsed;
  final String? transcriptText;
  final String? srtContent;

  const VATSJob({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.videoUrl,
    this.audioUrl,
    required this.status,
    this.progressPercent = 0,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.audioDuration,
    this.creditsUsed,
    this.transcriptText,
    this.srtContent,
  });

  factory VATSJob.fromJson(Map<String, dynamic> json) {
    return VATSJob(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fileName: json['fileName'] as String,
      videoUrl: json['videoUrl'] as String,
      audioUrl: json['audioUrl'] as String?,
      status: VATSJobStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => VATSJobStatus.uploading,
      ),
      progressPercent: json['progressPercent'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt:
          json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      errorMessage: json['errorMessage'] as String?,
      audioDuration: json['audioDurationSeconds'] != null
          ? Duration(seconds: json['audioDurationSeconds'] as int)
          : null,
      creditsUsed: json['creditsUsed'] as int?,
      transcriptText: json['transcriptText'] as String?,
      srtContent: json['srtContent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'status': status.name,
      'progressPercent': progressPercent,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'audioDurationSeconds': audioDuration?.inSeconds,
      'creditsUsed': creditsUsed,
      'transcriptText': transcriptText,
      'srtContent': srtContent,
    };
  }

  VATSJob copyWith({
    String? videoUrl,
    VATSJobStatus? status,
    int? progressPercent,
    String? audioUrl,
    DateTime? completedAt,
    String? errorMessage,
    Duration? audioDuration,
    int? creditsUsed,
    String? transcriptText,
    String? srtContent,
  }) {
    return VATSJob(
      id: id,
      userId: userId,
      fileName: fileName,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      audioDuration: audioDuration ?? this.audioDuration,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      transcriptText: transcriptText ?? this.transcriptText,
      srtContent: srtContent ?? this.srtContent,
    );
  }
}

/// Entitlement check result
class EntitlementCheckResult {
  final bool allowed;
  final String? reason;
  final int? currentUsage;
  final int? limit;
  final PlanId? planId;
  final bool requiresUpgrade;
  final PlanId? suggestedPlan;

  const EntitlementCheckResult({
    required this.allowed,
    this.reason,
    this.currentUsage,
    this.limit,
    this.planId,
    this.requiresUpgrade = false,
    this.suggestedPlan,
  });

  int get remaining => limit != null && currentUsage != null ? limit! - currentUsage! : 0;

  bool get isNearLimit {
    if (limit == null || currentUsage == null) return false;
    return remaining <= (limit! * 0.2).ceil(); // 20% remaining
  }
}
