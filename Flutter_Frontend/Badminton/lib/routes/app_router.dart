import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/student/profile_completion_screen.dart';
import '../screens/owner/owner_dashboard.dart';

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

        // Signup route
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) {
            final userType = state.extra as String? ?? 'student';
            return SignupScreen(userType: userType);
          },
        ),

        // Owner Dashboard route
        GoRoute(
          path: '/owner-dashboard',
          name: 'owner-dashboard',
          builder: (context, state) => const OwnerDashboard(),
        ),

        // Coach Dashboard route (placeholder)
        GoRoute(
          path: '/coach-dashboard',
          name: 'coach-dashboard',
          builder: (context, state) => const PlaceholderDashboard(
            role: 'Coach',
            icon: Icons.person_outline,
          ),
        ),

        // Student Profile Completion route
        GoRoute(
          path: '/student-profile-complete',
          name: 'student-profile-complete',
          builder: (context, state) => const ProfileCompletionScreen(),
        ),

        // Student Dashboard route (placeholder)
        GoRoute(
          path: '/student-dashboard',
          name: 'student-dashboard',
          builder: (context, state) => const PlaceholderDashboard(
            role: 'Student',
            icon: Icons.school_outlined,
          ),
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
            Icon(
              icon,
              size: 80,
              color: const Color(0xFF4a9eff),
            ),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF4caf50),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dashboard features coming in Phase 3',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF888888),
                  ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4a9eff),
                foregroundColor: const Color(0xFFe8e8e8),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
