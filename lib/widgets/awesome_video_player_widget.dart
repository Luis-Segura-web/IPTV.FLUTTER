import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_video_player/awesome_video_player.dart';
import '../models/channel.dart';
import '../models/profile.dart';
import '../services/iptv_video_service.dart';

class AwesomeVideoPlayerWidget extends StatefulWidget {
  final Channel channel;
  final Profile profile;
  final VoidCallback? onFullScreenToggle;
  final Function(String)? onError;
  final bool showControls;
  final bool autoPlay;

  const AwesomeVideoPlayerWidget({
    super.key,
    required this.channel,
    required this.profile,
    this.onFullScreenToggle,
    this.onError,
    this.showControls = true,
    this.autoPlay = true,
  });

  @override
  State<AwesomeVideoPlayerWidget> createState() => _AwesomeVideoPlayerWidgetState();
}

class _AwesomeVideoPlayerWidgetState extends State<AwesomeVideoPlayerWidget> {
  final IPTVVideoService _videoService = IPTVVideoService();
  AwesomeVideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializePlayer();
      }
    });
  }

  @override
  void dispose() {
    _videoService.disposeCurrentController();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      _controller = await _videoService.createController(
        channel: widget.channel,
        profile: widget.profile,
        onStatusChanged: _handleStatusChanged,
        onError: _handleError,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      widget.onError?.call(e.toString());
    }
  }

  void _handleStatusChanged(PlayerStatus status) {
    if (!mounted) return;

    switch (status) {
      case PlayerStatus.loading:
        setState(() {
          _isLoading = true;
          _error = null;
        });
        break;
      case PlayerStatus.playing:
      case PlayerStatus.paused:
      case PlayerStatus.completed:
        setState(() {
          _isLoading = false;
          _error = null;
        });
        break;
      case PlayerStatus.failed:
        setState(() {
          _isLoading = false;
          _error = 'Playback failed';
        });
        break;
    }
  }

  void _handleError(String error) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = error;
    });

    widget.onError?.call(error);
  }

  Future<void> _retry() async {
    await _videoService.retry(widget.channel, widget.profile);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    widget.onFullScreenToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_controller == null) {
      return _buildErrorWidget(message: 'Failed to initialize player');
    }

    return _buildVideoPlayer();
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading stream...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget({String? message}) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Stream Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? _error ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onDoubleTap: _toggleFullScreen,
      child: Stack(
        children: [
          AwesomeVideoPlayer(
            controller: _controller!,
            aspectRatio: 16 / 9,
            enableCustomControls: widget.showControls,
            placeholder: Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            errorBuilder: (context, error) => _buildErrorWidget(message: error),
          ),
          if (widget.showControls)
            _buildCustomControls(),
          if (!widget.showControls)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: _toggleFullScreen,
                icon: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomControls() {
    return VideoControls(
      controller: _controller!,
      showFullScreenButton: true,
      showSkipButtons: !widget.channel.isLive,
      onFullScreenToggle: _toggleFullScreen,
      primaryColor: Theme.of(context).colorScheme.primary,
    );
  }
}

/// Custom video controls widget for IPTV
class VideoControls extends StatefulWidget {
  final AwesomeVideoPlayerController controller;
  final bool showFullScreenButton;
  final bool showSkipButtons;
  final VoidCallback? onFullScreenToggle;
  final Color primaryColor;

  const VideoControls({
    super.key,
    required this.controller,
    this.showFullScreenButton = true,
    this.showSkipButtons = true,
    this.onFullScreenToggle,
    this.primaryColor = Colors.blue,
  });

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _showControls = true;
  AwesomeVideoPlayerController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    if (!_showControls) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildTopControls(),
            const Spacer(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Row(
      children: [
        const Spacer(),
        if (widget.showFullScreenButton)
          IconButton(
            onPressed: widget.onFullScreenToggle,
            icon: const Icon(Icons.fullscreen, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return StreamBuilder<PlayerState>(
      stream: _controller.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? PlayerState.stopped;
        final isPlaying = state == PlayerState.playing;
        
        return Row(
          children: [
            IconButton(
              onPressed: () {
                if (isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            if (widget.showSkipButtons) ...[
              IconButton(
                onPressed: () {
                  // Skip backward 10 seconds - implement if supported
                },
                icon: const Icon(Icons.replay_10, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  // Skip forward 10 seconds - implement if supported
                },
                icon: const Icon(Icons.forward_10, color: Colors.white),
              ),
            ],
            const Spacer(),
            StreamBuilder<Duration>(
              stream: _controller.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: _controller.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data;
                    if (duration != null && duration.inSeconds > 0) {
                      return Text(
                        '${_formatDuration(position)} / ${_formatDuration(duration)}',
                        style: const TextStyle(color: Colors.white),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}