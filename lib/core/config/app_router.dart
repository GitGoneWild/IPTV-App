import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/live_tv/screens/live_tv_screen.dart';
import '../../features/movies/screens/movie_detail_screen.dart';
import '../../features/movies/screens/movies_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/setup_screen.dart';
import '../../features/parental/screens/parental_screen.dart';
import '../../features/player/screens/player_screen.dart';
import '../../features/profiles/screens/profiles_screen.dart';
import '../../features/series/screens/series_detail_screen.dart';
import '../../features/series/screens/series_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../widgets/main_shell.dart';

/// App route names
abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String setup = '/setup';
  static const String home = '/home';
  static const String liveTV = '/live-tv';
  static const String movies = '/movies';
  static const String movieDetail = '/movies/:id';
  static const String series = '/series';
  static const String seriesDetail = '/series/:id';
  static const String player = '/player';
  static const String settings = '/settings';
  static const String profiles = '/settings/profiles';
  static const String parental = '/settings/parental';
}

/// App router configuration using GoRouter
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static GoRouter router({required bool isFirstLaunch}) => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation:
            isFirstLaunch ? AppRoutes.onboarding : AppRoutes.splash,
        debugLogDiagnostics: true,
        routes: [
          // Splash screen
          GoRoute(
            path: AppRoutes.splash,
            builder: (context, state) => const SplashScreen(),
          ),

          // Onboarding
          GoRoute(
            path: AppRoutes.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),

          // Setup
          GoRoute(
            path: AppRoutes.setup,
            builder: (context, state) {
              final type = state.uri.queryParameters['type'] ?? 'm3u';
              return SetupScreen(type: type);
            },
          ),

          // Main app shell with bottom navigation
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              // Home
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),

              // Live TV
              GoRoute(
                path: AppRoutes.liveTV,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LiveTVScreen(),
                ),
              ),

              // Movies
              GoRoute(
                path: AppRoutes.movies,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MoviesScreen(),
                ),
              ),

              // Series
              GoRoute(
                path: AppRoutes.series,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SeriesScreen(),
                ),
              ),

              // Settings
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),

          // Movie Detail (outside shell)
          GoRoute(
            path: AppRoutes.movieDetail,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return MovieDetailScreen(movieId: id);
            },
          ),

          // Series Detail (outside shell)
          GoRoute(
            path: AppRoutes.seriesDetail,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return SeriesDetailScreen(seriesId: id);
            },
          ),

          // Player (fullscreen, outside shell)
          GoRoute(
            path: AppRoutes.player,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return PlayerScreen(
                url: extra['url'] as String? ?? '',
                title: extra['title'] as String? ?? '',
                subtitle: extra['subtitle'] as String?,
                isLive: extra['isLive'] as bool? ?? false,
                channelId: extra['channelId'] as String?,
                movieId: extra['movieId'] as String?,
                episodeId: extra['episodeId'] as String?,
                position: extra['position'] as Duration?,
              );
            },
          ),

          // Profiles
          GoRoute(
            path: AppRoutes.profiles,
            builder: (context, state) => const ProfilesScreen(),
          ),

          // Parental Controls
          GoRoute(
            path: AppRoutes.parental,
            builder: (context, state) => const ParentalScreen(),
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.uri.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      );
}
