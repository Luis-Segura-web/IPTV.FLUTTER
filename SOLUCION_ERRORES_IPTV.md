# 🛠️ Guía de Solución de Errores IPTV

## 📋 Error Principal: UnrecognizedInputFormatException

### ❗ **Descripción del Problema**
```
UnrecognizedInputFormatException: None of the available extractors could read the stream
```

Este error indica que **ExoPlayer no puede reconocer el formato del stream** que está intentando reproducir.

### 🔍 **Causas Principales**

1. **Stream Corrupto o Inválido**
   - El servidor IPTV está enviando datos que no son de video
   - La URL del canal está apuntando a contenido no válido
   - El stream está interrumpido o dañado

2. **Formato No Soportado**
   - El stream está en un formato que ExoPlayer no puede procesar
   - Codificación de video no estándar
   - Headers HTTP incorrectos que confunden al detector de formato

3. **Problemas de Conectividad**
   - Conexión intermitente que causa corrupción de datos
   - Timeout en la conexión inicial
   - Problemas de autenticación con el servidor IPTV

### 🛠️ **Soluciones Implementadas**

#### 1. **Validación Previa de Streams**
```dart
// El servicio ahora valida URLs antes de crear el reproductor
final isValid = await validateStreamUrl(channel.streamUrl);
if (!isValid) {
  throw Exception('Formato de stream no soportado');
}
```

#### 2. **Headers HTTP Mejorados**
```dart
// Headers específicos por tipo de stream
if (url.contains('.m3u8')) {
  headers['Accept'] = 'application/vnd.apple.mpegurl, */*';
} else if (url.contains('.mpd')) {
  headers['Accept'] = 'application/dash+xml, */*';
}
```

#### 3. **Detección de Errores Mejorada**
- Mensajes de error específicos y en español
- Logging detallado para debugging
- Diagnóstico automático de problemas de URL

#### 4. **User-Agent Optimizado**
```dart
'User-Agent': 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36'
```

### 📱 **Cómo Identificar el Problema**

#### **Síntomas Visibles:**
- ✅ La aplicación se conecta al servidor IPTV
- ✅ Se cargan las listas de canales
- ❌ Error al reproducir canales específicos
- ❌ Mensaje: "Formato de stream no soportado"

#### **Logging en Consola:**
```
=== ERROR DE STREAM IPTV ===
URL: http://example.com/stream.m3u8
Error: UnrecognizedInputFormatException
DIAGNÓSTICO: El ExoPlayer no puede detectar el formato del stream
POSIBLES CAUSAS:
- Stream corrupto o no válido
- Formato de video no estándar
```

### 🔧 **Pasos para Solucionar**

#### **Para Usuarios:**

1. **Verificar la URL del Canal**
   ```
   ✅ Correcto: http://server.com/live/channel.m3u8
   ❌ Incorrecto: http://server.com/invalid_url
   ```

2. **Probar con Otro Canal**
   - Si otros canales funcionan, el problema es específico del canal
   - Si ningún canal funciona, problema de configuración general

3. **Verificar Credenciales**
   - Usuario y contraseña correctos en el perfil
   - Servidor IPTV activo y funcionando

4. **Usar el Reproductor Alternativo**
   - Cambiar entre "Awesome Player" y "Legacy Player"
   - El botón de toggle está en la barra superior del reproductor

5. **🆕 Reiniciar la Aplicación**
   - Cerrar completamente la app
   - Volver a abrirla y probar de nuevo
   - Esto limpia la caché del reproductor

6. **🆕 Verificar Conectividad**
   - Asegurarse de tener conexión estable a internet
   - Probar cambiar de WiFi a datos móviles o viceversa

#### **Para Desarrolladores:**

1. **Verificar URLs de Test**
   ```dart
   // Usar el método de diagnóstico
   final diagnosis = await videoService.diagnoseStream(channelUrl);
   print('Diagnóstico: ${diagnosis}');
   ```

2. **Analizar Headers HTTP**
   ```dart
   // Verificar que los headers sean apropiados para el tipo de stream
   final headers = _buildHttpHeaders(profile, channel);
   ```

3. **Implementar Retry Logic**
   ```dart
   // El servicio incluye retry automático
   await videoService.retry(channel, profile);
   ```

### 📊 **Formatos de Stream Soportados**

| Formato | Extensión | Soporte | Compatibilidad |
|---------|-----------|---------|----------------|
| HLS | `.m3u8` | ✅ Completo | Excelente |
| DASH | `.mpd` | ✅ Completo | Muy Buena |
| MP4 | `.mp4` | ✅ Completo | Excelente |
| TS | `.ts` | ✅ Completo | Buena |
| MKV | `.mkv` | ⚠️ Limitado | Variable |
| AVI | `.avi` | ⚠️ Limitado | Variable |

### 🎯 **Mejores Prácticas**

1. **Para Proveedores IPTV:**
   - Usar formatos estándar (HLS, DASH)
   - Proporcionar URLs con extensiones claras
   - Mantener streams estables y sin interrupciones

2. **Para Configuración de Perfiles:**
   - Verificar URLs de servidor antes de guardar
   - Usar credenciales válidas
   - Probar conectividad regularmente

3. **Para Debugging:**
   - Activar logging detallado
   - Usar herramientas de diagnóstico incluidas
   - Probar con múltiples canales

### 🚨 **Casos Especiales**

#### **Error Persistente en Todos los Canales:**
- Problema de configuración de perfil
- Servidor IPTV caído o con problemas
- Problemas de conectividad de red

#### **Error Solo en Canales Específicos:**
- URLs de canales individuales incorrectas
- Formato no soportado para esos canales específicos
- Restricciones geográficas o de acceso

#### **Error Intermitente:**
- Problemas de conectividad
- Sobrecarga del servidor IPTV
- Problemas de ancho de banda

### 🚨 **Errores Adicionales Comunes**

#### **RenderFlex Overflow Error:**
```
A RenderFlex overflowed by 1.1 pixels on the bottom.
```

**Descripción:** Error de interfaz de usuario que no afecta la funcionalidad del reproductor.

**Solución:**
- Este error es cosmético y no afecta la reproducción
- Será corregido en futuras actualizaciones
- No requiere acción del usuario

#### **OnBackInvokedCallback Warning:**
```
OnBackInvokedCallback is not enabled for the application.
```

**Descripción:** Advertencia sobre configuración de navegación Android 13+.

**Solución:**
- Advertencia informativa, no afecta funcionalidad
- Se corregirá en configuración de manifest Android

### 📞 **Contacto y Soporte**

Si después de seguir esta guía el problema persiste:

1. **Documentar el Error:**
   - Copiar el log completo del error
   - Incluir la URL del canal problemático
   - Especificar el modelo de dispositivo

2. **Información a Proporcionar:**
   - Versión de la aplicación
   - Tipo de conexión (WiFi/Datos móviles)
   - Proveedor IPTV utilizado
   - Otros reproductores que funcionan/no funcionan

3. **Pruebas Adicionales:**
   - Probar la URL en otros reproductores IPTV
   - Verificar con el proveedor IPTV
   - Probar en diferentes dispositivos

---

**Última actualización:** Agosto 2025  
**Versión de la guía:** 1.0  
**Aplicable a:** IPTV Flutter App v1.0+
