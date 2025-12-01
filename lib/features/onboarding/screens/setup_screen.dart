import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/http_service.dart';
import '../../../core/services/m3u_parser_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/xtream_service.dart';
import '../../../data/models/provider_model.dart';

/// Setup screen for configuring IPTV sources
class SetupScreen extends StatefulWidget {
  const SetupScreen({required this.type, super.key});

  final String type;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _m3uFormKey = GlobalKey<FormState>();
  final _xtreamFormKey = GlobalKey<FormState>();

  final _m3uUrlController = TextEditingController();
  final _m3uNameController = TextEditingController();
  final _m3uEpgUrlController = TextEditingController();

  final _xtreamServerController = TextEditingController();
  final _xtreamUsernameController = TextEditingController();
  final _xtreamPasswordController = TextEditingController();
  final _xtreamNameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final _httpService = HttpService();
  final _m3uParser = const M3UParserService();
  late final XtreamService _xtreamService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.type == 'xtream' ? 1 : 0,
    );
    _xtreamService = XtreamService(httpService: _httpService);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _m3uUrlController.dispose();
    _m3uNameController.dispose();
    _m3uEpgUrlController.dispose();
    _xtreamServerController.dispose();
    _xtreamUsernameController.dispose();
    _xtreamPasswordController.dispose();
    _xtreamNameController.dispose();
    super.dispose();
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _validateM3U() async {
    if (!_m3uFormKey.currentState!.validate()) return;

    _clearMessages();
    setState(() => _isLoading = true);

    try {
      final content = await _httpService.downloadString(_m3uUrlController.text);

      if (!_m3uParser.validate(content)) {
        setState(() {
          _errorMessage = 'Invalid M3U playlist format';
          _isLoading = false;
        });
        return;
      }

      final channels = _m3uParser.parse(content);
      setState(() {
        _successMessage = 'Found ${channels.length} channels';
        _isLoading = false;
      });
    } on HttpException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to validate: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveM3U() async {
    if (!_m3uFormKey.currentState!.validate()) return;

    _clearMessages();
    setState(() => _isLoading = true);

    try {
      // Download and parse playlist
      final content = await _httpService.downloadString(_m3uUrlController.text);

      if (!_m3uParser.validate(content)) {
        setState(() {
          _errorMessage = 'Invalid M3U playlist format';
          _isLoading = false;
        });
        return;
      }

      final channels = _m3uParser.parse(content);

      // Save provider
      final provider = ProviderModel(
        id: const Uuid().v4(),
        name: _m3uNameController.text.isNotEmpty
            ? _m3uNameController.text
            : 'My M3U Playlist',
        type: ProviderType.m3u,
        url: _m3uUrlController.text,
        epgUrl: _m3uEpgUrlController.text.isNotEmpty
            ? _m3uEpgUrlController.text
            : null,
        createdAt: DateTime.now(),
      );

      final storage = StorageService.instance;
      await storage.saveProvider(provider);
      await storage.saveChannels(channels);
      await storage.setActiveProviderId(provider.id);

      if (!mounted) return;

      context.go(AppRoutes.home);
    } on HttpException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _validateXtream() async {
    if (!_xtreamFormKey.currentState!.validate()) return;

    _clearMessages();
    setState(() => _isLoading = true);

    try {
      final provider = ProviderModel(
        id: const Uuid().v4(),
        name: _xtreamNameController.text.isNotEmpty
            ? _xtreamNameController.text
            : 'My Xtream Provider',
        type: ProviderType.xtream,
        url: _xtreamServerController.text,
        username: _xtreamUsernameController.text,
        password: _xtreamPasswordController.text,
        createdAt: DateTime.now(),
      );

      final result = await _xtreamService.authenticate(provider);

      if (result.isActive) {
        setState(() {
          _successMessage =
              'Connected! Account: ${result.username}, Status: ${result.status}';
          if (result.expirationDate != null) {
            _successMessage =
                '$_successMessage, Expires: ${result.expirationDate}';
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Account is not active: ${result.status}';
          _isLoading = false;
        });
      }
    } on XtreamException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to validate: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveXtream() async {
    if (!_xtreamFormKey.currentState!.validate()) return;

    _clearMessages();
    setState(() => _isLoading = true);

    try {
      final provider = ProviderModel(
        id: const Uuid().v4(),
        name: _xtreamNameController.text.isNotEmpty
            ? _xtreamNameController.text
            : 'My Xtream Provider',
        type: ProviderType.xtream,
        url: _xtreamServerController.text,
        username: _xtreamUsernameController.text,
        password: _xtreamPasswordController.text,
        createdAt: DateTime.now(),
      );

      // Authenticate
      final authResult = await _xtreamService.authenticate(provider);
      if (!authResult.isActive) {
        setState(() {
          _errorMessage = 'Account is not active';
          _isLoading = false;
        });
        return;
      }

      // Update provider with expiration info
      final updatedProvider = provider.copyWith(
        expirationDate: authResult.expirationDate,
        maxConnections: authResult.maxConnections,
      );

      // Fetch channels
      final channels = await _xtreamService.getLiveStreams(provider);
      final movies = await _xtreamService.getVodStreams(provider);
      final series = await _xtreamService.getSeries(provider);
      final liveCategories = await _xtreamService.getLiveCategories(provider);
      final vodCategories = await _xtreamService.getVodCategories(provider);
      final seriesCategories = await _xtreamService.getSeriesCategories(provider);

      // Save data
      final storage = StorageService.instance;
      await storage.saveProvider(updatedProvider);
      await storage.saveChannels(channels);
      await storage.saveMovies(movies);
      await storage.saveSeries(series);
      await storage.saveCategories([
        ...liveCategories,
        ...vodCategories,
        ...seriesCategories,
      ]);
      await storage.setActiveProviderId(provider.id);

      if (!mounted) return;

      context.go(AppRoutes.home);
    } on XtreamException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save: $e';
        _isLoading = false;
      });
    }
  }

  void _setupLater() {
    StorageService.instance.setFirstLaunch(false);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.setupTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: AppStrings.setupM3U),
              Tab(text: AppStrings.setupXtream),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildM3UForm(),
            _buildXtreamForm(),
          ],
        ),
      );

  Widget _buildM3UForm() => SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _m3uFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Text(
                        AppStrings.setupM3UDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXXL),

              // Name field
              TextFormField(
                controller: _m3uNameController,
                decoration: const InputDecoration(
                  labelText: 'Playlist Name (optional)',
                  hintText: 'My M3U Playlist',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // URL field
              TextFormField(
                controller: _m3uUrlController,
                decoration: const InputDecoration(
                  labelText: AppStrings.setupURL,
                  hintText: 'https://example.com/playlist.m3u',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a playlist URL';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // EPG URL field
              TextFormField(
                controller: _m3uEpgUrlController,
                decoration: const InputDecoration(
                  labelText: 'EPG URL (optional)',
                  hintText: 'https://example.com/epg.xml',
                  prefixIcon: Icon(Icons.schedule),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXXL),

              // Messages
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],

              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _validateM3U,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.setupValidate),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingL),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveM3U,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.setupSave),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Setup later button
              TextButton(
                onPressed: _setupLater,
                child: const Text(AppStrings.setupLater),
              ),
            ],
          ),
        ),
      );

  Widget _buildXtreamForm() => SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _xtreamFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Text(
                        AppStrings.setupXtreamDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXXL),

              // Name field
              TextFormField(
                controller: _xtreamNameController,
                decoration: const InputDecoration(
                  labelText: 'Provider Name (optional)',
                  hintText: 'My IPTV Provider',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Server URL field
              TextFormField(
                controller: _xtreamServerController,
                decoration: const InputDecoration(
                  labelText: AppStrings.setupServerURL,
                  hintText: 'http://example.com:8080',
                  prefixIcon: Icon(Icons.dns),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a server URL';
                  }
                  if (!value.startsWith('http://') &&
                      !value.startsWith('https://')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Username field
              TextFormField(
                controller: _xtreamUsernameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.setupUsername,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Password field
              TextFormField(
                controller: _xtreamPasswordController,
                decoration: const InputDecoration(
                  labelText: AppStrings.setupPassword,
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.spacingXXL),

              // Messages
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],

              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _validateXtream,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.setupValidate),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingL),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveXtream,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.setupSave),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Setup later button
              TextButton(
                onPressed: _setupLater,
                child: const Text(AppStrings.setupLater),
              ),
            ],
          ),
        ),
      );
}
