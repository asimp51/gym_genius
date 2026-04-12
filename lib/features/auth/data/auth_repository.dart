import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simulates authentication locally. Firebase will replace this later.
/// The interface (method signatures) will remain the same.
class AuthRepository {
  bool _isLoggedIn = false;
  bool _isOnboarded = false;
  String _userId = '';
  String? _orgId;
  String? _orgRole;

  bool get isLoggedIn => _isLoggedIn;
  bool get isOnboarded => _isOnboarded;
  String get userId => _userId;
  String? get orgId => _orgId;
  String? get orgRole => _orgRole;

  void setOrganization(String orgId, String role) {
    _orgId = orgId;
    _orgRole = role;
  }

  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    _isLoggedIn = true;
    _userId = 'user_${email.hashCode.abs()}';
    // Mock: if returning user, mark as onboarded
    if (email == 'demo@gymgenius.com') {
      _isOnboarded = true;
    }
  }

  Future<void> signUpWithEmail(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (name.isEmpty) {
      throw Exception('Name is required');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Valid email is required');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    _isLoggedIn = true;
    _isOnboarded = false;
    _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _isOnboarded = true;
    _userId = 'google_user';
  }

  Future<void> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _isOnboarded = true;
    _userId = 'apple_user';
  }

  Future<void> signOut() async {
    _isLoggedIn = false;
    _isOnboarded = false;
    _userId = '';
    _orgId = null;
    _orgRole = null;
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Valid email is required');
    }
    // In production, sends a reset email via Firebase Auth
  }

  void completeOnboarding() {
    _isOnboarded = true;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
