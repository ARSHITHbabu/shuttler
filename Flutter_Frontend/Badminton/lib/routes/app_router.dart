import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/student/profile_completion_screen.dart';
import '../screens/student/pending_approval_screen.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/owner/academy_setup_screen.dart';
import '../screens/owner/owner_dashboard.dart';
import '../screens/owner/notifications_screen.dart';
import '../screens/coach/coach_dashboard.dart';

/// App routing configuration with go_router
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        // Root route - Role Selection
        GoRoute(
          path: '/',
          name: 'role-selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),

        // Login route
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            final userType = state.extra as String? ?? 'student';
            return LoginScreen(userType: userType);
          },
        ),

        // Signup route - supports invitation token via query params
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) {
            final userType =
                state.extra as String? ??
                (state.uri.queryParameters['userType'] ?? 'student');
            final invitationToken = state.uri.queryParameters['token'];
            return SignupScreen(
              userType: userType,
              invitationToken: invitationToken,
            );
          },
        ),

        // Invite route handler - redirects to signup with token
        GoRoute(
          path: '/invite/:token',
          name: 'invite-student',
          builder: (context, state) {
            final token = state.pathParameters['token']!;
            return SignupScreen(userType: 'student', invitationToken: token);
          },
        ),

        // Coach invite route handler
        GoRoute(
          path: '/invite/coach/:token',
          name: 'invite-coach',
          builder: (context, state) {
            final token = state.pathParameters['token']!;
            return SignupScreen(userType: 'coach', invitationToken: token);
          },
        ),

        // Forgot Password route
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) {
            final userType = state.extra as String? ?? 'student';
            return ForgotPasswordScreen(userType: userType);
          },
        ),

        // Owner Dashboard route
        GoRoute(
          path: '/owner-dashboard',
          name: 'owner-dashboard',
          builder: (context, state) => const OwnerDashboard(),
        ),

        // Coach Dashboard route
        GoRoute(
          path: '/coach-dashboard',
          name: 'coach-dashboard',
          builder: (context, state) => const CoachDashboard(),
        ),

        // Student Profile Completion route
        GoRoute(
          path: '/student-profile-complete',
          name: 'student-profile-complete',
          builder: (context, state) => const ProfileCompletionScreen(),
        ),

        // Student Pending Approval route
        GoRoute(
          path: '/student-pending',
          name: 'student-pending',
          builder: (context, state) => const PendingApprovalScreen(),
        ),

        // Student Dashboard route
        GoRoute(
          path: '/student-dashboard',
          name: 'student-dashboard',
          builder: (context, state) => const StudentDashboard(),
        ),

        // Academy Setup route
        GoRoute(
          path: '/academy-setup',
          name: 'academy-setup',
          builder: (context, state) => const AcademySetupScreen(),
        ),

        // Notifications route
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],

      // Error page
      errorBuilder: (context, state) => Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFf44336),
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFFe8e8e8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder dashboard screen for testing navigation
class PlaceholderDashboard extends StatelessWidget {
  final String role;
  final IconData icon;

  const PlaceholderDashboard({
    super.key,
    required this.role,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242424),
        title: Text(
          '$role Dashboard',
          style: const TextStyle(color: Color(0xFFe8e8e8)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFe8e8e8)),
            onPressed: () {
              // Logout and go back to role selection
              context.go('/');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color(0xFF4a9eff)),
            const SizedBox(height: 24),
            Text(
              'Welcome to $role Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFFe8e8e8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Phase 2: Authentication Complete!',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: const Color(0xFF4caf50)),
            ),
            const SizedBox(height: 8),
            Text(
              'Dashboard features coming in Phase 3',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF888888)),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4a9eff),
                foregroundColor: const Color(0xFFe8e8e8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
