import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive authentication service providing reactive streams
/// and methods for managing user authentication state
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers for reactive state management
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  final StreamController<bool> _verifiedController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _anonymousController =
      StreamController<bool>.broadcast();
  final StreamController<List<String>> _providersController =
      StreamController<List<String>>.broadcast();

  StreamSubscription<User?>? _authStateSubscription;
  bool _isInitialized = false;

  /// Current user state stream
  Stream<User?> get userStream => _userController.stream;

  /// Email verification status stream
  Stream<bool> get isVerifiedStream => _verifiedController.stream;

  /// Anonymous user status stream
  Stream<bool> get isAnonymousStream => _anonymousController.stream;

  /// Linked auth providers stream
  Stream<List<String>> get providersStream => _providersController.stream;

  /// Current user (synchronous access)
  User? get currentUser => _auth.currentUser;

  /// Is user authenticated
  bool get isAuthenticated => currentUser != null;

  /// Is user email verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Is user anonymous
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// Initialize the auth service and set up listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set persistence to local storage for session persistence
    try {
      await _auth.setPersistence(Persistence.LOCAL);
    } catch (e) {
      // Persistence might fail in some environments, log but continue
      debugPrint('Warning: Could not set auth persistence: $e');
    }

    // Listen to auth state changes
    _authStateSubscription =
        _auth.authStateChanges().listen(_onAuthStateChanged);

    // Emit initial state
    _onAuthStateChanged(_auth.currentUser);

    _isInitialized = true;
  }

  /// Handle auth state changes and update streams
  void _onAuthStateChanged(User? user) {
    _userController.add(user);
    _verifiedController.add(user?.emailVerified ?? false);
    _anonymousController.add(user?.isAnonymous ?? false);

    final providers =
        user?.providerData.map((info) => info.providerId).toList() ??
            <String>[];
    _providersController.add(providers);
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Send verification email immediately after sign up
      await credential.user?.sendEmailVerification();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Sign up failed: $e');
    }
  }

  /// Sign in with Google OAuth
  Future<UserCredential> signInWithGoogle() async {
    try {
      // TODO: Implement Google OAuth when properly configured
      throw const AuthException(
        AuthErrorCode.unknown,
        'Google Sign-In coming soon! Use email/password for now.',
      );
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Google sign in failed: $e');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Password reset failed: $e');
    }
  }

  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
          AuthErrorCode.userNotFound, 'No user signed in');
    }

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
          AuthErrorCode.unknown, 'Email verification failed: $e');
    }
  }

  /// Reload current user to refresh verification status
  Future<void> reloadUser() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
          AuthErrorCode.userNotFound, 'No user signed in');
    }

    try {
      // Force reload from Firebase servers
      await user.reload();

      // Get fresh user instance after reload
      final freshUser = _auth.currentUser;

      // Trigger state update with fresh user
      _onAuthStateChanged(freshUser);

      debugPrint(
          '[AuthService] User reloaded - emailVerified: ${freshUser?.emailVerified}');
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'User reload failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Sign out failed: $e');
    }
  }

  /// Link anonymous account with credential (preserve user data)
  Future<UserCredential> linkAnonymousAccount(AuthCredential credential) async {
    final user = currentUser;
    if (user == null || !user.isAnonymous) {
      throw const AuthException(
        AuthErrorCode.unknown,
        'Must be signed in anonymously to link account',
      );
    }

    try {
      final linkedCredential = await user.linkWithCredential(credential);

      // Send verification email for email/password providers
      if (credential.providerId == 'password') {
        await linkedCredential.user?.sendEmailVerification();
      }

      return linkedCredential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Account linking failed: $e');
    }
  }

  /// Require recent authentication for sensitive operations
  Future<bool> requireRecentAuth(
      {Duration maxAge = const Duration(minutes: 5)}) async {
    final user = currentUser;
    if (user == null) return false;

    final lastSignInTime = user.metadata.lastSignInTime;
    if (lastSignInTime == null) return false;

    final timeSinceLastAuth = DateTime.now().difference(lastSignInTime);
    return timeSinceLastAuth <= maxAge;
  }

  /// Reauthenticate user with email and password
  Future<void> reauthenticateWithEmail(String email, String password) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
          AuthErrorCode.userNotFound, 'No user signed in');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Reauthentication failed: $e');
    }
  }

  /// Update user email (requires recent auth)
  Future<void> updateEmail(String newEmail) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
          AuthErrorCode.userNotFound, 'No user signed in');
    }

    if (!await requireRecentAuth()) {
      throw const AuthException(
        AuthErrorCode.requiresRecentLogin,
        'Please sign in again to update email',
      );
    }

    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Email update failed: $e');
    }
  }

  /// Update user password (requires recent auth)
  Future<void> updatePassword(String newPassword) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
          AuthErrorCode.userNotFound, 'No user signed in');
    }

    if (!await requireRecentAuth()) {
      throw const AuthException(
        AuthErrorCode.requiresRecentLogin,
        'Please sign in again to update password',
      );
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Password update failed: $e');
    }
  }

  /// Delete user account (requires recent auth)
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException(
          AuthErrorCode.userNotFound, 'No user signed in');
    }

    if (!await requireRecentAuth()) {
      throw const AuthException(
        AuthErrorCode.requiresRecentLogin,
        'Please sign in again to delete account',
      );
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(AuthErrorCode.unknown, 'Account deletion failed: $e');
    }
  }

  /// Map Firebase auth exceptions to custom auth exceptions
  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException(
            AuthErrorCode.userNotFound, 'No account found with this email');
      case 'wrong-password':
        return const AuthException(
            AuthErrorCode.wrongPassword, 'Incorrect password');
      case 'email-already-in-use':
        return const AuthException(
            AuthErrorCode.emailAlreadyInUse, 'Email is already registered');
      case 'weak-password':
        return const AuthException(AuthErrorCode.weakPassword,
            'Password should be at least 6 characters');
      case 'invalid-email':
        return const AuthException(
            AuthErrorCode.invalidEmail, 'Please enter a valid email address');
      case 'user-disabled':
        return const AuthException(
            AuthErrorCode.userDisabled, 'This account has been disabled');
      case 'network-request-failed':
        return const AuthException(AuthErrorCode.networkError,
            'Network error. Please check your connection');
      case 'requires-recent-login':
        return const AuthException(AuthErrorCode.requiresRecentLogin,
            'Please sign in again to continue');
      case 'credential-already-in-use':
        return const AuthException(AuthErrorCode.credentialAlreadyInUse,
            'This account is already linked');
      case 'provider-already-linked':
        return const AuthException(AuthErrorCode.providerAlreadyLinked,
            'This provider is already linked');
      default:
        return AuthException(
            AuthErrorCode.unknown, e.message ?? 'Authentication failed');
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength (min 8 chars, uppercase, number)
  bool isValidPassword(String password) {
    if (password.length < 8) return false;

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return hasUppercase && hasNumber;
  }

  /// Get password validation error message
  String? getPasswordError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Clean up resources
  void dispose() {
    _authStateSubscription?.cancel();
    _userController.close();
    _verifiedController.close();
    _anonymousController.close();
    _providersController.close();
    _isInitialized = false;
  }
}

/// Custom auth exception with typed error codes
class AuthException implements Exception {
  final AuthErrorCode code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Auth error codes for typed error handling
enum AuthErrorCode {
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  userDisabled,
  networkError,
  requiresRecentLogin,
  credentialAlreadyInUse,
  providerAlreadyLinked,
  unknown,
}
