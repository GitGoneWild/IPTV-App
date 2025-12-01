import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// A reusable custom card widget for content grids
/// Supports poster cards (movies/series) and thumbnail cards (channels)
class CustomCard extends StatelessWidget {
  const CustomCard({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.overlay,
    this.aspectRatio = 2 / 3,
    this.showGradient = true,
    this.borderRadius = AppDimensions.radiusM,
    this.elevation = 0,
    super.key,
  });

  /// Card title
  final String title;

  /// Optional subtitle
  final String? subtitle;

  /// Image URL for the card
  final String? imageUrl;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long pressed
  final VoidCallback? onLongPress;

  /// Optional trailing widget (e.g., favorite icon)
  final Widget? trailing;

  /// Optional overlay widget (e.g., progress indicator, live badge)
  final Widget? overlay;

  /// Aspect ratio for the card image (default: 2/3 for posters)
  final double aspectRatio;

  /// Whether to show gradient overlay for text visibility
  final bool showGradient;

  /// Border radius for the card
  final double borderRadius;

  /// Card elevation
  final double elevation;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    _buildImage(),

                    // Gradient overlay for text visibility
                    if (showGradient)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.background.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Custom overlay
                    if (overlay != null) overlay!,

                    // Trailing widget (e.g., favorite button)
                    if (trailing != null)
                      Positioned(
                        top: AppDimensions.paddingS,
                        right: AppDimensions.paddingS,
                        child: trailing!,
                      ),
                  ],
                ),
              ),

              // Title section
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                color: AppColors.cardBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() => Container(
        color: AppColors.backgroundSecondary,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textTertiary,
            size: 40,
          ),
        ),
      );
}

/// A specialized poster card for movies and series
class PosterCard extends StatelessWidget {
  const PosterCard({
    required this.title,
    this.posterUrl,
    this.year,
    this.rating,
    this.isFavorite = false,
    this.watchProgress,
    this.onTap,
    this.onFavoriteTap,
    super.key,
  });

  final String title;
  final String? posterUrl;
  final int? year;
  final double? rating;
  final bool isFavorite;
  final double? watchProgress;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) => CustomCard(
        title: title,
        subtitle: year?.toString(),
        imageUrl: posterUrl,
        onTap: onTap,
        aspectRatio: 2 / 3,
        trailing: onFavoriteTap != null
            ? GestureDetector(
                onTap: onFavoriteTap,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              )
            : null,
        overlay: _buildOverlay(context),
      );

  Widget? _buildOverlay(BuildContext context) {
    final overlays = <Widget>[];

    // Rating badge
    if (rating != null) {
      overlays.add(
        Positioned(
          top: AppDimensions.paddingS,
          left: AppDimensions.paddingS,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.warning, size: 14),
                const SizedBox(width: 2),
                Text(
                  rating!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Watch progress indicator
    if (watchProgress != null && watchProgress! > 0) {
      overlays.add(
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            value: watchProgress,
            backgroundColor: AppColors.backgroundTertiary,
            color: AppColors.primary,
            minHeight: 3,
          ),
        ),
      );
    }

    if (overlays.isEmpty) return null;
    return Stack(children: overlays);
  }
}

/// A specialized channel card for live TV
class ChannelCard extends StatelessWidget {
  const ChannelCard({
    required this.name,
    this.logoUrl,
    this.currentProgram,
    this.progress,
    this.isLive = true,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    super.key,
  });

  final String name;
  final String? logoUrl;
  final String? currentProgram;
  final double? progress;
  final bool isLive;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Card(
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      child: logoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: logoUrl!,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.live_tv,
                                color: AppColors.textTertiary,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.live_tv,
                                color: AppColors.textTertiary,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Name
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                // Current program
                if (currentProgram != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    currentProgram!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],

                // Progress bar
                if (progress != null) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.backgroundTertiary,
                      color: AppColors.primary,
                      minHeight: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

/// A horizontal reminder card for the home screen
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    required this.channelName,
    required this.programTitle,
    required this.timeUntil,
    this.channelLogoUrl,
    this.startTime,
    this.onTap,
    this.onDismiss,
    super.key,
  });

  final String channelName;
  final String programTitle;
  final String timeUntil;
  final String? channelLogoUrl;
  final String? startTime;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 220,
          margin: const EdgeInsets.only(right: AppDimensions.spacingM),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  children: [
                    // Channel logo
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: channelLogoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: channelLogoUrl!,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.live_tv,
                                  color: AppColors.textTertiary,
                                  size: 18,
                                ),
                              )
                            : const Icon(
                                Icons.live_tv,
                                color: AppColors.textTertiary,
                                size: 18,
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        channelName,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onDismiss != null)
                      GestureDetector(
                        onTap: onDismiss,
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Program title
                Text(
                  programTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Time info row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeUntil,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    if (startTime != null) ...[
                      const Spacer(),
                      Text(
                        startTime!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
