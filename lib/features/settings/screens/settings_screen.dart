import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/provider_model.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<ProviderModel> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = StorageService.instance;
    final providers = await storage.getProviders();

    setState(() {
      _providers = providers;
      _isLoading = false;
    });
  }

  Future<void> _refreshPlaylist() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text(
              'Refreshing playlist...',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playlist refreshed'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _refreshEpg() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text(
              'Refreshing EPG...',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EPG refreshed'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _deleteProvider(ProviderModel provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text(
          'Delete Provider',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${provider.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.instance.deleteProvider(provider.id);
      await _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Provider deleted'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.settingsTitle),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                children: [
                  // IPTV Accounts Section
                  _buildSectionHeader(
                    icon: Icons.account_circle,
                    title: AppStrings.settingsAccounts,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildAccountsSection(),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // General Section
                  _buildSectionHeader(
                    icon: Icons.tune,
                    title: AppStrings.settingsGeneral,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildGeneralSection(),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Playback Section
                  _buildSectionHeader(
                    icon: Icons.play_circle_outline,
                    title: AppStrings.settingsPlayback,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildPlaybackSection(),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Parental Controls Section
                  _buildSectionHeader(
                    icon: Icons.lock_outline,
                    title: AppStrings.settingsParental,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildParentalSection(),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Notifications Section
                  _buildSectionHeader(
                    icon: Icons.notifications_outlined,
                    title: AppStrings.settingsNotifications,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildNotificationsSection(),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // About Section
                  _buildSectionHeader(
                    icon: Icons.info_outline,
                    title: AppStrings.settingsAbout,
                  ),
                  const SizedBox(height: AppDimensions.spacingM),
                  _buildAboutSection(),
                  const SizedBox(height: AppDimensions.spacingXXXL),
                ],
              ),
      );

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) =>
      Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppDimensions.spacingM),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      );

  Widget _buildAccountsSection() => Card(
        color: AppColors.cardBackground,
        child: Column(
          children: [
            // Providers list
            if (_providers.isEmpty)
              const ListTile(
                leading: Icon(Icons.info_outline, color: AppColors.textTertiary),
                title: Text(
                  'No IPTV sources configured',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ..._providers.map(
                (provider) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: provider.type == ProviderType.xtream
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      provider.type == ProviderType.xtream
                          ? Icons.cloud
                          : Icons.playlist_play,
                      color: provider.type == ProviderType.xtream
                          ? AppColors.primary
                          : AppColors.accent,
                    ),
                  ),
                  title: Text(
                    provider.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    provider.type == ProviderType.xtream
                        ? 'Xtream Codes'
                        : 'M3U Playlist',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                    color: AppColors.backgroundSecondary,
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          // TODO: Edit provider
                          break;
                        case 'delete':
                          _deleteProvider(provider);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppColors.textSecondary),
                            SizedBox(width: 12),
                            Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Divider(color: AppColors.border),

            // Add account button
            ListTile(
              leading: const Icon(Icons.add, color: AppColors.primary),
              title: const Text(
                AppStrings.settingsAddAccount,
                style: TextStyle(color: AppColors.primary),
              ),
              onTap: () => context.push(AppRoutes.setup),
            ),

            // Refresh buttons
            if (_providers.isNotEmpty) ...[
              const Divider(color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.refresh, color: AppColors.textSecondary),
                title: const Text(
                  AppStrings.settingsRefresh,
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: _refreshPlaylist,
              ),
              ListTile(
                leading: const Icon(Icons.schedule, color: AppColors.textSecondary),
                title: const Text(
                  AppStrings.settingsRefreshEPG,
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: _refreshEpg,
              ),
            ],
          ],
        ),
      );

  Widget _buildGeneralSection() => Card(
        color: AppColors.cardBackground,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.textSecondary),
              title: const Text(
                AppStrings.settingsLanguage,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: const Text(
                'English',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                // TODO: Language selection
              },
            ),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: const Icon(Icons.palette_outlined, color: AppColors.textSecondary),
              title: const Text(
                AppStrings.settingsTheme,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: const Text(
                'Dark',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                // TODO: Theme selection
              },
            ),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.textSecondary),
              title: const Text(
                AppStrings.profilesTitle,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => context.push(AppRoutes.profiles),
            ),
          ],
        ),
      );

  Widget _buildPlaybackSection() => Card(
        color: AppColors.cardBackground,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.speed, color: AppColors.textSecondary),
              title: const Text(
                AppStrings.settingsBufferSize,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: const Text(
                '5 seconds',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                // TODO: Buffer size selection
              },
            ),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: const Icon(Icons.hd, color: AppColors.textSecondary),
              title: const Text(
                AppStrings.settingsQuality,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: const Text(
                'Auto',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                // TODO: Quality selection
              },
            ),
          ],
        ),
      );

  Widget _buildParentalSection() => Card(
        color: AppColors.cardBackground,
        child: ListTile(
          leading: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
          title: const Text(
            AppStrings.parentalTitle,
            style: TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: const Text(
            'Configure PIN and content restrictions',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => context.push(AppRoutes.parental),
        ),
      );

  Widget _buildNotificationsSection() => Card(
        color: AppColors.cardBackground,
        child: Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active, color: AppColors.textSecondary),
              title: const Text(
                'Push Notifications',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Receive notifications for new content',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              value: false,
              onChanged: (value) {
                // TODO: Toggle notifications
              },
              activeColor: AppColors.primary,
            ),
            const Divider(color: AppColors.border, height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.event, color: AppColors.textSecondary),
              title: const Text(
                'Program Reminders',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Get reminded about upcoming programs',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              value: false,
              onChanged: (value) {
                // TODO: Toggle reminders
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      );

  Widget _buildAboutSection() => Card(
        color: AppColors.cardBackground,
        child: Column(
          children: [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
              title: const Text(
                AppStrings.appName,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Version ${AppStrings.appVersion}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.textSecondary),
              title: const Text(
                'Terms of Service',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () {
                // TODO: Open terms
              },
            ),
            const Divider(color: AppColors.border, height: 1),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondary),
              title: const Text(
                'Privacy Policy',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () {
                // TODO: Open privacy policy
              },
            ),
          ],
        ),
      );
}
