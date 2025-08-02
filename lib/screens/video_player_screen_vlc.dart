import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/channel.dart';
import '../models/profile.dart';
import '../widgets/vlc_player_widget.dart';

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
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _enterFullScreen();
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  void _enterFullScreen() {
    if (!_isFullScreen) {
      setState(() {
        _isFullScreen = true;
      });
      
      // Ocultar la barra de estado y navegación
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
      
      // Cambiar orientación a landscape
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _exitFullScreen() {
    if (_isFullScreen) {
      setState(() {
        _isFullScreen = false;
      });
      
      // Restaurar la barra de estado y navegación
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      
      // Restaurar orientación
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _handlePlayerError(String error) {
    // Mostrar snackbar con el error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _onBackPressed() {
    _exitFullScreen();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: VLCPlayerWidget(
          channel: widget.channel,
          profile: widget.profile,
          onBack: _onBackPressed,
          onError: _handlePlayerError,
          showControls: true,
        ),
      ),
    );
  }
}
