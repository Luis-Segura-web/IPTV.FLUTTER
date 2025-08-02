import 'dart:async';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/channel.dart';
import '../models/profile.dart';

class VLCVideoService {
  static final VLCVideoService _instance = VLCVideoService._internal();
  factory VLCVideoService() => _instance;
  VLCVideoService._internal();

  VlcPlayerController? _currentController;

  /// Crea un nuevo controlador VLC para streaming IPTV
  Future<VlcPlayerController> createController({
    required Channel channel,
    required Profile profile,
    Function(String)? onError,
  }) async {
    // Validar URL antes de crear el controlador
    try {
      await validateStreamUrl(channel.streamUrl);
    } catch (e) {
      if (onError != null) {
        _logStreamError(channel.streamUrl, e.toString());
        onError('Error de validación: ${e.toString()}');
      }
      rethrow;
    }

    // Crear controlador VLC con configuración específica para IPTV
    final controller = VlcPlayerController.network(
      _preprocessStreamUrl(channel.streamUrl),
      hwAcc: HwAcc.full, // Aceleración de hardware completa
      autoPlay: true,
      autoInitialize: true,
      options: VlcPlayerOptions(
        http: VlcHttpOptions([
          '--http-user-agent=${_getUserAgent(profile)}',
          '--network-caching=3000',
          '--http-reconnect',
          '--http-continuous',
        ]),
        advanced: VlcAdvancedOptions([
          '--intf=dummy',
          '--no-video-title-show',
          '--no-stats',
          '--rtsp-tcp',
        ]),
        video: VlcVideoOptions([
          '--drop-late-frames',
          '--skip-frames',
        ]),
        audio: VlcAudioOptions([
          '--aout=android_audiotrack',
        ]),
        rtp: VlcRtpOptions([
          '--rtsp-tcp',
        ]),
        extras: [
          '--verbose=2',
          '--demux=adaptive',
          '--adaptive-timeout=4000',
        ],
      ),
    );

    // Configurar listeners de eventos
    _setupEventListeners(controller, onError);

    // Guardar referencia del controlador actual
    _currentController = controller;

    return controller;
  }

  /// Configura los listeners de eventos de VLC
  void _setupEventListeners(VlcPlayerController controller, Function(String)? onError) {
    // Listener para inicialización
    controller.addOnInitListener(() {
      print('VLC Player inicializado correctamente');
    });

    // Listener para cambios de estado de reproducción
    controller.addListener(() {
      final value = controller.value;
      
      if (value.hasError) {
        print('Error en VLC Player: ${value.errorDescription}');
        onError?.call(_getErrorMessage(value.errorDescription));
      }
      
      print('Estado VLC - Reproduciendo: ${value.isPlaying}, Duración: ${value.duration}, Posición: ${value.position}');
    });
  }

  /// Preprocesa la URL del stream para optimización
  String _preprocessStreamUrl(String url) {
    // Añadir parámetros de optimización si es necesario
    if (url.contains('?')) {
      return '$url&buffer_time=3000&live=1';
    } else {
      return '$url?buffer_time=3000&live=1';
    }
  }

  /// Obtiene el User-Agent personalizado para el perfil
  String _getUserAgent(Profile profile) {
    return 'VLC/${_getVlcVersion()} (IPTV; ${profile.name}) VLCPlayer/1.0';
  }

  /// Obtiene la versión de VLC (simulada para el User-Agent)
  String _getVlcVersion() {
    return '3.0.18'; // Versión típica de VLC
  }

