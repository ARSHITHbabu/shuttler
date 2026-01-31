import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'service_providers.dart';

part 'auth_provider.g.dart';

/// Authentication state sealed class
sealed class AuthState {
  const AuthState();
}

/// User is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// User is authenticated
class Authenticated extends AuthState {
  final String userType;
  final int userId;
  final String userName;
  final String userEmail;

  const Authenticated({
    required this.userType,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  String toString() {
    return 'Authenticated(userType: $userType, userId: $userId, userName: $userName, userEmail: $userEmail)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Authenticated &&
        other.userType == userType &&
        other.userId == userId &&
        other.userName == userName &&
        other.userEmail == userEmail;
  }

  @override
  int get hashCode {
    return Object.hash(userType, userId, userName, userEmail);
  }
}

/// Authentication provider with code generation
/// Keep alive to maintain auth state across navigation
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    // Keep provider alive to maintain state
    ref.keepAlive();
    
    // Ensure storage is initialized before checking
    final storageService = ref.read(storageServiceProvider);
    if (!storageService.isInitialized) {
      await storageService.init();
    }
    
    // Check if user is already logged in on app start
    final authService = ref.read(authServiceProvider);

    if (authService.isLoggedIn()) {
      // Load user data from storage
      final userType = authService.getCurrentUserType();
      final userId = authService.getCurrentUserId();
      final userName = authService.getCurrentUserName();
      final userEmail = authService.getCurrentUserEmail();

      if (userType != null &&
          userId != null &&
          userName != null &&
          userEmail != null) {
        return Authenticated(
          userType: userType,
          userId: userId,
          userName: userName,
          userEmail: userEmail,
        );
      }
    }

    return const Unauthenticated();
  }

  /// Login with email and password
  /// Returns the full result including profile_complete for students
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
    bool rememberMe = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);

      final result = await authService.login(
        email: email,
        password: password,
        userType: userType,
        rememberMe: rememberMe,
      );

      final user = result['user'];

      state = AsyncValue.data(
        Authenticated(
          userType: userType,
          userId: user['id'] as int,
          userName: user['name'] as String,
          userEmail: user['email'] as String,
        ),
      );
      
      // Return the full result including profile_complete
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Rethrow to allow UI to handle the error
      rethrow;
    }
  }

  /// Register new user
  /// Returns the full result for profile completeness check
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
    Map<String, dynamic>? additionalData,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);

      final result = await authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        userType: userType,
        additionalData: additionalData,
      );

      final user = result['user'];

      // Auto-login after successful registration
      state = AsyncValue.data(
        Authenticated(
          userType: userType,
          userId: user['id'] as int,
          userName: user['name'] as String,
          userEmail: user['email'] as String,
        ),
      );
      
      // Return the full result
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      // Rethrow to allow UI to handle the error
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();
      state = const AsyncValue.data(Unauthenticated());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      final authService = ref.read(authServiceProvider);
      final userData = await authService.refreshUserData();

      // Update state with fresh data
      final currentState = state.value;
      if (currentState is Authenticated) {
        state = AsyncValue.data(
          Authenticated(
            userType: currentState.userType,
            userId: userData['id'] as int,
            userName: userData['name'] as String,
            userEmail: userData['email'] as String,
          ),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Check if token is valid
  Future<bool> validateToken() async {
    try {
      final authService = ref.read(authServiceProvider);
      return await authService.validateToken();
    } catch (e) {
      return false;
    }
  }
}
