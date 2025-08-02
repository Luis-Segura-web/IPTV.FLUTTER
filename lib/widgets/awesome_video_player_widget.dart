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
  BetterPlayerController? _controller;
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
      );

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

  void _handleStatusChanged(BetterPlayerEventType eventType) {
    if (!mounted) return;

    switch (eventType) {
      case BetterPlayerEventType.initialized:
        setState(() {
          _isLoading = false;
          _error = null;
        });
        break;
      case BetterPlayerEventType.play:
      case BetterPlayerEventType.pause:
        setState(() {
          _isLoading = false;
        });
        break;
      case BetterPlayerEventType.exception:
        setState(() {
          _isLoading = false;
          _error = 'Playback error occurred';
        });
        widget.onError?.call('Playback error occurred');
        break;
      default:
        break;
    }
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    await _videoService.disposeCurrentController();
    await _initializePlayer();
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
      child: BetterPlayer(controller: _controller!),
    );
  }
}