import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'share_envelope.dart';

/// Persistent handoff store using Firestore
/// Stores user-scoped cross-tool data for retrieval across sessions
class HandoffStore {
  static final HandoffStore _instance = HandoffStore._internal();
  static HandoffStore get instance => _instance;

  HandoffStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save an envelope to Firestore for later retrieval
  Future<String> save(ShareEnvelope envelope) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to save handoffs');
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('handoffs')
        .add({
      ...envelope.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Retrieve an envelope by ID
  Future<ShareEnvelope?> get(String id) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('handoffs')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return ShareEnvelope.fromJson(data);
  }

  /// Get all handoffs for current user
  Future<List<ShareEnvelope>> getAll() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final query = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('handoffs')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return query.docs.map((doc) => ShareEnvelope.fromJson(doc.data())).toList();
  }

  /// Delete a handoff by ID
  Future<void> delete(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('handoffs')
        .doc(id)
        .delete();
  }

  /// Clear all handoffs for current user
  Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final query = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('handoffs')
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Clean up expired handoffs (older than TTL)
  Future<void> cleanupExpired({Duration ttl = const Duration(days: 7)}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cutoff = DateTime.now().subtract(ttl);
    final query = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('handoffs')
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
