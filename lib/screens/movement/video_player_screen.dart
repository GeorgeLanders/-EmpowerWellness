import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/storage_service.dart';
import 'movement_library_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MovementItem movementItem;

  const VideoPlayerScreen({super.key, required this.movementItem});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.movementItem.assetPath);
      await _controller!.initialize();
      _controller!.addListener(_videoListener);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _seekForward() {
    if (_controller == null || !_isInitialized) return;
    final newPosition = _controller!.value.position + const Duration(seconds: 10);
    final clamped = newPosition > _controller!.value.duration ? _controller!.value.duration : newPosition;
    _controller!.seekTo(clamped);
  }

  void _seekBackward() {
    if (_controller == null || !_isInitialized) return;
    final newPosition = _controller!.value.position - const Duration(seconds: 10);
    final clamped = newPosition < Duration.zero ? Duration.zero : newPosition;
    _controller!.seekTo(clamped);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Log the completed movement and update user stats
  void _logMovement() {
    final storage = StorageService();
    final user = storage.loadUserData();

    // Update tracking fields
    user.totalMovements++;
    if (!user.completedExerciseIds.contains(widget.movementItem.title)) {
      user.completedExerciseIds = [...user.completedExerciseIds, widget.movementItem.title];
    }

    // Update streak
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (user.lastActiveDate != today) {
      user.daysActive++;
      // Check if consecutive day
      if (user.lastActiveDate.isNotEmpty) {
        final lastDate = DateTime.parse(user.lastActiveDate);
        final diff = DateTime.now().difference(lastDate).inDays;
        if (diff == 1) {
          user.currentStreak++;
        } else {
          user.currentStreak = 1;
        }
      } else {
        user.currentStreak = 1;
      }
      user.lastActiveDate = today;
    }

    // Update diorama progress (caps at 100)
    user.dioramaProgress = ((user.totalMovements * 2).clamp(0, 100));

    storage.saveUserData(user);

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${widget.movementItem.title} completed! Total: ${user.totalMovements}',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          backgroundColor: AppTheme.voidPurple,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.movementItem.title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        ),
        body: _hasError ? _buildFallback() : _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.space6),
        padding: const EdgeInsets.all(AppTheme.space8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withValues(alpha: 0.3),
              AppTheme.deepSpace.withValues(alpha: 0.8),
              AppTheme.neonCyan.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.glassBorders),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glassWhite,
                border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.5), width: 2),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.neonCyan,
                size: 64,
              ),
            ),
            const SizedBox(height: AppTheme.space6),
            const Text(
              'Video Coming Soon',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.space3),
            Text(
              widget.movementItem.title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              '${widget.movementItem.duration} • ${widget.movementItem.targetArea}',
              style: TextStyle(
                color: AppTheme.neonCyan.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space6),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  _logMovement();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warmGold,
                  foregroundColor: AppTheme.deepSpace,
                  elevation: 8,
                  shadowColor: AppTheme.warmGold.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
                child: const Text(
                  'Complete & Log Movement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.neonCyan),
      );
    }

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        // Video Area
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                  if (_showControls) ...[
                    Positioned(
                      bottom: 80,
                      left: AppTheme.space4,
                      right: AppTheme.space4,
                      child: GlassCard(
                        opacity: 0.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _seekBackward,
                              icon: const Icon(Icons.replay_10, color: AppTheme.textPrimary, size: 32),
                            ),
                            const SizedBox(width: AppTheme.space4),
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Container(
                                padding: const EdgeInsets.all(AppTheme.space3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.neonCyan.withValues(alpha: 0.2),
                                  border: Border.all(color: AppTheme.neonCyan, width: 2),
                                ),
                                child: Icon(
                                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: AppTheme.neonCyan,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.space4),
                            IconButton(
                              onPressed: _seekForward,
                              icon: const Icon(Icons.forward_10, color: AppTheme.textPrimary, size: 32),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: AppTheme.space4,
                      right: AppTheme.space4,
                      child: GlassCard(
                        opacity: 0.25,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                activeTrackColor: AppTheme.neonCyan,
                                inactiveTrackColor: AppTheme.glassBorders,
                                thumbColor: AppTheme.neonCyan,
                                overlayColor: AppTheme.neonCyan.withValues(alpha: 0.2),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: progress.clamp(0.0, 1.0),
                                onChanged: (value) {
                                  final newPosition = Duration(
                                    milliseconds: (value * duration.inMilliseconds).round(),
                                  );
                                  _controller!.seekTo(newPosition);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppTheme.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.movementItem.duration} • ${widget.movementItem.targetArea}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space4),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _logMovement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warmGold,
                    foregroundColor: AppTheme.deepSpace,
                    elevation: 8,
                    shadowColor: AppTheme.warmGold.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                  ),
                  child: const Text(
                    'Complete & Log Movement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
