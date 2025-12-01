import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/config/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../data/models/channel_model.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/series_model.dart';

/// Home screen with Continue Watching, Favorites, Reminders, and recommendations
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChannelModel> _channels = [];
  List<MovieModel> _movies = [];
  List<SeriesModel> _series = [];
  List<ChannelModel> _favoriteChannels = [];
  List<MovieModel> _favoriteMovies = [];
  List<SeriesModel> _favoriteSeries = [];
  List<MovieModel> _continueWatching = [];
  List<ReminderModel> _upcomingReminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadData();
  }

  Future<void> _initializeServices() async {
    try {
      await ReminderService.instance.initialize();
    } catch (e) {
      debugPrint('Failed to initialize reminder service: $e');
    }
  }

  Future<void> _loadData() async {
    final storage = StorageService.instance;

    final channels = storage.getChannels();
    final movies = storage.getMovies();
    final series = storage.getSeries();

    // Get favorites
    final favChannelIds = storage.getFavoriteIds('channel');
    final favMovieIds = storage.getFavoriteIds('movie');
    final favSeriesIds = storage.getFavoriteIds('series');

    // Get watch progress
    final watchProgress = storage.getWatchProgress();

    // Get upcoming reminders
    List<ReminderModel> reminders = [];
    try {
      reminders = ReminderService.instance.getUpcomingReminders();
    } catch (e) {
      debugPrint('Failed to load reminders: $e');
    }

    setState(() {
      _channels = channels;
      _movies = movies;
      _series = series;
      _upcomingReminders = reminders;

      _favoriteChannels =
          channels.where((c) => favChannelIds.contains(c.id)).toList();
      _favoriteMovies =
          movies.where((m) => favMovieIds.contains(m.id)).toList();
      _favoriteSeries =
          series.where((s) => favSeriesIds.contains(s.id)).toList();

      // Continue watching - movies with watch progress
      _continueWatching = movies.where((m) {
        final progress = watchProgress['movie_${m.id}'];
        if (progress == null) return false;
        // Only show if progress is between 5% and 95%
        final percent = m.duration != null && m.duration! > 0
            ? progress.inMinutes / m.duration!
            : 0.0;
        return percent > 0.05 && percent < 0.95;
      }).toList();

      _isLoading = false;
    });
  }

  Future<void> _dismissReminder(ReminderModel reminder) async {
    await ReminderService.instance.removeReminder(reminder.id);
    setState(() {
      _upcomingReminders.removeWhere((r) => r.id == reminder.id);
    });
  }

  void _navigateToPlayer({
    required String url,
    required String title,
    String? subtitle,
    bool isLive = false,
    String? channelId,
    String? movieId,
  }) {
    context.push(
      AppRoutes.player,
      extra: {
        'url': url,
        'title': title,
        'subtitle': subtitle,
        'isLive': isLive,
        'channelId': channelId,
        'movieId': movieId,
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? _buildLoadingState()
            : _channels.isEmpty && _movies.isEmpty && _series.isEmpty
                ? _buildEmptyState()
                : _buildContent(),
      );

  Widget _buildLoadingState() => Shimmer.fromColors(
        baseColor: AppColors.backgroundSecondary,
        highlightColor: AppColors.backgroundTertiary,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            Container(
              height: 24,
              width: 150,
              color: AppColors.backgroundSecondary,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) => Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: AppDimensions.spacingM),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.live_tv_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            Text(
              'No content available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Add an IPTV source to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.setup),
              icon: const Icon(Icons.add),
              label: const Text('Add IPTV Source'),
            ),
          ],
        ),
      );

  Widget _buildContent() => CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(AppStrings.appName),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured content (hero banner)
                  if (_movies.isNotEmpty) _buildHeroBanner(),

                  // Upcoming Reminders
                  if (_upcomingReminders.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: AppStrings.homeUpcomingReminders,
                      icon: Icons.alarm,
                      child: _buildRemindersRow(),
                    ),
                  ],

                  // Continue Watching
                  if (_continueWatching.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: AppStrings.homeContinueWatching,
                      icon: Icons.history,
                      child: _buildContinueWatchingRow(),
                    ),
                  ],

                  // Favorite Channels
                  if (_favoriteChannels.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: '${AppStrings.homeFavorites} - Live TV',
                      icon: Icons.favorite,
                      child: _buildChannelRow(_favoriteChannels),
                    ),
                  ],

                  // Favorite Movies
                  if (_favoriteMovies.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: '${AppStrings.homeFavorites} - Movies',
                      icon: Icons.favorite,
                      child: _buildMovieRow(_favoriteMovies),
                    ),
                  ],

                  // Favorite Series
                  if (_favoriteSeries.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: '${AppStrings.homeFavorites} - Series',
                      icon: Icons.favorite,
                      child: _buildSeriesRow(_favoriteSeries),
                    ),
                  ],

                  // Recently Added Movies
                  if (_movies.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: AppStrings.homeRecentlyAdded,
                      icon: Icons.new_releases_outlined,
                      child: _buildMovieRow(_movies.take(10).toList()),
                    ),
                  ],

                  // Popular Channels
                  if (_channels.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: AppStrings.homePopular,
                      icon: Icons.trending_up,
                      child: _buildChannelRow(_channels.take(10).toList()),
                    ),
                  ],

                  // TV Series
                  if (_series.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingXXL),
                    _buildSection(
                      title: 'TV Series',
                      icon: Icons.tv,
                      child: _buildSeriesRow(_series.take(10).toList()),
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spacingXXXL),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildHeroBanner() {
    final featured = _movies.isNotEmpty ? _movies.first : null;
    if (featured == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/movies/${featured.id}'),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.3),
              AppColors.accent.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (featured.backdropUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                child: CachedNetworkImage(
                  imageUrl: featured.backdropUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.backgroundSecondary,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    featured.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Row(
                    children: [
                      if (featured.year != null) ...[
                        Text(
                          featured.yearString,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                      ],
                      if (featured.rating != null) ...[
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          featured.rating!.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: AppDimensions.paddingL,
              bottom: AppDimensions.paddingL,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.white,
                  onPressed: () {
                    if (featured.streamUrl != null) {
                      _navigateToPlayer(
                        url: featured.streamUrl!,
                        title: featured.title,
                        subtitle: featured.yearString,
                        movieId: featured.id,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          child,
        ],
      );

  Widget _buildRemindersRow() => SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _upcomingReminders.length,
          itemBuilder: (context, index) {
            final reminder = _upcomingReminders[index];
            return ReminderCard(
              channelName: reminder.channelName,
              programTitle: reminder.programTitle,
              timeUntil: reminder.formattedTimeUntilStart,
              channelLogoUrl: reminder.channelLogoUrl,
              startTime: reminder.formattedStartTime,
              onTap: () {
                // Find the channel and navigate to player
                final channel = _channels.firstWhere(
                  (c) => c.id == reminder.channelId,
                  orElse: () => ChannelModel(id: '', name: ''),
                );
                if (channel.streamUrl != null) {
                  _navigateToPlayer(
                    url: channel.streamUrl!,
                    title: channel.name,
                    isLive: true,
                    channelId: channel.id,
                  );
                }
              },
              onDismiss: () => _dismissReminder(reminder),
            );
          },
        ),
      );

  Widget _buildContinueWatchingRow() => SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _continueWatching.length,
          itemBuilder: (context, index) {
            final movie = _continueWatching[index];
            return _ContinueWatchingCard(
              movie: movie,
              onTap: () {
                if (movie.streamUrl != null) {
                  _navigateToPlayer(
                    url: movie.streamUrl!,
                    title: movie.title,
                    subtitle: movie.yearString,
                    movieId: movie.id,
                  );
                }
              },
            );
          },
        ),
      );

  Widget _buildChannelRow(List<ChannelModel> channels) => SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index];
            return _ChannelCard(
              channel: channel,
              onTap: () {
                if (channel.streamUrl != null) {
                  _navigateToPlayer(
                    url: channel.streamUrl!,
                    title: channel.name,
                    isLive: true,
                    channelId: channel.id,
                  );
                }
              },
            );
          },
        ),
      );

  Widget _buildMovieRow(List<MovieModel> movies) => SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _MovieCard(
              movie: movie,
              onTap: () => context.push('/movies/${movie.id}'),
            );
          },
        ),
      );

  Widget _buildSeriesRow(List<SeriesModel> series) => SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: series.length,
          itemBuilder: (context, index) {
            final s = series[index];
            return _SeriesCard(
              series: s,
              onTap: () => context.push('/series/${s.id}'),
            );
          },
        ),
      );
}

