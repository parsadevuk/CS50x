import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user.dart';
import '../../utils/constants.dart';
import '../../utils/xp_calculator.dart';
import '../repositories/user_repository.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final bool isNewUser;
  final bool isEmailConflict;
  /// Set when a guest signs into an *existing* SSO account — UI must show merge dialog.
  final GuestMergePreview? guestMergePreview;

  const AuthResult({
    required this.success,
    this.error,
    this.user,
    this.isNewUser = false,
    this.isEmailConflict = false,
    this.guestMergePreview,
  });
}

/// Holds both user snapshots during the two-step guest login merge flow.
class GuestMergePreview {
  final String guestUid;
  final User guestUser;
  final User existingUser;

  const GuestMergePreview({
    required this.guestUid,
    required this.guestUser,
    required this.existingUser,
  });
}

class AuthService {
  final _userRepo = UserRepository();
  final _auth = fb.FirebaseAuth.instance;

  // ── Session ───────────────────────────────────────────────────────────────

  /// Returns the signed-in user's local profile, or null if signed out.
  Future<User?> getSessionUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    return _userRepo.findById(fbUser.uid);
  }

  /// True if any user profiles exist in the local database.
  Future<bool> anyUsersExist() => _userRepo.anyUsersExist();

  /// Whether the current Firebase user has verified their email.
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// True if the current user is an anonymous guest.
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  /// True if the current user signed in via SSO (no email/password provider).
  bool get currentUserIsSso {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return false;
    return fbUser.providerData.every((p) => p.providerId != 'password');
  }

  // ── Email + Password ──────────────────────────────────────────────────────

  Future<AuthResult> register({
    required String fullName,
    required String username,
    required String email,
    String? website,
    required String password,
  }) async {
    if (await _userRepo.usernameExists(username.trim().toLowerCase())) {
      return const AuthResult(
        success: false,
        error: 'That username is already taken. Try a different one.',
      );
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final uid = credential.user!.uid;
      final now = DateTime.now().toUtc();

      final user = User(
        id: uid,
        fullName: fullName.trim(),
        username: username.trim().toLowerCase(),
        email: email.trim().toLowerCase(),
        website: website?.trim().isNotEmpty == true ? website!.trim() : null,
        passwordHash: '',
        cashBalance: AppConstants.startingCash,
        xp: 0,
        level: 1,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: null,
      );

      await _userRepo.insert(user);

      // Send verification email (non-blocking — we don't gate login on it)
      try {
        await credential.user!.sendEmailVerification();
      } catch (_) {}

      return AuthResult(success: true, user: user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _authError(e.code));
    }
  }

  Future<AuthResult> login({
    required String emailOrUsername,
    required String password,
  }) async {
    String email;
    if (emailOrUsername.contains('@')) {
      email = emailOrUsername.trim().toLowerCase();
    } else {
      final profile = await _userRepo
          .findByEmailOrUsername(emailOrUsername.trim().toLowerCase());
      if (profile == null) {
        return const AuthResult(
          success: false,
          error: "We couldn't log you in. Check your details and try again.",
        );
      }
      email = profile.email;
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await _userRepo.findById(credential.user!.uid);
      if (user == null) {
        await _auth.signOut();
        return const AuthResult(
          success: false,
          error: 'Account data not found. Please register again.',
        );
      }

      final updatedUser = await _awardDailyLoginXp(user);
      await _userRepo.updateLastLogin(updatedUser.id);
      return AuthResult(success: true, user: updatedUser);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _authError(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AuthResult> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return const AuthResult(success: false, error: 'Not signed in.');
    }

    try {
      final credential = fb.EmailAuthProvider.credential(
        email: fbUser.email!,
        password: currentPassword,
      );
      await fbUser.reauthenticateWithCredential(credential);
      await fbUser.updatePassword(newPassword);
      return const AuthResult(success: true);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _authError(e.code));
    }
  }

  // ── Email Verification ────────────────────────────────────────────────────

  /// Sends a verification email to the current user's address.
  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on fb.FirebaseAuthException catch (_) {}
  }

  /// Sends a password reset email. Returns error string or null on success.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with that email address.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
  }

  /// Re-fetches Firebase user state to get the latest emailVerified flag.
  Future<bool> refreshEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ── SSO guest-aware helpers ───────────────────────────────────────────────

  /// Snapshot the current anonymous session before SSO replaces it.
  Future<({String? guestUid, User? guestProfile})> _captureGuest() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || !fbUser.isAnonymous) {
      return (guestUid: null, guestProfile: null);
    }
    final guestUid = fbUser.uid;
    try {
      final profile = await _userRepo.findById(guestUid);
      return (guestUid: guestUid, guestProfile: profile);
    } catch (_) {
      // Firestore security rules may block anonymous reads — capture uid anyway.
      // The merge dialog will use the live in-memory profile passed from the provider.
      return (guestUid: guestUid, guestProfile: null);
    }
  }

  /// Copies guest game data to [toUid] and deletes the guest Firestore doc.
  Future<void> _copyAndCleanGuestData({
    required String guestUid,
    required User guestProfile,
    required String toUid,
  }) async {
    try {
      await _userRepo.copyGameData(
        fromUid: guestUid,
        toUid: toUid,
        cashBalance: guestProfile.cashBalance,
        xp: guestProfile.xp,
        level: guestProfile.level,
      );
    } catch (_) {}
    try { await _userRepo.deleteUserData(guestUid); } catch (_) {}
  }

  // ── Google SSO ────────────────────────────────────────────────────────────

  /// [fallbackGuestUser] — the in-memory guest user already held by the provider.
  /// Avoids a redundant (and potentially rule-blocked) Firestore read.
  Future<AuthResult> signInWithGoogle({User? fallbackGuestUser}) async {
    // Capture guest state BEFORE SSO clears Firebase Auth current user.
    // Use the in-memory fallback if Firestore read fails.
    final (:guestUid, :guestProfile) = await _captureGuest();
    final effectiveGuestProfile = guestProfile ?? fallbackGuestUser;

    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Clear cached account so picker always shows
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult(success: false, error: null);
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final (:user, :isNew) =
          await _getOrCreateSsoProfile(userCredential.user!);
      final updatedUser = await _awardDailyLoginXp(user);
      await _userRepo.updateLastLogin(updatedUser.id);

      // ── Guest merge ──────────────────────────────────────────────────────
      if (guestUid != null && effectiveGuestProfile != null) {
        if (isNew) {
          // Brand-new SSO account — auto-copy guest data (no conflict)
          await _copyAndCleanGuestData(
              guestUid: guestUid, guestProfile: effectiveGuestProfile, toUid: updatedUser.id);
          final merged = await _userRepo.findById(updatedUser.id) ?? updatedUser;
          return AuthResult(success: true, user: merged, isNewUser: true);
        } else {
          // Existing SSO account — let the UI ask which data to keep
          return AuthResult(
            success: true,
            user: updatedUser,
            isNewUser: false,
            guestMergePreview: GuestMergePreview(
              guestUid: guestUid,
              guestUser: effectiveGuestProfile,
              existingUser: updatedUser,
            ),
          );
        }
      }

      return AuthResult(success: true, user: updatedUser, isNewUser: isNew);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _authError(e.code));
    } catch (e, stack) {
      debugPrint('Google SSO error: $e\n$stack');
      return const AuthResult(
          success: false, error: 'Google sign-in failed. Please try again.');
    }
  }

  // ── Apple SSO ─────────────────────────────────────────────────────────────
  // Uses Firebase's built-in AppleAuthProvider which handles nonce internally.

  Future<AuthResult> signInWithApple({User? fallbackGuestUser}) async {
    final (:guestUid, :guestProfile) = await _captureGuest();
    final effectiveGuestProfile = guestProfile ?? fallbackGuestUser;

    try {
      final provider = fb.AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await _auth.signInWithProvider(provider);
      final (:user, :isNew) =
          await _getOrCreateSsoProfile(userCredential.user!);
      final updatedUser = await _awardDailyLoginXp(user);
      await _userRepo.updateLastLogin(updatedUser.id);

      if (guestUid != null && effectiveGuestProfile != null) {
        if (isNew) {
          await _copyAndCleanGuestData(
              guestUid: guestUid, guestProfile: effectiveGuestProfile, toUid: updatedUser.id);
          final merged = await _userRepo.findById(updatedUser.id) ?? updatedUser;
          return AuthResult(success: true, user: merged, isNewUser: true);
        } else {
          return AuthResult(
            success: true,
            user: updatedUser,
            isNewUser: false,
            guestMergePreview: GuestMergePreview(
              guestUid: guestUid,
              guestUser: effectiveGuestProfile,
              existingUser: updatedUser,
            ),
          );
        }
      }

      return AuthResult(success: true, user: updatedUser, isNewUser: isNew);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        return const AuthResult(success: false, error: null);
      }
      return AuthResult(success: false, error: _authError(e.code));
    } catch (e) {
      if (e.toString().contains('cancel') ||
          e.toString().contains('Cancel') ||
          e.toString().contains('1001')) {
        return const AuthResult(success: false, error: null);
      }
      return const AuthResult(
          success: false, error: 'Apple sign-in failed. Please try again.');
    }
  }

  // ── Guest / Anonymous ─────────────────────────────────────────────────────

  Future<AuthResult> signInAnonymously() async {
    try {
      final fbUser = _auth.currentUser;
      // Already anonymous — just restore profile
      if (fbUser != null && fbUser.isAnonymous) {
        final existing = await _userRepo.findById(fbUser.uid);
        if (existing != null) return AuthResult(success: true, user: existing);
      }

      final credential = await _auth.signInAnonymously();
      final uid = credential.user!.uid;

      final existing = await _userRepo.findById(uid);
      if (existing != null) return AuthResult(success: true, user: existing);

      final now = DateTime.now().toUtc();
      final shortId = uid.substring(0, 6);
      final user = User(
        id: uid,
        fullName: 'Guest',
        username: 'guest_$shortId',
        email: '',
        website: null,
        passwordHash: '',
        cashBalance: AppConstants.startingCash,
        xp: 0,
        level: 1,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: null,
      );

      await _userRepo.insert(user);
      return AuthResult(success: true, user: user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _authError(e.code));
    }
  }

  /// Links a guest account to a real email/password account.
  /// The UID stays the same so all portfolio data is preserved.
  Future<AuthResult> linkGuestWithEmail({
    required String fullName,
    required String username,
    required String email,
    String? website,
    required String password,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || !fbUser.isAnonymous) {
      return const AuthResult(success: false, error: 'Not signed in as guest.');
    }

    if (await _userRepo.usernameExists(username.trim().toLowerCase())) {
      return const AuthResult(
          success: false, error: 'That username is already taken. Try a different one.');
    }

    try {
      final credential = fb.EmailAuthProvider.credential(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final linked = await fbUser.linkWithCredential(credential);
      final uid = linked.user!.uid;

      // Update the guest profile with real details
      await _userRepo.updateFullName(uid, fullName.trim());
      await _userRepo.updateUsername(uid, username.trim().toLowerCase());
      await _userRepo.updateEmail(uid, email.trim().toLowerCase());
      if (website != null && website.trim().isNotEmpty) {
        await _userRepo.updateWebsite(uid, website.trim());
      }

      try { await linked.user!.sendEmailVerification(); } catch (_) {}

      final user = await _userRepo.findById(uid);
      return AuthResult(success: true, user: user);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        // Signal the UI to show the conflict resolution dialog
        return const AuthResult(
          success: false,
          isEmailConflict: true,
          error: 'email-conflict',
        );
      }
      return AuthResult(success: false, error: _authError(e.code));
    }
  }

  /// Called when guest chooses "Keep guest progress" or "Keep existing account".
  /// Authenticates into the existing account, optionally overwrites its game
  /// data with the guest's data, then deletes the anonymous guest.
  Future<AuthResult> mergeGuestAndSignInToExisting({
    required String email,
    required String password,
    required bool keepGuestData,
  }) async {
    final guestFbUser = _auth.currentUser;
    if (guestFbUser == null || !guestFbUser.isAnonymous) {
      return const AuthResult(success: false, error: 'Not signed in as guest.');
    }

    final guestUid = guestFbUser.uid;

    // Read guest profile before signing out
    final guestProfile = await _userRepo.findById(guestUid);

    try {
      // Sign in to existing account (this signs out the anonymous user in Firebase Auth)
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final existingUid = credential.user!.uid;

      if (keepGuestData && guestProfile != null) {
        // Overwrite existing account's game data with guest's data
        await _userRepo.copyGameData(fromUid: guestUid, toUid: existingUid,
            cashBalance: guestProfile.cashBalance,
            xp: guestProfile.xp,
            level: guestProfile.level);
      }

      // Clean up orphaned guest Firestore data
      try { await _userRepo.deleteUserData(guestUid); } catch (_) {}

      final user = await _userRepo.findById(existingUid);
      if (user == null) {
        return const AuthResult(success: false, error: 'Account data not found.');
      }

      return AuthResult(success: true, user: user);
    } on fb.FirebaseAuthException catch (e) {
      // Re-map wrong password to a friendlier message
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return const AuthResult(
          success: false,
          error: 'Wrong password for the existing account. Please try again.',
        );
      }
      return AuthResult(success: false, error: _authError(e.code));
    }
  }

  /// Links a guest account to an SSO provider (Google/Apple/Microsoft).
  Future<AuthResult> linkGuestWithSso(fb.AuthCredential ssoCredential) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || !fbUser.isAnonymous) {
      return const AuthResult(success: false, error: 'Not signed in as guest.');
    }
    try {
      final linked = await fbUser.linkWithCredential(ssoCredential);
      final (:user, :isNew) = await _getOrCreateSsoProfile(linked.user!);
      return AuthResult(success: true, user: user, isNewUser: isNew);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _authError(e.code));
    }
  }

  // ── Microsoft SSO ─────────────────────────────────────────────────────────

  Future<AuthResult> signInWithMicrosoft({User? fallbackGuestUser}) async {
    final (:guestUid, :guestProfile) = await _captureGuest();
    final effectiveGuestProfile = guestProfile ?? fallbackGuestUser;

    try {
      final provider = fb.OAuthProvider('microsoft.com')
        ..addScope('email')
        ..addScope('openid')
        ..addScope('profile');

      final userCredential = await _auth.signInWithProvider(provider);
      final (:user, :isNew) =
          await _getOrCreateSsoProfile(userCredential.user!);
      final updatedUser = await _awardDailyLoginXp(user);
      await _userRepo.updateLastLogin(updatedUser.id);

      if (guestUid != null && effectiveGuestProfile != null) {
        if (isNew) {
          await _copyAndCleanGuestData(
              guestUid: guestUid, guestProfile: effectiveGuestProfile, toUid: updatedUser.id);
          final merged = await _userRepo.findById(updatedUser.id) ?? updatedUser;
          return AuthResult(success: true, user: merged, isNewUser: true);
        } else {
          return AuthResult(
            success: true,
            user: updatedUser,
            isNewUser: false,
            guestMergePreview: GuestMergePreview(
              guestUid: guestUid,
              guestUser: effectiveGuestProfile,
              existingUser: updatedUser,
            ),
          );
        }
      }

      return AuthResult(success: true, user: updatedUser, isNewUser: isNew);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _authError(e.code));
    } catch (_) {
      return const AuthResult(
          success: false,
          error: 'Microsoft sign-in failed. Please try again.');
    }
  }

  // ── Guest two-step merge ──────────────────────────────────────────────────

  /// Step 1: Signs in to the existing account while still having the guest UID.
  /// Reads guest data BEFORE signing in (own-document read always works),
  /// then reads existing account data AFTER signing in (own-document read).
  /// Returns both snapshots for UI comparison — no game data is modified yet.
  Future<({GuestMergePreview? preview, String? error})> beginGuestLogin({
    required String emailOrUsername,
    required String password,
  }) async {
    final guestFbUser = _auth.currentUser;
    if (guestFbUser == null || !guestFbUser.isAnonymous) {
      return (preview: null, error: 'Not signed in as guest.');
    }

    final guestUid = guestFbUser.uid;

    // Read our own guest doc — always permitted regardless of security rules
    final guestProfile = await _userRepo.findById(guestUid);
    if (guestProfile == null) {
      return (preview: null, error: 'Guest data not found.');
    }

    // Resolve username → email (wrapped; if rules block cross-user query, fail gracefully)
    String email;
    if (emailOrUsername.trim().contains('@')) {
      email = emailOrUsername.trim().toLowerCase();
    } else {
      try {
        final found = await _userRepo
            .findByUsername(emailOrUsername.trim().toLowerCase());
        if (found == null) {
          return (preview: null,
            error: "We couldn't find an account with that username.");
        }
        email = found.email;
      } catch (_) {
        return (preview: null,
          error: 'Please use your email address to log in.');
      }
    }

    try {
      // Switching Firebase Auth from anonymous → real account
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final existingUid = credential.user!.uid;

      // Now read the real account's own doc (own-document read — always works)
      final existingUser = await _userRepo.findById(existingUid);
      if (existingUser == null) {
        await _auth.signOut();
        return (preview: null, error: 'Account data not found.');
      }

      return (
        preview: GuestMergePreview(
          guestUid: guestUid,
          guestUser: guestProfile,
          existingUser: existingUser,
        ),
        error: null,
      );
    } on fb.FirebaseAuthException catch (e) {
      return (preview: null, error: _authError(e.code));
    }
  }

  /// Step 2: Finalise after the user has chosen which data to keep.
  /// [keepGuestData] = true → copy guest game data over the existing account.
  Future<AuthResult> finalizeMerge({
    required String guestUid,
    required bool keepGuestData,
  }) async {
    final existingFbUser = _auth.currentUser;
    if (existingFbUser == null) {
      return const AuthResult(success: false, error: 'Not signed in.');
    }
    final existingUid = existingFbUser.uid;

    if (keepGuestData) {
      try {
        final guestProfile = await _userRepo.findById(guestUid);
        if (guestProfile != null) {
          await _userRepo.copyGameData(
            fromUid: guestUid,
            toUid: existingUid,
            cashBalance: guestProfile.cashBalance,
            xp: guestProfile.xp,
            level: guestProfile.level,
          );
        }
      } catch (_) {}
    }

    // Clean up orphaned guest Firestore data
    try { await _userRepo.deleteUserData(guestUid); } catch (_) {}

    var user = await _userRepo.findById(existingUid);
    if (user == null) {
      return const AuthResult(success: false, error: 'Account data not found.');
    }
    user = await _awardDailyLoginXp(user);
    await _userRepo.updateLastLogin(user.id);
    return AuthResult(success: true, user: user);
  }

  // ── Other ─────────────────────────────────────────────────────────────────

  Future<User> refreshUser(String userId) async {
    final user = await _userRepo.findById(userId);
    return user!;
  }

  /// Returns an error message if the image exceeds 200 KB, otherwise null.
  String? validateProfilePicture(String base64Image) {
    // base64 length * 3/4 ≈ original byte size
    final estimatedBytes = (base64Image.length * 3 / 4).round();
    if (estimatedBytes > 200 * 1024) {
      return 'Image is too large. Please choose a photo under 200 KB.';
    }
    return null;
  }

  Future<void> updateProfilePicture(String userId, String? base64Image) async {
    if (base64Image != null) {
      final error = validateProfilePicture(base64Image);
      if (error != null) throw Exception(error);
    }
    await _userRepo.updateProfilePicture(userId, base64Image);
  }

  Future<void> updateLocation(String userId, String city, String country) async {
    await _userRepo.updateLocation(userId, city, country);
  }

  Future<void> updateFullName(String userId, String fullName) async {
    await _userRepo.updateFullName(userId, fullName.trim());
  }

  /// Returns error string if username taken, null if success.
  Future<String?> updateUsername(String userId, String newUsername) async {
    final trimmed = newUsername.trim().toLowerCase();
    final existing = await _userRepo.findByUsername(trimmed);
    if (existing != null && existing.id != userId) {
      return 'Username already taken. Please choose another.';
    }
    await _userRepo.updateUsername(userId, trimmed);
    return null;
  }

  Future<void> updateWebsite(String userId, String? website) async {
    await _userRepo.updateWebsite(userId, website);
  }

  /// Deletes all Firestore data and Firebase Auth account.
  /// Returns null on success, or an error message string.
  Future<String?> deleteAccount(String userId) async {
    try {
      await _userRepo.deleteUserData(userId);
      await _auth.currentUser?.delete();
      return null;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please log out and sign in again before deleting your account.';
      }
      return e.message ?? 'Failed to delete account.';
    } catch (e) {
      return 'Failed to delete account. Please try again.';
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Gets an existing local profile or creates a new one for SSO sign-ins.
  /// Returns `(user, isNew)` — isNew is true when the profile was just created.
  Future<({User user, bool isNew})> _getOrCreateSsoProfile(
      fb.User fbUser) async {
    // 1. Check by Firebase UID (returning user)
    final existing = await _userRepo.findById(fbUser.uid);
    if (existing != null) return (user: existing, isNew: false);

    // 2. Check by email — user may have registered with email/password before
    if (fbUser.email != null && fbUser.email!.isNotEmpty) {
      final byEmail = await _userRepo.findByEmail(fbUser.email!);
      if (byEmail != null) return (user: byEmail, isNew: false);
    }

    final base = _generateUsername(
        fbUser.displayName, fbUser.email ?? fbUser.uid.substring(0, 8));
    final username = await _uniqueUsername(base);
    final now = DateTime.now().toUtc();

    final user = User(
      id: fbUser.uid,
      fullName: fbUser.displayName ?? username,
      username: username,
      email: fbUser.email ?? '',
      website: null,
      passwordHash: '',
      cashBalance: AppConstants.startingCash,
      xp: 0,
      level: 1,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: null,
    );

    await _userRepo.insert(user);
    return (user: user, isNew: true);
  }

  // ── Profile completion (SSO new users) ────────────────────────────────────

  Future<bool> isUsernameTaken(String username,
      {required String excludingUserId}) async {
    final existing = await _userRepo.findByUsername(username);
    if (existing == null) return false;
    return existing.id != excludingUserId;
  }

  Future<AuthResult> completeProfile({
    required String userId,
    required String username,
    String? website,
  }) async {
    final trimmed = username.trim().toLowerCase();
    if (await isUsernameTaken(trimmed, excludingUserId: userId)) {
      return const AuthResult(
          success: false, error: 'That username is already taken.');
    }
    await _userRepo.updateUsername(userId, trimmed);
    await _userRepo.updateWebsite(userId, website);
    final user = await _userRepo.findById(userId);
    return AuthResult(success: true, user: user);
  }

  String _generateUsername(String? displayName, String email) {
    String base;
    if (displayName != null && displayName.trim().isNotEmpty) {
      base = displayName
          .toLowerCase()
          .replaceAll(' ', '')
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
    } else {
      base = email
          .split('@')
          .first
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
    }
    final trimmed = base.isEmpty ? 'user' : base;
    return trimmed.substring(0, trimmed.length.clamp(0, 20));
  }

  Future<String> _uniqueUsername(String base) async {
    if (!await _userRepo.usernameExists(base)) return base;
    for (int i = 2; i <= 999; i++) {
      final candidate = '$base$i';
      if (!await _userRepo.usernameExists(candidate)) return candidate;
    }
    return '${base}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Daily login XP — uses UTC/Greenwich time, resets at midnight UTC.
  Future<User> _awardDailyLoginXp(User user) async {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final lastLogin = user.lastLoginAt;

    bool shouldAward;
    if (lastLogin == null) {
      shouldAward = true;
    } else {
      final lastDay = DateTime.utc(lastLogin.toUtc().year,
          lastLogin.toUtc().month, lastLogin.toUtc().day);
      shouldAward = lastDay.isBefore(today);
    }

    if (shouldAward) {
      final newXp = user.xp + AppConstants.xpDailyLogin;
      final newLevel = XpCalculator.getLevelFromXp(newXp);
      final updated = user.copyWith(xp: newXp, level: newLevel);
      await _userRepo.update(updated);
      return updated;
    }

    return user;
  }

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'That email is already registered. Log in instead.';
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return "We couldn't log you in. Check your details and try again.";
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled yet.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
