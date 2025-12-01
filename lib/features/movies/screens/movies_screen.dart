import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/movie_model.dart';

/// Movies screen with poster grid
class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List<MovieModel> _movies = [];
  List<CategoryModel> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = StorageService.instance;

    final movies = storage.getMovies();
    final categories = storage.getCategories();

    // Filter movie categories only
    final movieCategories =
        categories.where((c) => c.type == CategoryType.movie).toList();

    setState(() {
      _movies = movies;
      _categories = movieCategories;
      _isLoading = false;
    });
  }

  List<MovieModel> get _filteredMovies {
    var movies = _movies;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != 'favorites') {
      movies = movies.where((m) => m.category == _selectedCategory).toList();
    }

    // Filter favorites
    if (_selectedCategory == 'favorites') {
      final storage = StorageService.instance;
      final favIds = storage.getFavoriteIds('movie');
      movies = movies.where((m) => favIds.contains(m.id)).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      movies = movies
          .where(
            (m) => m.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return movies;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.navMovies),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _MovieSearchDelegate(
                    movies: _movies,
                    onSelect: (movie) => context.push('/movies/${movie.id}'),
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
            : _movies.isEmpty
                ? _buildEmptyState()
                : _buildContent(),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            Text(
              'No movies available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Add an IPTV source with VOD content',
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
                    _buildCategoryChip(null, AppStrings.moviesAll),
                    _buildCategoryChip('favorites', AppStrings.moviesFavorites),
                    ..._categories.map(
                      (c) => _buildCategoryChip(c.id, c.name),
                    ),
                  ],
                ),
              ),
            ),

          // Movie grid
          Expanded(
            child: _buildMovieGrid(_filteredMovies),
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

  Widget _buildMovieGrid(List<MovieModel> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Text(
          'No movies in this category',
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
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return _MovieCard(
              movie: movie,
              onTap: () => context.push('/movies/${movie.id}'),
            );
          },
        );
      },
    );
  }
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      child: movie.posterUrl != null
                          ? CachedNetworkImage(
                              imageUrl: movie.posterUrl!,
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
                    // Rating badge
                    if (movie.rating != null)
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
                                movie.rating!.toStringAsFixed(1),
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
                    // Watch progress
                    if (movie.watchProgressPercent > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundTertiary,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(AppDimensions.radiusS),
                            ),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: movie.watchProgressPercent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(AppDimensions.radiusS),
                                ),
                              ),
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
              movie.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (movie.year != null)
              Text(
                movie.yearString,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
              ),
          ],
        ),
      );
}

class _MovieSearchDelegate extends SearchDelegate<MovieModel?> {
  _MovieSearchDelegate({
    required this.movies,
    required this.onSelect,
  });

  final List<MovieModel> movies;
  final void Function(MovieModel) onSelect;

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
    final results = movies
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final movie = results[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: movie.posterUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: movie.posterUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.movie, color: AppColors.textTertiary),
          ),
          title: Text(
            movie.title,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: movie.year != null
              ? Text(
                  movie.yearString,
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              : null,
          onTap: () {
            close(context, movie);
            onSelect(movie);
          },
        );
      },
    );
  }
}
