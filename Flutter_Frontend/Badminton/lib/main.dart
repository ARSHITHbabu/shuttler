import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'routes/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/service_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'widgets/common/offline_indicator.dart';
import 'widgets/common/app_logo.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // Create router once and reuse it to preserve navigation state
  late final router = AppRouter.createRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkJailbreak();
    });
  }

  Future<void> _checkJailbreak() async {
    try {
      final bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      final bool developerMode = await FlutterJailbreakDetection.developerMode;
      if (jailbroken || developerMode) {
        final context = router.routerDelegate.navigatorKey.currentContext;
        if (context == null) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text(
                'Security Warning', 
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
              ),
              content: const Text(
                'Your device appears to be rooted or jailbroken. For your security, please be aware that using this application on a compromised device may put your data at risk.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('I Understand'),
                ),
              ],
            );
          },
        );
      }
    } on PlatformException {
      debugPrint('Failed to get jailbreak status.');
    } catch (e) {
      debugPrint('Error checking jailbreak status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);

    return OfflineIndicator(
      child: MaterialApp.router(
        title: 'Pursue Badminton',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}

/// Temporary placeholder screen until we build authentication screens
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(
              height: 120,
            ),
            const SizedBox(height: 24),
            Text(
              'Pursue Badminton',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Management System',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 48),
            Text(
              'Phase 1: Foundation Complete ✅',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Next: Authentication Screens',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
