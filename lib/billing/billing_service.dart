/// Billing service - handles subscription state and usage tracking.
///
/// Reads from Firestore:
/// - users/{uid}/billing/profile
/// - users/{uid}/usage/{yyyy-mm-dd}
///
/// Provides streams for reactive UI updates.
library;

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'billing_types.dart';

class BillingService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  // Cached pricing config
  Map<String, dynamic>? _pricingConfig;

  // Streams
  StreamSubscription<DocumentSnapshot>? _billingProfileSubscription;
  final _billingProfileController =
      StreamController<BillingProfile>.broadcast();

  StreamSubscription<DocumentSnapshot>? _usageSubscription;
  final _usageController = StreamController<UsageRecord>.broadcast();

  BillingService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get pricing config from assets
  Future<Map<String, dynamic>> getPricingConfig() async {
    if (_pricingConfig != null) return _pricingConfig!;

    final jsonString = await rootBundle.loadString('config/pricing.json');
    _pricingConfig = json.decode(jsonString) as Map<String, dynamic>;
    return _pricingConfig!;
  }

  /// Get plan by ID
  Future<Map<String, dynamic>?> getPlan(PlanId planId) async {
    final config = await getPricingConfig();
    final plans = config['plans'] as Map<String, dynamic>;
    return plans[planId.id] as Map<String, dynamic>?;
  }

  /// Get entitlements for a plan
  Future<Entitlements> getEntitlements(PlanId planId) async {
    final plan = await getPlan(planId);
    if (plan == null) {
      // Default to free
      final freePlan = await getPlan(PlanId.free);
      return Entitlements.fromJson(
          freePlan!['entitlements'] as Map<String, dynamic>);
    }
    return Entitlements.fromJson(plan['entitlements'] as Map<String, dynamic>);
  }

  /// Get all plans for display
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    final config = await getPricingConfig();
    final plans = config['plans'] as Map<String, dynamic>;
    return [
      plans['free'] as Map<String, dynamic>,
      plans['pro'] as Map<String, dynamic>,
      plans['pro_plus'] as Map<String, dynamic>,
    ];
  }

  /// Start listening to billing profile
  void startListening() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint(
          '[BillingService] No user logged in, skipping billing listener');
      return;
    }

    final userId = user.uid;

    // Listen to billing profile
    _billingProfileSubscription =
        _firestore.doc('users/$userId/billing/profile').snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          final profile = BillingProfile.fromJson(snapshot.data()!);
          _billingProfileController.add(profile);
        } else {
          // Create default free profile
          final freeProfile = BillingProfile.free();
          _firestore
              .doc('users/$userId/billing/profile')
              .set(freeProfile.toJson());
          _billingProfileController.add(freeProfile);
        }
      },
      onError: (error) {
        debugPrint(
            '[BillingService] Error listening to billing profile: $error');
      },
    );

    // Listen to today's usage
    final today = _getTodayDateString();
    _usageSubscription =
        _firestore.doc('users/$userId/usage/$today').snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          final usage = UsageRecord.fromJson(snapshot.data()!);
          _usageController.add(usage);
        } else {
          _usageController.add(UsageRecord.empty(today));
        }
      },
      onError: (error) {
        debugPrint('[BillingService] Error listening to usage: $error');
      },
    );
  }

  /// Stop listening
  void stopListening() {
    _billingProfileSubscription?.cancel();
    _usageSubscription?.cancel();
  }

  /// Stream of billing profile
  Stream<BillingProfile> get billingProfileStream =>
      _billingProfileController.stream;

  /// Stream of today's usage
  Stream<UsageRecord> get usageStream => _usageController.stream;

  /// Get current billing profile (one-time read)
  Future<BillingProfile> getBillingProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return BillingProfile.free();
    }

    final snapshot =
        await _firestore.doc('users/${user.uid}/billing/profile').get();

    if (snapshot.exists) {
      return BillingProfile.fromJson(snapshot.data()!);
    }

    return BillingProfile.free();
  }

  /// Get today's usage (one-time read)
  Future<UsageRecord> getTodayUsage() async {
    final user = _auth.currentUser;
    if (user == null) {
      return UsageRecord.empty(_getTodayDateString());
    }

    final today = _getTodayDateString();
    final snapshot =
        await _firestore.doc('users/${user.uid}/usage/$today').get();

    if (snapshot.exists) {
      return UsageRecord.fromJson(snapshot.data()!);
    }

    return UsageRecord.empty(today);
  }

  /// Check if user can perform heavy operation
  Future<EntitlementCheckResult> canPerformHeavyOp() async {
    final profile = await getBillingProfile();
    final usage = await getTodayUsage();
    final entitlements = await getEntitlements(profile.planId);

    if (usage.heavyOps >= entitlements.heavyOpsPerDay) {
      return EntitlementCheckResult(
        allowed: false,
        reason: 'Daily heavy operation limit reached',
        currentUsage: usage.heavyOps,
        limit: entitlements.heavyOpsPerDay,
        planId: profile.planId,
        requiresUpgrade: profile.planId == PlanId.free,
        suggestedPlan:
            profile.planId == PlanId.free ? PlanId.pro : PlanId.proPlus,
      );
    }

    return EntitlementCheckResult(
      allowed: true,
      currentUsage: usage.heavyOps,
      limit: entitlements.heavyOpsPerDay,
      planId: profile.planId,
    );
  }

  /// Check if file size is within limits
  Future<EntitlementCheckResult> canProcessFileSize(int fileSize) async {
    final profile = await getBillingProfile();
    final entitlements = await getEntitlements(profile.planId);

    if (fileSize > entitlements.maxFileSize) {
      return EntitlementCheckResult(
        allowed: false,
        reason: 'File size exceeds ${entitlements.maxFileSizeFormatted} limit',
        currentUsage: fileSize,
        limit: entitlements.maxFileSize,
        planId: profile.planId,
        requiresUpgrade: true,
        suggestedPlan: _getSuggestedPlanForFileSize(fileSize),
      );
    }

    return EntitlementCheckResult(
      allowed: true,
      currentUsage: fileSize,
      limit: entitlements.maxFileSize,
      planId: profile.planId,
    );
  }

  /// Check if batch size is within limits
  Future<EntitlementCheckResult> canProcessBatchSize(int batchSize) async {
    final profile = await getBillingProfile();
    final entitlements = await getEntitlements(profile.planId);

    if (batchSize > entitlements.maxBatchSize) {
      return EntitlementCheckResult(
        allowed: false,
        reason: 'Batch size exceeds ${entitlements.maxBatchSize} items limit',
        currentUsage: batchSize,
        limit: entitlements.maxBatchSize,
        planId: profile.planId,
        requiresUpgrade: true,
        suggestedPlan: _getSuggestedPlanForBatchSize(batchSize),
      );
    }

    return EntitlementCheckResult(
      allowed: true,
      currentUsage: batchSize,
      limit: entitlements.maxBatchSize,
      planId: profile.planId,
    );
  }

  /// Check if user can access a tool
  Future<EntitlementCheckResult> canAccessTool(String toolId) async {
    final profile = await getBillingProfile();
    final config = await getPricingConfig();
    final tools = config['tools'] as Map<String, dynamic>;
    final tool = tools[toolId] as Map<String, dynamic>?;

    if (tool == null) {
      return const EntitlementCheckResult(
        allowed: false,
        reason: 'Tool not found',
      );
    }

    final minPlan = PlanId.fromString(tool['minPlan'] as String);
    final planIndex =
        [PlanId.free, PlanId.pro, PlanId.proPlus].indexOf(profile.planId);
    final requiredIndex =
        [PlanId.free, PlanId.pro, PlanId.proPlus].indexOf(minPlan);

    if (planIndex < requiredIndex) {
      return EntitlementCheckResult(
        allowed: false,
        reason:
            '${tool['name']} requires ${_getPlanDisplayName(minPlan)} plan or higher',
        planId: profile.planId,
        requiresUpgrade: true,
        suggestedPlan: minPlan,
      );
    }

    return EntitlementCheckResult(
      allowed: true,
      planId: profile.planId,
    );
  }

  /// Track heavy operation usage
  Future<void> trackHeavyOp() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = _getTodayDateString();
    final usageRef = _firestore.doc('users/${user.uid}/usage/$today');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(usageRef);

      if (snapshot.exists) {
        final usage = UsageRecord.fromJson(snapshot.data()!);
        transaction.update(
            usageRef, usage.copyWith(heavyOps: usage.heavyOps + 1).toJson());
      } else {
        final newUsage = UsageRecord.empty(today).copyWith(heavyOps: 1);
        transaction.set(usageRef, newUsage.toJson());
      }
    });
  }

  /// Track file processing
  Future<void> trackFileProcessed(int bytes) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = _getTodayDateString();
    final usageRef = _firestore.doc('users/${user.uid}/usage/$today');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(usageRef);

      if (snapshot.exists) {
        final usage = UsageRecord.fromJson(snapshot.data()!);
        transaction.update(
          usageRef,
          usage
              .copyWith(
                filesProcessed: usage.filesProcessed + 1,
                bytesProcessed: usage.bytesProcessed + bytes,
              )
              .toJson(),
        );
      } else {
        final newUsage = UsageRecord.empty(today).copyWith(
          filesProcessed: 1,
          bytesProcessed: bytes,
        );
        transaction.set(usageRef, newUsage.toJson());
      }
    });
  }

  /// Create checkout session
  Future<Map<String, dynamic>> createCheckoutSession({
    required PlanId planId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    print('DEBUG: BillingService.createCheckoutSession called');
    print('DEBUG: planId: ${planId.id}, successUrl: $successUrl, cancelUrl: $cancelUrl');
    
    final callable = _functions.httpsCallable('createCheckoutSession');
    print('DEBUG: Calling Firebase function: createCheckoutSession');
    
    final result = await callable.call({
      'planId': planId.id,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    });
    
    print('DEBUG: Firebase function result: ${result.data}');
    return result.data as Map<String, dynamic>;
  }

  /// Create portal link
  Future<String> createPortalLink(String returnUrl) async {
    final callable = _functions.httpsCallable('createPortalLink');
    final result = await callable.call({'returnUrl': returnUrl});
    final data = result.data as Map<String, dynamic>;
    return data['url'] as String;
  }

  /// Helper: Get today's date string (yyyy-mm-dd)
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Helper: Get suggested plan for file size
  PlanId _getSuggestedPlanForFileSize(int fileSize) {
    if (fileSize <= 52428800) return PlanId.pro; // 50MB
    return PlanId.proPlus;
  }

  /// Helper: Get suggested plan for batch size
  PlanId _getSuggestedPlanForBatchSize(int batchSize) {
    if (batchSize <= 20) return PlanId.pro;
    return PlanId.proPlus;
  }

  /// Helper: Get plan display name
  String _getPlanDisplayName(PlanId planId) {
    switch (planId) {
      case PlanId.free:
        return 'Free';
      case PlanId.pro:
        return 'Pro';
      case PlanId.proPlus:
        return 'Pro+';
    }
  }

  void dispose() {
    stopListening();
    _billingProfileController.close();
    _usageController.close();
  }
}
