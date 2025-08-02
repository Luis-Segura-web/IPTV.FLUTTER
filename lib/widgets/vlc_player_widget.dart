import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../services/vlc_video_service.dart';
import '../models/channel.dart';
import '../models/profile.dart';

class VLCPlayerWidget extends StatefulWidget {
  final Channel channel;
  final Profile profile;
  final VoidCallback? onBack;
  final Function(String)? onError;
  final bool showControls;

  const VLCPlayerWidget({
    super.key,
    required this.channel,
    required this.profile,
    this.onBack,
    this.onError,
    this.showControls = true,
  });

  @override
  State<VLCPlayerWidget> createState() => _VLCPlayerWidgetState();
}

class _VLCPlayerWidgetState extends State<VLCPlayerWidget> {
  VlcPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _controlsVisible = true;
  final VLCVideoService _vlcService = VLCVideoService();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      final controller = await _vlcService.createController(
        channel: widget.channel,
        profile: widget.profile,
        onError: _handleError,
      );

      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
        _handleError(e.toString());
      }
    }
  }

  void _handleError(String error) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = error;
      });
    }
    widget.onError?.call(error);
  }

  void _toggleControlsVisibility() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video Player
          if (_controller != null && !_hasError)
            GestureDetector(
              onTap: _toggleControlsVisibility,
              child: Center(
                child: VlcPlayer(
                  controller: _controller!,
                  aspectRatio: 16 / 9,
                  placeholder: _buildLoadingWidget(),
                ),
              ),
            ),

          // Loading Indicator
          if (_isLoading) _buildLoadingWidget(),

          // Error Widget
          if (_hasError) _buildErrorWidget(),

          // Controls Overlay
          if (widget.showControls && _controlsVisible && !_isLoading && !_hasError)
            _buildControlsOverlay(),

          // Back Button
          if (widget.onBack != null)
            Positioned(
              top: 40,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: widget.onBack,
                ),
              ),
            ),

          // Channel Info
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.channel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando stream...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error de Reproducción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Error desconocido',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _initializePlayer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black87,
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Play/Pause Button
              IconButton(
                onPressed: () {
                  if (_vlcService.isPlaying) {
                    _vlcService.pause();
                  } else {
                    _vlcService.play();
                  }
                },
                icon: Icon(
                  _vlcService.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              // Stop Button
              IconButton(
                onPressed: () {
                  _vlcService.stop();
                },
                icon: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              // Volume Controls
              IconButton(
                onPressed: () {
                  // Toggle volume (implement volume control if needed)
                },
                icon: const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              // Info Button
              IconButton(
                onPressed: () {
                  _showPlayerInfo();
                },
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerInfo() {
    final info = _vlcService.getDebugInfo();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del Reproductor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Canal: ${widget.channel.name}'),
            Text('URL: ${widget.channel.streamUrl}'),
            const Divider(),
            ...info.entries.map((entry) => 
              Text('${entry.key}: ${entry.value}')
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // No necesitamos disposar el controlador aquí ya que 
    // el servicio maneja el lifecycle
    super.dispose();
  }
}
