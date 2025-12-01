import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/movie_model.dart';

/// Movie detail screen
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({required this.movieId, super.key});

  final String movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  MovieModel? _movie;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    final storage = StorageService.instance;
    final movies = storage.getMovies();
    final movie = movies.firstWhere(
      (m) => m.id == widget.movieId,
      orElse: () => const MovieModel(id: '', title: ''),
    );

    setState(() {
      _movie = movie.id.isNotEmpty ? movie : null;
      _isFavorite = storage.isFavorite('movie', widget.movieId);
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final storage = StorageService.instance;
    if (_isFavorite) {
      await storage.removeFavorite('movie', widget.movieId);
    } else {
      await storage.addFavorite('movie', widget.movieId);
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

  void _playMovie() {
    if (_movie?.streamUrl == null) return;

    context.push(
      AppRoutes.player,
      extra: {
        'url': _movie!.streamUrl,
        'title': _movie!.title,
        'subtitle': _movie!.yearString,
        'movieId': _movie!.id,
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

    if (_movie == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Movie not found',
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
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_movie!.backdropUrl != null)
                    CachedNetworkImage(
                      imageUrl: _movie!.backdropUrl!,
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
                        width: 120,
                        height: 180,
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
                          child: _movie!.posterUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _movie!.posterUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.backgroundSecondary,
                                  child: const Icon(
                                    Icons.movie,
                                    size: 48,
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
                              _movie!.title,
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
                                if (_movie!.year != null)
                                  _buildMetadataChip(
                                    icon: Icons.calendar_today,
                                    text: _movie!.yearString,
                                  ),
                                if (_movie!.rating != null)
                                  _buildMetadataChip(
                                    icon: Icons.star,
                                    text: _movie!.rating!.toStringAsFixed(1),
                                    iconColor: AppColors.warning,
                                  ),
                                if (_movie!.duration != null)
                                  _buildMetadataChip(
                                    icon: Icons.access_time,
                                    text: _movie!.durationString,
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spacingL),

                            // Genres
                            if (_movie!.genres != null &&
                                _movie!.genres!.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _movie!.genres!
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

                  // Play button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _movie!.streamUrl != null ? _playMovie : null,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        _movie!.watchProgressPercent > 0
                            ? 'Continue Watching'
                            : 'Play Movie',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  // Watch progress
                  if (_movie!.watchProgressPercent > 0) ...[
                    const SizedBox(height: AppDimensions.spacingS),
                    LinearProgressIndicator(
                      value: _movie!.watchProgressPercent,
                      backgroundColor: AppColors.backgroundTertiary,
                      color: AppColors.primary,
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Plot
                  if (_movie!.plot != null && _movie!.plot!.isNotEmpty) ...[
                    Text(
                      'Synopsis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      _movie!.plot!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXXL),
                  ],

                  // Director
                  if (_movie!.director != null &&
                      _movie!.director!.isNotEmpty) ...[
                    Text(
                      'Director',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      _movie!.director!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXXL),
                  ],

                  // Cast
                  if (_movie!.cast != null && _movie!.cast!.isNotEmpty) ...[
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
                      children: _movie!.cast!
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
}
