# 🎥 VLC Media Player Integration

## Overview

Esta aplicación utiliza **VLC Media Player** como su motor de reproducción de video principal, proporcionando capacidades de streaming de nivel profesional específicamente optimizadas para contenido IPTV.

## 🚀 ¿Por qué VLC?

### Ventajas Técnicas
- **Compatibilidad Universal**: Soporta prácticamente todos los formatos de video y audio
- **Soporte IPTV Superior**: Manejo excelente de streams HLS, DASH, RTSP y RTMP
- **Aceleración de Hardware**: Aceleración completa por hardware para reproducción fluida
- **Buffering Inteligente**: Sistema de caché personalizable para mejor rendimiento
- **Resistencia de Red**: Manejo robusto de interrupciones y reconexiones automáticas

### Beneficios para IPTV
- **Mejor Compatibilidad**: Resuelve problemas de `UnrecognizedInputFormatException`
- **Formatos Múltiples**: Soporta formatos problemáticos que otros reproductores no pueden manejar
- **Streaming Estable**: Conexiones más estables y menos interrupciones
- **Recuperación Automática**: Reconexión automática en caso de pérdida de señal

## 📊 Formatos Soportados

### Video
- **HLS** (.m3u8) - Excelente soporte para TV en vivo
- **DASH** (.mpd) - Streaming adaptativo
- **MP4** - Archivos de video estándar
- **RTSP** - Cámaras IP y streams en vivo
- **RTMP** - Protocolo de streaming en vivo
- **TS** - Transport streams
- **MKV, AVI, FLV** - Contenedores adicionales

### Audio
- **AAC, MP3, OGG** - Codecs de audio estándar
- **AC3, DTS** - Audio de alta calidad
- **Opus** - Codec moderno de baja latencia

### Protocolos
- **HTTP/HTTPS** - Streaming web estándar
- **RTSP/RTMP** - Protocolos de streaming profesional
- **UDP** - Multicast y broadcasting
- **FILE** - Archivos locales

## 🔧 Configuración Técnica

### Configuración VLC Optimizada

```dart
VlcPlayerController.network(
  streamUrl,
  hwAcc: HwAcc.full, // Aceleración de hardware completa
  autoPlay: true,
  autoInitialize: true,
  options: VlcPlayerOptions(
    http: VlcHttpOptions([
      '--http-user-agent=VLC/3.0.18 (IPTV; Flutter) VLCPlayer/1.0',
      '--network-caching=3000',    // Cache de 3 segundos
      '--http-reconnect',          // Reconexión automática
      '--http-continuous',         // Streaming continuo
    ]),
    advanced: VlcAdvancedOptions([
      '--intf=dummy',              // Sin interfaz adicional
      '--no-video-title-show',     // No mostrar título
      '--no-stats',                // Sin estadísticas
      '--rtsp-tcp',                // RTSP sobre TCP
    ]),
    video: VlcVideoOptions([
      '--drop-late-frames',        // Descartar frames tardíos
      '--skip-frames',             // Saltar frames si es necesario
    ]),
    audio: VlcAudioOptions([
      '--aout=android_audiotrack', // Audio optimizado para Android
    ]),
  ),
)
```

### Headers HTTP Personalizados

```dart
Map<String, String> buildHeaders(Profile profile, Channel channel) {
  return {
    'User-Agent': 'VLC/3.0.18 (IPTV; ${profile.name}) VLCPlayer/1.0',
    'Referer': profile.serverUrl,
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Cache-Control': 'no-cache',
    // Headers específicos del proveedor IPTV
    if (profile.username.isNotEmpty) 'X-Player-Username': profile.username,
    if (profile.password.isNotEmpty) 'X-Player-Password': profile.password,
  };
}
```

## 🎮 Controles del Reproductor

### Controles Básicos
- **Play/Pause**: Control de reproducción
- **Stop**: Detener reproducción
- **Seek**: Búsqueda en contenido VOD
- **Volume**: Control de volumen (0-100)

### Funciones Avanzadas
- **Fullscreen**: Modo pantalla completa automático
- **Hardware Acceleration**: Activado por defecto
- **Error Recovery**: Recuperación automática de errores
- **Stream Diagnostics**: Diagnósticos en tiempo real

### Gestos de Usuario
- **Tap**: Mostrar/ocultar controles
- **Back Button**: Salir del reproductor
- **Hardware Back**: Manejo nativo de Android

## 🛠️ Optimizaciones IPTV

### Configuración de Red
```dart
VlcHttpOptions([
  '--network-caching=3000',      // 3 segundos de caché
  '--http-reconnect',            // Reconexión automática
  '--http-continuous',           // Streaming continuo
  '--adaptive-timeout=4000',     // Timeout adaptativo
])
```

