import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/profile_model.dart';

/// Profiles management screen
class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<ProfileModel> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final storage = StorageService.instance;
    final profiles = await storage.getProfiles();

    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  Future<void> _addProfile() async {
    final result = await showDialog<ProfileModel>(
      context: context,
      builder: (context) => const _ProfileDialog(),
    );

    if (result != null) {
      await StorageService.instance.saveProfile(result);
      await _loadProfiles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile created')),
      );
    }
  }

  Future<void> _editProfile(ProfileModel profile) async {
    final result = await showDialog<ProfileModel>(
      context: context,
      builder: (context) => _ProfileDialog(profile: profile),
    );

    if (result != null) {
      await StorageService.instance.saveProfile(result);
      await _loadProfiles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }

  Future<void> _deleteProfile(ProfileModel profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text(
          'Delete Profile',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${profile.name}"?',
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
      await StorageService.instance.deleteProfile(profile.id);
      await _loadProfiles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.profilesTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addProfile,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profiles.isEmpty
                ? _buildEmptyState()
                : _buildProfileList(),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            Text(
              'No profiles created',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Create a profile to personalize your experience',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppDimensions.spacingXXL),
            ElevatedButton.icon(
              onPressed: _addProfile,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.profilesAdd),
            ),
          ],
        ),
      );

  Widget _buildProfileList() => ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
            color: AppColors.cardBackground,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: profile.isKidsProfile
                    ? AppColors.categoryKids
                    : AppColors.primary,
                child: Icon(
                  profile.isKidsProfile ? Icons.child_care : Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text(
                profile.name,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                profile.isKidsProfile ? 'Kids Profile' : 'Standard Profile',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                color: AppColors.backgroundSecondary,
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editProfile(profile);
                      break;
                    case 'delete':
                      _deleteProfile(profile);
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
          );
        },
      );
}

class _ProfileDialog extends StatefulWidget {
  const _ProfileDialog({this.profile});

  final ProfileModel? profile;

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late bool _isKidsProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name);
    _isKidsProfile = widget.profile?.isKidsProfile ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final profile = ProfileModel(
      id: widget.profile?.id ?? const Uuid().v4(),
      name: _nameController.text,
      isKidsProfile: _isKidsProfile,
      createdAt: widget.profile?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          widget.profile == null ? AppStrings.profilesAdd : AppStrings.profilesEdit,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.profilesName,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingL),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Kids Profile',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Apply kid-friendly restrictions',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                value: _isKidsProfile,
                onChanged: (value) => setState(() => _isKidsProfile = value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      );
}
