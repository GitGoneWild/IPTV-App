import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

/// Global error handler for uncaught exceptions
void _handleFlutterError(FlutterErrorDetails details) {
  // Log error in debug mode
  if (kDebugMode) {
    FlutterError.dumpErrorToConsole(details);
  }

  // In production, you can send to crash reporting service
  // Example: Sentry.captureException(details.exception, stackTrace: details.stack);
}

/// Global error handler for async errors
void _handleAsyncError(Object error, StackTrace stack) {
  if (kDebugMode) {
    debugPrint('Uncaught async error: $error');
    debugPrint('Stack trace: $stack');
  }
}

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling
  FlutterError.onError = _handleFlutterError;

  // Handle async errors
  runZonedGuarded(
    () => runApp(const WatchTheFlixApp()),
    _handleAsyncError,
  );
}