### Configuración de Video
```dart
VlcVideoOptions([
  '--drop-late-frames',          // Descartar frames tardíos
  '--skip-frames',               // Saltar frames problemáticos
])
```

### Configuración RTSP
```dart
VlcRtpOptions([
  '--rtsp-tcp',                  // Forzar TCP para RTSP
])
```

## 🚨 Manejo de Errores

### Errores Comunes y Soluciones

#### 1. **Error de Inicialización**
```
Error: Unable to initialize VLC
```
**Solución**: Verificar que la URL sea válida y accesible

#### 2. **Error de Red**
```
Error: Network unreachable
```
**Solución**: Verificar conectividad y configuración de proxy

#### 3. **Formato No Soportado**
```
Error: Unsupported format
```
**Solución**: VLC soporta más formatos - raro que ocurra

#### 4. **Error de Autenticación**
```
Error: HTTP 401/403
```
**Solución**: Verificar credenciales en el perfil IPTV

### Diagnóstico Automático

```dart
void _handleVlcError(String error) {
  if (error.contains('network')) {
    // Problema de conectividad
    showNetworkErrorDialog();
  } else if (error.contains('unauthorized')) {
    // Problema de autenticación
    showAuthErrorDialog();
  } else if (error.contains('format')) {
    // Problema de formato (raro en VLC)
    showFormatErrorDialog();
  } else {
    // Error genérico
    showGenericErrorDialog(error);
  }
}
```

## 📱 Implementación

### Integración Básica

```dart
VLCPlayerWidget(
  channel: channel,
  profile: profile,
  onError: (error) {
    print('VLC Error: $error');
  },
  showControls: true,
)
```

### Configuración Avanzada

```dart
final controller = await VLCVideoService().createController(
  channel: channel,
  profile: profile,
  onError: (error) {
    // Manejo personalizado de errores
  },
);
```

## 🔍 Diagnósticos y Logging

### Información de Estado
```dart
VlcPlayerValue value = controller.value;
print('Estado: ${value.isPlaying ? "Reproduciendo" : "Pausado"}');
print('Duración: ${value.duration}');
print('Posición: ${value.position}');
print('Buffer: ${value.bufferPercent}%');
```

### Logging Detallado
```dart
controller.addListener(() {
  final value = controller.value;
  print('VLC State - Playing: ${value.isPlaying}');
  print('Duration: ${value.duration}');
  print('Position: ${value.position}');
  if (value.hasError) {
    print('VLC Error: ${value.errorDescription}');
  }
});
```

## 🎯 Mejores Prácticas

### Para Desarrolladores
1. **Disposición Correcta**: Siempre disponer el controlador en `dispose()`
2. **Manejo de Estado**: Usar `mounted` para verificar widget activo
3. **Error Handling**: Implementar manejo robusto de errores
4. **Logging**: Activar logs para debugging

### Para Usuarios Finales
1. **Conectividad**: Asegurar conexión estable a internet
2. **URLs Válidas**: Verificar que las URLs de canales sean correctas
3. **Credenciales**: Mantener actualizadas las credenciales IPTV
4. **Actualizaciones**: Mantener la app actualizada

## 🚀 Beneficios vs Otros Reproductores

| Característica | VLC | ExoPlayer | Chewie |
|----------------|-----|-----------|--------|
| Formatos Soportados | ✅ Excelente | ⚠️ Limitado | ⚠️ Limitado |
| RTSP/RTMP | ✅ Nativo | ❌ No | ❌ No |
| Error Recovery | ✅ Avanzado | ⚠️ Básico | ⚠️ Básico |
| Configurabilidad | ✅ Completa | ⚠️ Limitada | ❌ Mínima |
| IPTV Optimization | ✅ Excelente | ⚠️ Requiere trabajo | ❌ Básico |
| Hardware Acceleration | ✅ Completa | ✅ Buena | ✅ Buena |

## 📞 Soporte y Troubleshooting

### Información a Recopilar para Soporte
1. **Modelo de Dispositivo**: Android version y modelo
2. **URL Problemática**: URL específica que falla
3. **Tipo de Error**: Mensaje de error exacto
4. **Logs de VLC**: Output del logging detallado
5. **Proveedor IPTV**: Información del proveedor

### Recursos Adicionales
- [VLC Media Player Documentación](https://www.videolan.org/vlc/)
- [Flutter VLC Player Package](https://pub.dev/packages/flutter_vlc_player)
- [Códigos de Error VLC](https://wiki.videolan.org/Documentation:Streaming_HowTo/)

---

**Última actualización**: Agosto 2025  
**Versión VLC**: 7.4.3  
**Compatibilidad**: Android 6.0+