  /// Valida si la URL del stream es accesible
  Future<void> validateStreamUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('URL inválida: $url');
    }

    if (!['http', 'https', 'rtsp', 'rtmp'].contains(uri.scheme)) {
      throw Exception('Protocolo no soportado: ${uri.scheme}');
    }

    // Validación adicional para URLs HTTP/HTTPS
    if (uri.scheme.startsWith('http')) {
      if (uri.host.isEmpty) {
        throw Exception('Host inválido en URL: $url');
      }
    }
  }

  /// Control de reproducción
  void play() {
    _currentController?.play();
  }

  void pause() {
    _currentController?.pause();
  }

  void stop() {
    _currentController?.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _currentController?.seekTo(position);
  }

  void setVolume(int volume) {
    _currentController?.setVolume(volume);
  }

  /// Obtiene el estado actual del reproductor
  VlcPlayerValue? get currentState => _currentController?.value;

  bool get isPlaying => _currentController?.value.isPlaying ?? false;
  bool get isInitialized => _currentController?.value.isInitialized ?? false;
  Duration? get duration => _currentController?.value.duration;
  Duration? get position => _currentController?.value.position;

  /// Traduce mensajes de error técnicos a español
  String _getErrorMessage(String? errorDescription) {
    if (errorDescription == null) return 'Error desconocido del reproductor';
    
    final error = errorDescription.toLowerCase();
    
    if (error.contains('network') || error.contains('connection')) {
      return 'Error de conexión de red. Verifica tu conexión a internet.';
    } else if (error.contains('timeout')) {
      return 'Tiempo de espera agotado. El servidor tardó demasiado en responder.';
    } else if (error.contains('not found') || error.contains('404')) {
      return 'Stream no encontrado. Verifica que la URL sea correcta.';
    } else if (error.contains('forbidden') || error.contains('403')) {
      return 'Acceso denegado. Verifica tus credenciales de acceso.';
    } else if (error.contains('unauthorized') || error.contains('401')) {
      return 'No autorizado. Verifica tu usuario y contraseña.';
    } else if (error.contains('format') || error.contains('codec')) {
      return 'Formato de video no soportado o codec no disponible.';
    } else if (error.contains('ssl') || error.contains('certificate')) {
      return 'Error de certificado SSL. Problema de seguridad en la conexión.';
    } else if (error.contains('dns')) {
      return 'Error de DNS. No se pudo resolver la dirección del servidor.';
    } else if (error.contains('buffer')) {
      return 'Error de buffer. Conexión inestable o servidor sobrecargado.';
    } else if (error.contains('rtsp') || error.contains('rtmp')) {
      return 'Error en protocolo de streaming. Verifica la configuración del servidor.';
    } else {
      return 'Error del reproductor VLC: $errorDescription';
    }
  }

  /// Registra errores de streams para debugging
  void _logStreamError(String url, String error) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] ERROR VLC STREAM: $url - $error');
  }

  /// Libera recursos del controlador actual
  Future<void> dispose() async {
    if (_currentController != null) {
      await _currentController!.dispose();
      _currentController = null;
    }
  }

  /// Reinicia el reproductor con el mismo stream
  Future<void> restart({
    required Channel channel,
    required Profile profile,
    Function(String)? onError,
  }) async {
    await dispose();
    await createController(
      channel: channel,
      profile: profile,
      onError: onError,
    );
  }

  /// Cambia la calidad del stream (si está disponible)
  Future<void> changeQuality(String newUrl) async {
    if (_currentController != null) {
      final currentPosition = _currentController!.value.position;
      await _currentController!.setMediaFromNetwork(newUrl);
      await _currentController!.seekTo(currentPosition);
    }
  }

  /// Configuración de aspectos de pantalla
  void setAspectRatio(String aspectRatio) {
    // VLC maneja automáticamente los aspectos de pantalla
    // Podemos implementar lógica específica si es necesario
    print('Configurando aspecto de pantalla: $aspectRatio');
  }

  /// Información de debug del reproductor
  Map<String, dynamic> getDebugInfo() {
    final controller = _currentController;
    if (controller == null) {
      return {'status': 'No hay controlador activo'};
    }

    final value = controller.value;
    return {
      'isInitialized': value.isInitialized,
      'isPlaying': value.isPlaying,
      'duration': value.duration.inSeconds,
      'position': value.position.inSeconds,
      'hasError': value.hasError,
      'errorDescription': value.errorDescription,
      'aspectRatio': value.aspectRatio,
      'size': '${value.size.width}x${value.size.height}',
    };
  }
}
