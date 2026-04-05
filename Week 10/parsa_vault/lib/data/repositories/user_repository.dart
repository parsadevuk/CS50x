import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ── Reads ──────────────────────────────────────────────────────────────────

  Future<User?> findById(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) return null;
    return User.fromFirestore(doc);
  }

  Future<User?> findByEmail(String email) async {
    final q = await _users
        .where('email', isEqualTo: email.toLowerCase().trim())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return User.fromFirestore(q.docs.first);
  }

  Future<User?> findByUsername(String username) async {
    final q = await _users
        .where('username', isEqualTo: username.toLowerCase().trim())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return User.fromFirestore(q.docs.first);
  }

  Future<User?> findByEmailOrUsername(String value) async {
    final lower = value.toLowerCase().trim();
    final byEmail = await findByEmail(lower);
    if (byEmail != null) return byEmail;
    return findByUsername(lower);
  }

  Future<bool> emailExists(String email) async =>
      (await findByEmail(email)) != null;

  Future<bool> usernameExists(String username) async =>
      (await findByUsername(username)) != null;

  Future<bool> anyUsersExist() async {
    final q = await _users.limit(1).get();
    return q.docs.isNotEmpty;
  }

  /// Returns all users ordered by XP descending (for leaderboard).
  Future<List<User>> getAllByXp() async {
    final q = await _users.orderBy('xp', descending: true).get();
    return q.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  // ── Writes ─────────────────────────────────────────────────────────────────

  Future<void> insert(User user) async {
    await _users.doc(user.id).set(user.toFirestore());
  }

  Future<void> update(User user) async {
    await _users.doc(user.id).set(user.toFirestore());
  }

  Future<void> updateFinancials({
    required String userId,
    required double cashBalance,
    required int xp,
    required int level,
  }) async {
    await _users.doc(userId).update({
      'cashBalance': cashBalance,
      'xp': xp,
      'level': level,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLastLogin(String userId) async {
    await _users.doc(userId).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUsername(String userId, String username) async {
    await _users.doc(userId).update({
      'username': username.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFullName(String userId, String fullName) async {
    await _users.doc(userId).update({
      'fullName': fullName.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfilePicture(String userId, String? base64Image) async {
    await _users.doc(userId).update({
      'profilePicture': base64Image,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes all Firestore data for this user (holdings, transactions, profile).
  Future<void> deleteUserData(String userId) async {
    final userDoc = _users.doc(userId);

    // Delete holdings sub-collection
    final holdings = await userDoc.collection('holdings').get();
    for (final doc in holdings.docs) {
      await doc.reference.delete();
    }

    // Delete transactions sub-collection
    final transactions = await userDoc.collection('transactions').get();
    for (final doc in transactions.docs) {
      await doc.reference.delete();
    }

    // Delete user document
    await userDoc.delete();
  }

  Future<void> updateLocation(String userId, String city, String country) async {
    await _users.doc(userId).update({
      'city': city.trim(),
      'country': country.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateWebsite(String userId, String? website) async {
    await _users.doc(userId).update({
      'website':
          website?.trim().isNotEmpty == true ? website!.trim() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEmail(String userId, String email) async {
    await _users.doc(userId).update({
      'email': email.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Copies guest game data (holdings, transactions, cash, XP) to an existing
  /// account. The existing account keeps its own name/username/email.
  Future<void> copyGameData({
    required String fromUid,
    required String toUid,
    required double cashBalance,
    required int xp,
    required int level,
  }) async {
    final fromDoc = _users.doc(fromUid);
    final toDoc = _users.doc(toUid);

    // 1. Update financials on existing account — floor cash to cents
    final cleanCash = (cashBalance * 100).floorToDouble() / 100;
    await toDoc.update({
      'cashBalance': cleanCash,
      'xp': xp,
      'level': level,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Replace holdings
    final existingHoldings = await toDoc.collection('holdings').get();
    for (final doc in existingHoldings.docs) {
      await doc.reference.delete();
    }
    final guestHoldings = await fromDoc.collection('holdings').get();
    for (final doc in guestHoldings.docs) {
      await toDoc.collection('holdings').doc(doc.id).set(doc.data());
    }

    // 3. Replace transactions
    final existingTxs = await toDoc.collection('transactions').get();
    for (final doc in existingTxs.docs) {
      await doc.reference.delete();
    }
    final guestTxs = await fromDoc.collection('transactions').get();
    for (final doc in guestTxs.docs) {
      await toDoc.collection('transactions').doc(doc.id).set(doc.data());
    }
  }
}
