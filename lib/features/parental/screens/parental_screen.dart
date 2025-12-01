import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/storage_service.dart';

/// Parental controls screen
class ParentalScreen extends StatefulWidget {
  const ParentalScreen({super.key});

  @override
  State<ParentalScreen> createState() => _ParentalScreenState();
}

class _ParentalScreenState extends State<ParentalScreen> {
  bool _isEnabled = false;
  bool _isLoading = true;
  String? _currentPin;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService.instance;
    final pin = await storage.getSecure('parental_pin');

    setState(() {
      _currentPin = pin;
      _isEnabled = pin != null && pin.isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _toggleParentalControls(bool enabled) async {
    if (enabled) {
      // Set up PIN
      final pin = await _showPinDialog(
        title: AppStrings.parentalSetPIN,
        confirm: true,
      );
      if (pin != null) {
        await StorageService.instance.saveSecure('parental_pin', pin);
        setState(() {
          _isEnabled = true;
          _currentPin = pin;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parental controls enabled'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      // Verify current PIN before disabling
      final verified = await _verifyPin();
      if (verified) {
        await StorageService.instance.deleteSecure('parental_pin');
        setState(() {
          _isEnabled = false;
          _currentPin = null;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parental controls disabled')),
        );
      }
    }
  }

  Future<bool> _verifyPin() async {
    final pin = await _showPinDialog(title: AppStrings.parentalEnterPIN);
    return pin == _currentPin;
  }

  Future<void> _changePin() async {
    // Verify current PIN
    final verified = await _verifyPin();
    if (!verified) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.parentalWrongPIN),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Set new PIN
    final newPin = await _showPinDialog(
      title: 'Enter New PIN',
      confirm: true,
    );
    if (newPin != null) {
      await StorageService.instance.saveSecure('parental_pin', newPin);
      setState(() => _currentPin = newPin);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN changed successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<String?> _showPinDialog({
    required String title,
    bool confirm = false,
  }) async =>
      showDialog<String>(
        context: context,
        builder: (context) => _PinDialog(
          title: title,
          confirm: confirm,
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.parentalTitle),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(width: AppDimensions.spacingL),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Protect Your Content',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lock specific categories and channels with a PIN code',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXXL),

                  // Enable switch
                  Card(
                    color: AppColors.cardBackground,
                    child: SwitchListTile(
                      secondary: Icon(
                        _isEnabled ? Icons.lock : Icons.lock_open,
                        color: _isEnabled
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      title: const Text(
                        AppStrings.parentalEnable,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        _isEnabled
                            ? 'PIN protection is active'
                            : 'Enable to set up PIN protection',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      value: _isEnabled,
                      onChanged: _toggleParentalControls,
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),

                  // PIN management
                  if (_isEnabled) ...[
                    Card(
                      color: AppColors.cardBackground,
                      child: ListTile(
                        leading: const Icon(
                          Icons.pin,
                          color: AppColors.textSecondary,
                        ),
                        title: const Text(
                          AppStrings.parentalChangePIN,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                        onTap: _changePin,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXXL),

                    // Lock categories
                    Text(
                      AppStrings.parentalLockCategories,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Card(
                      color: AppColors.cardBackground,
                      child: Column(
                        children: [
                          _buildCategorySwitch('Adult', Icons.no_adult_content),
                          const Divider(color: AppColors.border, height: 1),
                          _buildCategorySwitch('Sports', Icons.sports),
                          const Divider(color: AppColors.border, height: 1),
                          _buildCategorySwitch('News', Icons.newspaper),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXXL),

                    // Content rating
                    Text(
                      AppStrings.parentalContentRating,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Card(
                      color: AppColors.cardBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Maximum allowed rating',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppDimensions.spacingM),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildRatingChip('G', true),
                                _buildRatingChip('PG', false),
                                _buildRatingChip('PG-13', false),
                                _buildRatingChip('R', false),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      );

  Widget _buildCategorySwitch(String name, IconData icon) => SwitchListTile(
        secondary: Icon(icon, color: AppColors.textSecondary),
        title: Text(
          name,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        value: false,
        onChanged: (value) async {
          if (await _verifyPin()) {
            // TODO: Toggle category lock
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.parentalWrongPIN),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        activeColor: AppColors.primary,
      );

  Widget _buildRatingChip(String rating, bool selected) => ChoiceChip(
        label: Text(rating),
        selected: selected,
        onSelected: (value) async {
          if (await _verifyPin()) {
            // TODO: Update rating restriction
          }
        },
        backgroundColor: AppColors.backgroundTertiary,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      );
}

class _PinDialog extends StatefulWidget {
  const _PinDialog({
    required this.title,
    this.confirm = false,
  });

  final String title;
  final bool confirm;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _pinController.text;

    if (pin.length != 4) {
      setState(() => _error = 'PIN must be 4 digits');
      return;
    }

    if (widget.confirm) {
      if (pin != _confirmController.text) {
        setState(() => _error = 'PINs do not match');
        return;
      }
    }

    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          widget.title,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'Enter PIN',
                errorText: _error,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
            ),
            if (widget.confirm) ...[
              const SizedBox(height: AppDimensions.spacingL),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      );
}
