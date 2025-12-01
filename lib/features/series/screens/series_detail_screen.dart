import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/series_model.dart';

/// Series detail screen
class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({required this.seriesId, super.key});

  final String seriesId;

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  SeriesModel? _series;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _selectedSeason = 0;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    final storage = StorageService.instance;
    final seriesList = storage.getSeries();
    final series = seriesList.firstWhere(
      (s) => s.id == widget.seriesId,
      orElse: () => const SeriesModel(id: '', title: ''),
    );

    setState(() {
      _series = series.id.isNotEmpty ? series : null;
      _isFavorite = storage.isFavorite('series', widget.seriesId);
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final storage = StorageService.instance;
    if (_isFavorite) {
      await storage.removeFavorite('series', widget.seriesId);
    } else {
      await storage.addFavorite('series', widget.seriesId);
    }
    setState(() => _isFavorite = !_isFavorite);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playEpisode(EpisodeModel episode) {
    if (episode.streamUrl == null) return;

    context.push(
      AppRoutes.player,
      extra: {
        'url': episode.streamUrl,
        'title': _series!.title,
        'subtitle': 'S${_selectedSeason + 1} E${episode.episodeNumber} - ${episode.displayTitle}',
        'episodeId': episode.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_series == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Series not found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with backdrop
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_series!.backdropUrl != null)
                    CachedNetworkImage(
                      imageUrl: _series!.backdropUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.backgroundSecondary,
                      ),
                    )
                  else
                    Container(color: AppColors.backgroundSecondary),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                          AppColors.background,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.error : null,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and metadata row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusS),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusS),
                          child: _series!.posterUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _series!.posterUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.backgroundSecondary,
                                  child: const Icon(
                                    Icons.tv,
                                    size: 40,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingL),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _series!.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppDimensions.spacingS),

                            // Metadata chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (_series!.year != null)
                                  _buildMetadataChip(
                                    icon: Icons.calendar_today,
                                    text: _series!.year.toString(),
                                  ),
                                if (_series!.rating != null)
                                  _buildMetadataChip(
                                    icon: Icons.star,
                                    text: _series!.rating!.toStringAsFixed(1),
                                    iconColor: AppColors.warning,
                                  ),
                                if (_series!.totalSeasons > 0)
                                  _buildMetadataChip(
                                    icon: Icons.folder,
                                    text: '${_series!.totalSeasons} Seasons',
                                  ),
                                if (_series!.totalEpisodes > 0)
                                  _buildMetadataChip(
                                    icon: Icons.video_library,
                                    text: '${_series!.totalEpisodes} Episodes',
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacingL),

                            // Genres
                            if (_series!.genres != null &&
                                _series!.genres!.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _series!.genres!
                                    .map(
                                      (genre) => Chip(
                                        label: Text(
                                          genre,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor:
                                            AppColors.backgroundTertiary,
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Plot
                  if (_series!.plot != null && _series!.plot!.isNotEmpty) ...[
                    Text(
                      'Synopsis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      _series!.plot!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXXL),
                  ],

                  // Cast
                  if (_series!.cast != null && _series!.cast!.isNotEmpty) ...[
                    Text(
                      'Cast',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _series!.cast!
                          .map(
                            (actor) => Chip(
                              avatar: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  actor.isNotEmpty ? actor[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              label: Text(
                                actor,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: AppColors.backgroundSecondary,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: AppDimensions.spacingXXL),
                  ],

                  // Seasons and Episodes
                  if (_series!.seasons != null &&
                      _series!.seasons!.isNotEmpty) ...[
                    Text(
                      AppStrings.seriesSeasons,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),

                    // Season tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          _series!.seasons!.length,
                          (index) {
                            final season = _series!.seasons![index];
                            final isSelected = _selectedSeason == index;
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppDimensions.spacingS,
                              ),
                              child: ChoiceChip(
                                selected: isSelected,
                                label: Text(season.displayName),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedSeason = index);
                                  }
                                },
                                backgroundColor: AppColors.backgroundTertiary,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingL),

                    // Episode list
                    _buildEpisodeList(),
                  ],

                  const SizedBox(height: AppDimensions.spacingXXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    Color iconColor = AppColors.textSecondary,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      );

  Widget _buildEpisodeList() {
    if (_series?.seasons == null ||
        _series!.seasons!.isEmpty ||
        _selectedSeason >= _series!.seasons!.length) {
      return const SizedBox.shrink();
    }

    final season = _series!.seasons![_selectedSeason];
    final episodes = season.episodes ?? [];

    if (episodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Text(
            'No episodes available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        return _EpisodeListTile(
          episode: episode,
          seasonNumber: season.seasonNumber,
          onTap: () => _playEpisode(episode),
        );
      },
    );
  }
}

class _EpisodeListTile extends StatelessWidget {
  const _EpisodeListTile({
    required this.episode,
    required this.seasonNumber,
    required this.onTap,
  });

  final EpisodeModel episode;
  final int seasonNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
        color: AppColors.cardBackground,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 120,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusS),
                        child: episode.posterUrl != null
                            ? CachedNetworkImage(
                                imageUrl: episode.posterUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.backgroundSecondary,
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: AppColors.textTertiary,
                                  size: 32,
                                ),
                              ),
                      ),
                      // Duration badge
                      if (episode.duration != null)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              episode.durationString,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      // Play icon overlay
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'S$seasonNumber E${episode.episodeNumber}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        episode.displayTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (episode.plot != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          episode.plot!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Watch progress
                      if (episode.watchProgressPercent > 0) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: episode.watchProgressPercent,
                            backgroundColor: AppColors.backgroundTertiary,
                            color: AppColors.primary,
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
