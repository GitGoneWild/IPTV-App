import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/epg_model.dart';

/// Video player screen with EPG overlay
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    required this.url,
    required this.title,
    this.subtitle,
    this.isLive = false,
    this.channelId,
    this.movieId,
    this.episodeId,
    this.position,
    super.key,
  });

  final String url;
  final String title;
  final String? subtitle;
  final bool isLive;
  final String? channelId;
  final String? movieId;
  final String? episodeId;
  final Duration? position;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  bool _showEpgOverlay = false;
  Timer? _hideControlsTimer;
  Timer? _progressSaveTimer;

  List<EpgModel> _epgData = [];
  EpgModel? _currentProgram;
  EpgModel? _nextProgram;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadEpgData();
    _enterFullScreen();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
      );

      await _controller!.initialize();

      // Seek to saved position if available
      if (widget.position != null) {
        await _controller!.seekTo(widget.position!);
      } else if (widget.movieId != null || widget.episodeId != null) {
        final storage = StorageService.instance;
        final type = widget.movieId != null ? 'movie' : 'episode';
        final id = widget.movieId ?? widget.episodeId!;
        final savedPosition = storage.getWatchProgressForItem(type, id);
        if (savedPosition != null) {
          await _controller!.seekTo(savedPosition);
        }
      }

      await _controller!.play();

      _controller!.addListener(_onPlayerUpdate);

      // Start progress save timer
      _progressSaveTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _saveProgress(),
      );

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      _startHideControlsTimer();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _loadEpgData() {
    if (!widget.isLive || widget.channelId == null) return;

    final storage = StorageService.instance;
    _epgData = storage.getEpgForChannel(widget.channelId!);
    _updateCurrentProgram();

    // Update EPG every minute
    Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCurrentProgram();
    });
  }

  void _updateCurrentProgram() {
    if (_epgData.isEmpty) return;

    final now = DateTime.now();
    _currentProgram = _epgData.firstWhere(
      (e) => e.isCurrentlyAiring,
      orElse: () => _epgData.first,
    );

    final currentIndex = _epgData.indexOf(_currentProgram!);
    if (currentIndex < _epgData.length - 1) {
      _nextProgram = _epgData[currentIndex + 1];
    }

    setState(() {});
  }

  void _onPlayerUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller?.value.isPlaying == true) {
      _controller?.pause();
    } else {
      _controller?.play();
      _startHideControlsTimer();
    }
    setState(() {});
  }

  void _toggleEpgOverlay() {
    setState(() => _showEpgOverlay = !_showEpgOverlay);
  }

  void _seekRelative(Duration offset) {
    if (_controller == null) return;
    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition + offset;
    _controller!.seekTo(newPosition);
    _startHideControlsTimer();
  }

  Future<void> _saveProgress() async {
    if (_controller == null || !_isInitialized) return;

    final position = _controller!.value.position;
    final storage = StorageService.instance;

    if (widget.movieId != null) {
      await storage.saveWatchProgress('movie', widget.movieId!, position);
    } else if (widget.episodeId != null) {
      await storage.saveWatchProgress('episode', widget.episodeId!, position);
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _hideControlsTimer?.cancel();
    _progressSaveTimer?.cancel();
    _controller?.removeListener(_onPlayerUpdate);
    _controller?.dispose();
    _exitFullScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.playerBackground,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video player
              _buildVideoPlayer(),

              // Controls overlay
              if (_showControls) _buildControlsOverlay(),

              // EPG overlay
              if (_showEpgOverlay && widget.isLive) _buildEpgOverlay(),

              // Loading indicator
              if (!_isInitialized && !_hasError)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),

              // Error display
              if (_hasError) _buildErrorDisplay(),
            ],
          ),
        ),
      );

  Widget _buildVideoPlayer() {
    if (_controller == null || !_isInitialized) {
      return Container(color: AppColors.playerBackground);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }

  Widget _buildControlsOverlay() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppDimensions.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (widget.isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              color: Colors.white,
                              size: 10,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.isLive && _epgData.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          _showEpgOverlay ? Icons.info : Icons.info_outline,
                        ),
                        color: Colors.white,
                        onPressed: _toggleEpgOverlay,
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Center play controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!widget.isLive)
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      color: Colors.white,
                      iconSize: 40,
                      onPressed: () =>
                          _seekRelative(const Duration(seconds: -10)),
                    ),
                  const SizedBox(width: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _controller?.value.isPlaying == true
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      color: Colors.white,
                      iconSize: 48,
                      onPressed: _togglePlayPause,
                    ),
                  ),
                  const SizedBox(width: 24),
                  if (!widget.isLive)
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      color: Colors.white,
                      iconSize: 40,
                      onPressed: () =>
                          _seekRelative(const Duration(seconds: 10)),
                    ),
                ],
              ),

              const Spacer(),

              // Bottom bar with progress
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    // Current program info for live TV
                    if (widget.isLive && _currentProgram != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimensions.spacingM),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Now: ${_currentProgram!.title}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_nextProgram != null)
                                    Text(
                                      'Next: ${_nextProgram!.title}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Progress bar for VOD
                    if (!widget.isLive && _controller != null && _isInitialized)
                      Row(
                        children: [
                          Text(
                            _formatDuration(_controller!.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: _controller!.value.position.inMilliseconds
                                  .toDouble(),
                              min: 0,
                              max: _controller!.value.duration.inMilliseconds
                                  .toDouble(),
                              onChanged: (value) {
                                _controller!.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                              activeColor: AppColors.primary,
                              inactiveColor: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          Text(
                            _formatDuration(_controller!.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                    // Live progress bar
                    if (widget.isLive && _currentProgram != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _currentProgram!.progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          color: AppColors.primary,
                          minHeight: 4,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildEpgOverlay() => Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        width: 300,
        child: Container(
          color: AppColors.background.withValues(alpha: 0.95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                color: AppColors.backgroundSecondary,
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Program Guide',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                      onPressed: _toggleEpgOverlay,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // EPG list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  itemCount: _epgData.length,
                  itemBuilder: (context, index) {
                    final program = _epgData[index];
                    final isCurrent = program.isCurrentlyAiring;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent
                            ? Border.all(color: AppColors.primary)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_formatTime(program.startTime)} - ${_formatTime(program.endTime)}',
                                style: TextStyle(
                                  color: isCurrent
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isCurrent) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'NOW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            program.title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (program.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              program.description!,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (isCurrent) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: program.progress,
                                backgroundColor: AppColors.backgroundTertiary,
                                color: AppColors.primary,
                                minHeight: 3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildErrorDisplay() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _initializePlayer,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      );

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