class _ContinueWatchingCard extends StatelessWidget {
  const _ContinueWatchingCard({
    required this.movie,
    required this.onTap,
  });

  final MovieModel movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 280,
          margin: const EdgeInsets.only(right: AppDimensions.spacingM),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusM),
                      ),
                      child: movie.backdropUrl != null
                          ? CachedNetworkImage(
                              imageUrl: movie.backdropUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.backgroundSecondary,
                                child: const Icon(
                                  Icons.movie,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.backgroundSecondary,
                              child: const Icon(
                                Icons.movie,
                                color: AppColors.textTertiary,
                              ),
                            ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Progress bar
              LinearProgressIndicator(
                value: movie.watchProgressPercent,
                backgroundColor: AppColors.backgroundTertiary,
                color: AppColors.primary,
                minHeight: 3,
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Text(
                  movie.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.channel,
    required this.onTap,
  });

  final ChannelModel channel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          margin: const EdgeInsets.only(right: AppDimensions.spacingM),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: channel.logoUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusS),
                        child: CachedNetworkImage(
                          imageUrl: channel.logoUrl!,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => const Icon(
                            Icons.live_tv,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.live_tv,
                        color: AppColors.textTertiary,
                      ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingS,
                ),
                child: Text(
                  channel.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.movie,
    required this.onTap,
  });

  final MovieModel movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    child: movie.posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: movie.posterUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Icon(
                                Icons.movie,
                                color: AppColors.textTertiary,
                                size: 40,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.backgroundSecondary,
                            child: const Icon(
                              Icons.movie,
                              color: AppColors.textTertiary,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                movie.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (movie.year != null)
                Text(
                  movie.yearString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
            ],
          ),
        ),
      );
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.series,
    required this.onTap,
  });

  final SeriesModel series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    child: series.posterUrl != null
                        ? CachedNetworkImage(
                            imageUrl: series.posterUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Icon(
                                Icons.tv,
                                color: AppColors.textTertiary,
                                size: 40,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.backgroundSecondary,
                            child: const Icon(
                              Icons.tv,
                              color: AppColors.textTertiary,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                series.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (series.totalSeasons > 0)
                Text(
                  '${series.totalSeasons} Seasons',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
            ],
          ),
        ),
      );
}
