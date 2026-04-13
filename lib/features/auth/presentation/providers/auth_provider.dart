import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../data/user_repository.dart';
import '../../domain/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool isOnboarded;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isOnboarded = false,
  });

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error, bool? isOnboarded}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthNotifier(this._authRepo, this._userRepo) : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      await _authRepo.signInWithEmail(email, password);
      final user = await _userRepo.getUser(_authRepo.userId);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isOnboarded: _authRepo.isOnboarded,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      await _authRepo.signUpWithEmail(name, email, password);
      final user = await _userRepo.createUser(_authRepo.userId, name, email);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepo.signInWithGoogle();
      final user = await _userRepo.getUser(_authRepo.userId);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authRepo.signInWithApple();
      final user = await _userRepo.getUser(_authRepo.userId);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _authRepo.sendPasswordReset(email);
  }

  Future<void> completeOnboarding(UserOnboarding onboarding) async {
    _authRepo.completeOnboarding();
    if (state.user != null) {
      final updated = state.user!.copyWith(
        onboarding: onboarding,
        updatedAt: DateTime.now(),
      );
      await _userRepo.updateUser(updated);
      state = state.copyWith(user: updated, isOnboarded: true);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    DateTime? birthDate,
  }) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        birthDate: birthDate,
        updatedAt: DateTime.now(),
      );
      await _userRepo.updateUser(updated);
      state = state.copyWith(user: updated);
    }
  }

  Future<void> updateEmail(String newEmail, String password) async {
    if (state.user != null) {
      if (newEmail.isEmpty || !newEmail.contains('@')) {
        throw Exception('Valid email is required');
      }
      if (password.length < 6) {
        throw Exception('Incorrect password');
      }
      final updated = state.user!.copyWith(
        email: newEmail,
        updatedAt: DateTime.now(),
      );
      await _userRepo.updateUser(updated);
      state = state.copyWith(user: updated);
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    if (currentPassword.length < 6) {
      throw Exception('Current password is incorrect');
    }
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters');
    }
    // In production, this would call Firebase Auth reauthenticate + updatePassword
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> updateSettings(UserSettings settings) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(settings: settings, updatedAt: DateTime.now());
      await _userRepo.updateUser(updated);
      state = state.copyWith(user: updated);
    }
  }

  Future<void> updateStats(UserStats stats) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(stats: stats, updatedAt: DateTime.now());
      await _userRepo.updateUser(updated);
      state = state.copyWith(user: updated);
    }
  }

  Future<void> updateGamification(UserGamification gamification) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(gamification: gamification, updatedAt: DateTime.now());
      await _userRepo.updateUser(updated);
      state = state.copyWith(user: updated);
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isOnboardedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isOnboarded;
});
