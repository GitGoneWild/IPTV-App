import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/series_model.dart';

/// Series screen with poster grid
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<SeriesModel> _series = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = StorageService.instance;

    final series = storage.getSeries();
    final categories = storage.getCategories();

    // Filter series categories only
    final seriesCategories =
        categories.where((c) => c.type == CategoryType.series).toList();

    setState(() {
      _series = series;
      _categories = seriesCategories;
      _isLoading = false;
    });
  }

  List<SeriesModel> get _filteredSeries {
    var series = _series;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != 'favorites') {
      series = series.where((s) => s.category == _selectedCategory).toList();
    }

    // Filter favorites
    if (_selectedCategory == 'favorites') {
      final storage = StorageService.instance;
      final favIds = storage.getFavoriteIds('series');
      series = series.where((s) => favIds.contains(s.id)).toList();
    }

    return series;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.navSeries),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _SeriesSearchDelegate(
                    series: _series,
                    onSelect: (s) => context.push('/series/${s.id}'),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _series.isEmpty
                ? _buildEmptyState()
                : _buildContent(),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            Text(
              'No series available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Add an IPTV source with series content',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );

  Widget _buildContent() => Column(
        children: [
          // Category tabs
          if (_categories.isNotEmpty)
            Container(
              color: AppColors.backgroundSecondary,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingS,
                ),
                child: Row(
                  children: [
                    _buildCategoryChip(null, AppStrings.seriesAll),
                    _buildCategoryChip('favorites', AppStrings.seriesFavorites),
                    ..._categories.map(
                      (c) => _buildCategoryChip(c.id, c.name),
                    ),
                  ],
                ),
              ),
            ),

          // Series grid
          Expanded(
            child: _buildSeriesGrid(_filteredSeries),
          ),
        ],
      );

  Widget _buildCategoryChip(String? categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingS),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? categoryId : null;
          });
        },
        backgroundColor: AppColors.backgroundTertiary,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildSeriesGrid(List<SeriesModel> series) {
    if (series.isEmpty) {
      return Center(
        child: Text(
          'No series in this category',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 6
            : constraints.maxWidth > 600
                ? 4
                : 3;

        return GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.6,
            crossAxisSpacing: AppDimensions.spacingM,
            mainAxisSpacing: AppDimensions.spacingM,
          ),
          itemCount: series.length,
          itemBuilder: (context, index) {
            final s = series[index];
            return _SeriesCard(
              series: s,
              onTap: () => context.push('/series/${s.id}'),
            );
          },
        );
      },
    );
  }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusS),
                      child: series.posterUrl != null
                          ? CachedNetworkImage(
                              imageUrl: series.posterUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.backgroundSecondary,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
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
                    // Rating badge
                    if (series.rating != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.warning,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                series.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Seasons badge
                    if (series.totalSeasons > 0)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${series.totalSeasons} Seasons',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (series.year != null)
              Text(
                series.year.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
              ),
          ],
        ),
      );
}

class _SeriesSearchDelegate extends SearchDelegate<SeriesModel?> {
  _SeriesSearchDelegate({
    required this.series,
    required this.onSelect,
  });

  final List<SeriesModel> series;
  final void Function(SeriesModel) onSelect;

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundSecondary,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.textSecondary),
          border: InputBorder.none,
        ),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = series
        .where((s) => s.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final s = results[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: s.posterUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: s.posterUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.tv, color: AppColors.textTertiary),
          ),
          title: Text(
            s.title,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: s.totalSeasons > 0
              ? Text(
                  '${s.totalSeasons} Seasons',
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              : null,
          onTap: () {
            close(context, s);
            onSelect(s);
          },
        );
      },
    );
  }
}
