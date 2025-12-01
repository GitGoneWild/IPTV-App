import 'package:flutter/material.dart';

import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
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

      // Check if first launch
      _isFirstLaunch = StorageService.instance.isFirstLaunch;

      setState(() => _isInitialized = true);
    } catch (e) {
      // Handle initialization error
      debugPrint('Initialization error: $e');
      setState(() => _isInitialized = true);
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
            child: CircularProgressIndicator(),
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
