import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/channel.dart';
import '../models/profile.dart';
import '../config/constants.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Channel channel;
  final Profile profile;

  const VideoPlayerScreen({
    super.key,
    required this.channel,
    required this.profile,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _exitFullScreen();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
        httpHeaders: {
          'User-Agent': 'Flutter IPTV Player',
          'Referer': widget.profile.serverUrl,
        },
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).colorScheme.primary,
          handleColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Colors.grey,
          bufferedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Playback Error',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
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
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _retry() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _initializePlayer();
  }

  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen ? null : AppBar(
        title: Text(
          widget.channel.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _enterFullScreen,
            icon: const Icon(Icons.fullscreen),
          ),
          IconButton(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildVideoPlayer(),
            ),
            if (!_isFullScreen) _buildChannelInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
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
      );
    }

    if (_error != null) {
      return Center(
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
              _error!,
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
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    if (_chewieController != null) {
      return GestureDetector(
        onDoubleTap: _isFullScreen ? _exitFullScreen : _enterFullScreen,
        child: Chewie(controller: _chewieController!),
      );
    }

    return const Center(
      child: Text(
        'Failed to initialize player',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildChannelInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.channel.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.channel.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.channel.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                widget.channel.isLive ? Icons.live_tv : Icons.movie,
                color: widget.channel.isLive ? Colors.red : Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                widget.channel.isLive ? 'Live TV' : 'On Demand',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                'Profile: ${widget.profile.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}