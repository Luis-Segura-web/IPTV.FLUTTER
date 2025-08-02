import 'dart:async';
import 'package:awesome_video_player/awesome_video_player.dart';
import '../models/channel.dart';
import '../models/profile.dart';

class IPTVVideoService {
  static final IPTVVideoService _instance = IPTVVideoService._internal();
  factory IPTVVideoService() => _instance;
  IPTVVideoService._internal();

  AwesomeVideoPlayerController? _currentController;
  StreamSubscription? _statusSubscription;
  StreamSubscription? _errorSubscription;

  /// Creates a new video player controller for IPTV streaming
  Future<AwesomeVideoPlayerController> createController({
    required Channel channel,
    required Profile profile,
    Function(PlayerStatus)? onStatusChanged,
    Function(String)? onError,
  }) async {
    // Dispose previous controller if exists
    await disposeCurrentController();

    // Create new controller with IPTV-specific configuration
    final controller = AwesomeVideoPlayerController.network(
      channel.streamUrl,
      httpHeaders: _buildHttpHeaders(profile, channel),
      autoPlay: true,
    );

    _currentController = controller;

    // Set up status and error listeners
    if (onStatusChanged != null) {
      _statusSubscription = controller.statusStream.listen(onStatusChanged);
    }

    if (onError != null) {
      _errorSubscription = controller.errorStream.listen(onError);
    }

    return controller;
  }

  /// Builds HTTP headers for IPTV authentication and streaming
  Map<String, String> _buildHttpHeaders(Profile profile, Channel channel) {
    final headers = <String, String>{
      'User-Agent': 'Flutter IPTV Player/1.0',
      'Referer': profile.serverUrl,
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate',
      'Connection': 'keep-alive',
    };

    // Add profile-specific headers if needed
    if (profile.username.isNotEmpty && profile.password.isNotEmpty) {
      headers['X-Player-Username'] = profile.username;
      headers['X-Player-Password'] = profile.password;
    }

    // Add channel-specific headers if available in metadata
    if (channel.metadata != null) {
      final metadata = channel.metadata!;
      if (metadata.containsKey('custom_headers')) {
        final customHeaders = metadata['custom_headers'] as Map<String, dynamic>?;
        if (customHeaders != null) {
          customHeaders.forEach((key, value) {
            headers[key] = value.toString();
          });
        }
      }
    }

    return headers;
  }

  /// Disposes the current controller and cleans up resources
  Future<void> disposeCurrentController() async {
    await _statusSubscription?.cancel();
    await _errorSubscription?.cancel();
    _statusSubscription = null;
    _errorSubscription = null;

    if (_currentController != null) {
      await _currentController!.dispose();
      _currentController = null;
    }
  }

  /// Gets the current controller
  AwesomeVideoPlayerController? get currentController => _currentController;

  /// Checks if a controller is currently active
  bool get hasActiveController => _currentController != null;

  /// Seeks to a specific position (mainly for VOD content)
  Future<void> seekTo(Duration position) async {
    if (_currentController != null) {
      await _currentController!.seekTo(position);
    }
  }

  /// Sets the volume
  Future<void> setVolume(double volume) async {
    if (_currentController != null) {
      await _currentController!.setVolume(volume);
    }
  }

  /// Pauses playback
  Future<void> pause() async {
    if (_currentController != null) {
      await _currentController!.pause();
    }
  }

  /// Resumes playback
  Future<void> play() async {
    if (_currentController != null) {
      await _currentController!.play();
    }
  }

  /// Toggles play/pause
  Future<void> togglePlayPause() async {
    if (_currentController != null) {
      if (_currentController!.value.isPlaying) {
        await pause();
      } else {
        await play();
      }
    }
  }

  /// Handles retry logic for failed streams
  Future<void> retry(Channel channel, Profile profile) async {
    if (_currentController != null) {
      // Recreate the controller with the same parameters
      final newController = await createController(
        channel: channel,
        profile: profile,
      );
      
      // Initialize the new controller
      await newController.initialize();
    }
  }

  /// Disposes all resources
  Future<void> dispose() async {
    await disposeCurrentController();
  }
}