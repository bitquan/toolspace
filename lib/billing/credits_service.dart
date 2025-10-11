/// Credits Service - manages minute-based credits for VATS operations.
///
/// Handles:
/// - Credit balance tracking
/// - Deduction for transcription jobs
/// - Monthly refill logic
/// - Local Stripe webhook simulation
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/services/debug_logger.dart';
import 'billing_types.dart';

class CreditsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Streams
  StreamSubscription<DocumentSnapshot>? _creditsSubscription;
  final _creditsController = StreamController<CreditsBilling>.broadcast();

  CreditsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Stream of credits billing updates
  Stream<CreditsBilling> get creditsStream => _creditsController.stream;

  /// Get current credits billing data
  Future<CreditsBilling?> getCurrentCredits() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.doc('users/${user.uid}/billing').get();
      if (doc.exists) {
        final data = doc.data()!;
        return CreditsBilling.fromJson(data);
      }
      return null;
    } catch (e) {
      DebugLogger.error('Failed to get credits: $e');
      return null;
    }
  }

  /// Initialize credits for new user
  Future<void> initializeCredits(PlanId plan) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final credits = CreditsBilling.forPlan(plan);
      await _firestore.doc('users/${user.uid}/billing').set(credits.toJson());
      DebugLogger.info('💳 Initialized credits for ${plan.id}: ${credits.planMinutes} minutes');
    } catch (e) {
      DebugLogger.error('Failed to initialize credits: $e');
    }
  }

  /// Check if user has enough credits for operation
  Future<bool> hasCreditsFor(int minutesRequired) async {
    final credits = await getCurrentCredits();
    if (credits == null) return false;
    
    // Check if refill is needed first
    if (credits.needsRefill) {
      await _performRefill();
      final updatedCredits = await getCurrentCredits();
      return updatedCredits?.hasCredits(minutesRequired) ?? false;
    }
    
    return credits.hasCredits(minutesRequired);
  }

  /// Deduct credits for VATS operation
  Future<bool> deductCreditsFor(Duration audioDuration, String jobId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final creditsNeeded = CreditsBilling.creditsForDuration(audioDuration);
    
    try {
      final credits = await getCurrentCredits();
      if (credits == null) {
        DebugLogger.error('No credits billing found for user');
        return false;
      }

      if (!credits.hasCredits(creditsNeeded)) {
        DebugLogger.warning('Insufficient credits: need $creditsNeeded, have ${credits.creditsRemaining}');
        return false;
      }

      final updatedCredits = credits.deductCredits(creditsNeeded);
      await _firestore.doc('users/${user.uid}/billing').update(updatedCredits.toJson());
      
      DebugLogger.info('💳 Deducted $creditsNeeded credits for job $jobId (${audioDuration.inMinutes}m ${audioDuration.inSeconds % 60}s)');
      return true;
    } catch (e) {
      DebugLogger.error('Failed to deduct credits: $e');
      return false;
    }
  }

  /// Add credits via top-up (simulated Stripe webhook)
  Future<void> addCredits(int additionalMinutes, String reason) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final credits = await getCurrentCredits();
      if (credits == null) return;

      final updatedCredits = CreditsBilling(
        plan: credits.plan,
        planMinutes: credits.planMinutes + additionalMinutes,
        creditsRemaining: credits.creditsRemaining + additionalMinutes,
        creditsUsed: credits.creditsUsed,
        lastRefill: credits.lastRefill,
        nextRefillDate: credits.nextRefillDate,
        autoRefill: credits.autoRefill,
      );

      await _firestore.doc('users/${user.uid}/billing').update(updatedCredits.toJson());
      DebugLogger.info('💳 Added $additionalMinutes credits: $reason');
    } catch (e) {
      DebugLogger.error('Failed to add credits: $e');
    }
  }

  /// Perform monthly refill
  Future<void> _performRefill() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final credits = await getCurrentCredits();
      if (credits == null || !credits.needsRefill) return;

      final refilled = credits.refillCredits();
      await _firestore.doc('users/${user.uid}/billing').update(refilled.toJson());
      
      DebugLogger.info('💳 Monthly refill completed: ${refilled.planMinutes} credits restored');
    } catch (e) {
      DebugLogger.error('Failed to perform refill: $e');
    }
  }

  /// Start listening to credits changes
  void startListening() {
    final user = _auth.currentUser;
    if (user == null) return;

    _creditsSubscription?.cancel();
    _creditsSubscription = _firestore
        .doc('users/${user.uid}/billing')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final credits = CreditsBilling.fromJson(snapshot.data()!);
        _creditsController.add(credits);
      }
    });
  }

  /// Stop listening to credits changes
  void stopListening() {
    _creditsSubscription?.cancel();
    _creditsSubscription = null;
  }

  /// Simulate Stripe webhook for local testing
  Future<void> simulateStripeTopUp(int additionalMinutes) async {
    if (!kDebugMode) {
      DebugLogger.warning('Stripe simulation only available in debug mode');
      return;
    }

    await addCredits(additionalMinutes, 'Simulated Stripe top-up');
    DebugLogger.info('🧪 SIMULATED: Stripe webhook added $additionalMinutes credits');
  }

  /// Simulate monthly refill for local testing
  Future<void> simulateMonthlyRefill() async {
    if (!kDebugMode) {
      DebugLogger.warning('Monthly refill simulation only available in debug mode');
      return;
    }

    await _performRefill();
    DebugLogger.info('🧪 SIMULATED: Monthly refill completed');
  }

  /// Get credits summary for UI display
  Future<Map<String, dynamic>> getCreditsSummary() async {
    final credits = await getCurrentCredits();
    if (credits == null) {
      return {
        'plan': 'free',
        'creditsRemaining': 0,
        'creditsUsed': 0,
        'planMinutes': 0,
        'percentUsed': 0.0,
        'daysUntilRefill': 0,
        'status': 'no_billing',
      };
    }

    final percentUsed = credits.planMinutes > 0 
        ? (credits.creditsUsed / credits.planMinutes) * 100
        : 0.0;

    final daysUntilRefill = credits.nextRefillDate != null
        ? credits.nextRefillDate!.difference(DateTime.now()).inDays
        : 0;

    return {
      'plan': credits.plan.id,
      'creditsRemaining': credits.creditsRemaining,
      'creditsUsed': credits.creditsUsed,
      'planMinutes': credits.planMinutes,
      'percentUsed': percentUsed,
      'daysUntilRefill': daysUntilRefill.clamp(0, 31),
      'status': credits.creditsRemaining > 0 ? 'active' : 'depleted',
    };
  }

  void dispose() {
    stopListening();
    _creditsController.close();
  }
}
