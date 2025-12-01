import 'package:flutter/material.dart';

import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_service.dart';
import 'core/services/storage_service.dart';

/// Main application widget
class WatchTheFlixApp extends StatefulWidget {
  const WatchTheFlixApp({super.key});

  @override
  State<WatchTheFlixApp> createState() => _WatchTheFlixAppState();
}

class _WatchTheFlixAppState extends State<WatchTheFlixApp> {
  bool _isInitialized = false;
  bool _isFirstLaunch = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize storage
      await StorageService.instance.initialize();

      // Initialize notifications
      await NotificationService.instance.initialize();

      // Initialize reminders
      await ReminderService.instance.initialize();

      // Check if first launch
      _isFirstLaunch = StorageService.instance.isFirstLaunch;

      setState(() => _isInitialized = true);
    } catch (e) {
      // Handle initialization error
      debugPrint('Initialization error: $e');
      setState(() {
        _isInitialized = true;
        _initError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show loading screen while initializing
      return MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading WatchTheFlix...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error state if initialization failed critically
    if (_initError != null) {
      return MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _initError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isInitialized = false;
                        _initError = null;
                      });
                      _initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router(isFirstLaunch: _isFirstLaunch),
    );
  }
}
