/// Billing types matching backend schema.
///
/// Keep in sync with functions/src/types/billing.ts

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

  bool get isActive =>
      this == SubscriptionStatus.active || this == SubscriptionStatus.trialing;
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
    if (maxFileSize < 1024 * 1024)
      return '${(maxFileSize / 1024).toStringAsFixed(0)} KB';
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
    return BillingProfile(
      stripeCustomerId: json['stripeCustomerId'] as String?,
      planId: PlanId.fromString(json['planId'] as String? ?? 'free'),
      status:
          SubscriptionStatus.fromString(json['status'] as String? ?? 'free'),
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['currentPeriodStart'] as int)
          : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['currentPeriodEnd'] as int)
          : null,
      trialEnd: json['trialEnd'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['trialEnd'] as int)
          : null,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
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
    final gracePeriod = Duration(days: 3); // matches backend
    return now.isAfter(currentPeriodEnd!) &&
        now.isBefore(currentPeriodEnd!.add(gracePeriod));
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
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int),
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

  int get remaining =>
      limit != null && currentUsage != null ? limit! - currentUsage! : 0;

  bool get isNearLimit {
    if (limit == null || currentUsage == null) return false;
    return remaining <= (limit! * 0.2).ceil(); // 20% remaining
  }
}
