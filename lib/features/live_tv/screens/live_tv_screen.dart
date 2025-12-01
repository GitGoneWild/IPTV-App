import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/channel_model.dart';
import '../../../data/models/epg_model.dart';

/// Live TV screen with channel listings and EPG
class LiveTVScreen extends StatefulWidget {
  const LiveTVScreen({super.key});

  @override
  State<LiveTVScreen> createState() => _LiveTVScreenState();
}

class _LiveTVScreenState extends State<LiveTVScreen>
    with SingleTickerProviderStateMixin {
  List<ChannelModel> _channels = [];
  List<CategoryModel> _categories = [];
  Map<String, List<EpgModel>> _epgByChannel = {};
  String? _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = StorageService.instance;

    final channels = storage.getChannels();
    final categories = storage.getCategories();
    final epg = storage.getEpg();

    // Group EPG by channel ID
    final epgByChannel = <String, List<EpgModel>>{};
    for (final entry in epg) {
      epgByChannel.putIfAbsent(entry.channelId, () => []).add(entry);
    }
    for (final entries in epgByChannel.values) {
      entries.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    // Filter live categories only
    final liveCategories = categories
        .where((c) => c.type == CategoryType.live || c.type == null)
        .toList();

    setState(() {
      _channels = channels;
      _categories = liveCategories;
      _epgByChannel = epgByChannel;
      _isLoading = false;

      _tabController = TabController(
        length: _categories.length + 2, // All + Favorites + categories
        vsync: this,
      );
    });
  }

  List<ChannelModel> get _filteredChannels {
    var channels = _channels;

    // Filter by category
    if (_selectedCategory != null) {
      channels = channels
          .where((c) => c.group == _selectedCategory)
          .toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      channels = channels
          .where(
            (c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return channels;
  }

  List<ChannelModel> get _favoriteChannels {
    final storage = StorageService.instance;
    final favIds = storage.getFavoriteIds('channel');
    return _channels.where((c) => favIds.contains(c.id)).toList();
  }

  void _navigateToPlayer(ChannelModel channel) {
    if (channel.streamUrl == null) return;

    context.push(
      AppRoutes.player,
      extra: {
        'url': channel.streamUrl,
        'title': channel.name,
        'isLive': true,
        'channelId': channel.id,
      },
    );
  }

  Future<void> _toggleFavorite(ChannelModel channel) async {
    final storage = StorageService.instance;
    if (storage.isFavorite('channel', channel.id)) {
      await storage.removeFavorite('channel', channel.id);
    } else {
      await storage.addFavorite('channel', channel.id);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.navLiveTV),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _ChannelSearchDelegate(
                    channels: _channels,
                    epgByChannel: _epgByChannel,
                    onSelect: _navigateToPlayer,
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
            : _channels.isEmpty
                ? _buildEmptyState()
                : _buildContent(),
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
              'No channels available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Add an IPTV source to view live channels',
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
                    _buildCategoryChip(null, AppStrings.liveTVAllChannels),
                    _buildCategoryChip('favorites', AppStrings.liveTVFavorites),
                    ..._categories.map(
                      (c) => _buildCategoryChip(c.id, c.name),
                    ),
                  ],
                ),
              ),
            ),

          // Channel list
          Expanded(
            child: _selectedCategory == 'favorites'
                ? _buildChannelList(_favoriteChannels)
                : _buildChannelList(_filteredChannels),
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

  Widget _buildChannelList(List<ChannelModel> channels) {
    if (channels.isEmpty) {
      return Center(
        child: Text(
          'No channels in this category',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];
        final epg = _epgByChannel[channel.epgId ?? channel.id] ?? [];
        final currentProgram = epg.firstWhere(
          (e) => e.isCurrentlyAiring,
          orElse: () => epg.isNotEmpty ? epg.first : EpgModel(
            id: '',
            channelId: channel.id,
            title: AppStrings.liveTVNoEPG,
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
          ),
        );
        final nextProgram = epg.length > 1 && epg.first == currentProgram
            ? epg[1]
            : null;

        return _ChannelListTile(
          channel: channel,
          currentProgram: currentProgram,
          nextProgram: nextProgram,
          isFavorite: StorageService.instance.isFavorite('channel', channel.id),
          onTap: () => _navigateToPlayer(channel),
          onFavorite: () => _toggleFavorite(channel),
        );
      },
    );
  }
}

class _ChannelListTile extends StatelessWidget {
  const _ChannelListTile({
    required this.channel,
    required this.currentProgram,
    this.nextProgram,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  final ChannelModel channel;
  final EpgModel currentProgram;
  final EpgModel? nextProgram;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

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
                // Channel logo
                Container(
                  width: 60,
                  height: 60,
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
                const SizedBox(width: AppDimensions.spacingM),

                // Channel info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Current program
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'NOW',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentProgram.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Progress bar
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: currentProgram.progress,
                          backgroundColor: AppColors.backgroundTertiary,
                          color: AppColors.primary,
                          minHeight: 3,
                        ),
                      ),

                      // Next program
                      if (nextProgram != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Next: ${nextProgram!.title}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Favorite button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.textSecondary,
                  ),
                  onPressed: onFavorite,
                ),
              ],
            ),
          ),
        ),
      );
}

class _ChannelSearchDelegate extends SearchDelegate<ChannelModel?> {
  _ChannelSearchDelegate({
    required this.channels,
    required this.epgByChannel,
    required this.onSelect,
  });

  final List<ChannelModel> channels;
  final Map<String, List<EpgModel>> epgByChannel;
  final void Function(ChannelModel) onSelect;

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
    final results = channels
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final channel = results[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: channel.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: channel.logoUrl!,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Icon(Icons.live_tv, color: AppColors.textTertiary),
          ),
          title: Text(
            channel.name,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: channel.group != null
              ? Text(
                  channel.group!,
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              : null,
          onTap: () {
            close(context, channel);
            onSelect(channel);
          },
        );
      },
    );
  }
}
