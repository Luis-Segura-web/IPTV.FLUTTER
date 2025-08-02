# Awesome Video Player Integration

## Overview

This document describes the integration of Awesome Video Player as the main video player for the IPTV Flutter application. The implementation provides enhanced streaming capabilities, improved error handling, and better IPTV support while maintaining backward compatibility with the existing Chewie player.

## Features

### 🎥 Dual Player Support
- **Awesome Video Player**: Modern, feature-rich player optimized for IPTV streaming
- **Legacy Chewie Player**: Fallback option for compatibility
- **Runtime Toggle**: Switch between players without restarting the app

### 🔧 IPTV-Specific Enhancements
- **Custom HTTP Headers**: Support for authentication and streaming headers
- **Optimized Buffering**: Enhanced buffer configuration for live streams
- **Live Stream Support**: Specialized controls for live TV channels
- **VOD Support**: Full controls for video-on-demand content

### 🎮 Enhanced Controls
- **Fullscreen Support**: Double-tap or button toggle
- **Play/Pause Controls**: Standard playback controls
- **Skip Controls**: 10-second forward/backward (VOD only)
- **Progress Display**: Current position and duration
- **Custom Styling**: Theme-aware control colors

### 🛠️ Error Handling
- **Automatic Retry**: Built-in retry mechanism for failed streams
- **Error Reporting**: Detailed error messages and callbacks
- **Graceful Fallback**: Smooth transition between player types

## Implementation Files

### Core Service
```
lib/services/iptv_video_service.dart
```
- Manages Awesome Video Player controllers
- Handles IPTV-specific configuration
- Provides HTTP header customization
- Implements retry logic and error handling

### Widget Components
```
lib/widgets/awesome_video_player_widget.dart
```
- Main video player widget wrapper
- Custom control implementation
- Fullscreen management
- Status and error handling

### Updated Screen
```
lib/screens/video_player_screen.dart
```
- Integrated Awesome Video Player
- Player toggle functionality
- Backward compatibility with Chewie
- Enhanced UI with player status indication

### Tests
```
test/iptv_video_service_test.dart
```
- Unit tests for video service
- Model validation tests
- Service lifecycle tests

## Usage

### Basic Implementation

```dart
// Using the updated VideoPlayerScreen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VideoPlayerScreen(
      channel: channel,
      profile: profile,
    ),
  ),
);
```

### Direct Widget Usage

```dart
AwesomeVideoPlayerWidget(
  channel: channel,
  profile: profile,
  showControls: true,
  autoPlay: true,
  onError: (error) {
    // Handle playback errors
    print('Player error: $error');
  },
  onFullScreenToggle: () {
    // Handle fullscreen changes
  },
)
```

### Service Usage

```dart
final videoService = IPTVVideoService();

// Create a controller
final controller = await videoService.createController(
  channel: channel,
  profile: profile,
  onStatusChanged: (status) {
    // Handle status changes
  },
  onError: (error) {
    // Handle errors
  },
);

// Initialize the controller
await controller.initialize();
```

## Configuration

### HTTP Headers

The service automatically builds appropriate HTTP headers for IPTV streaming:

```dart
// Standard headers
'User-Agent': 'Flutter IPTV Player/1.0'
'Referer': profile.serverUrl
'Accept': '*/*'
'Accept-Encoding': 'gzip, deflate'
'Connection': 'keep-alive'

// Profile-specific headers
'X-Player-Username': profile.username
'X-Player-Password': profile.password

// Custom headers from channel metadata
// Supports additional headers via channel.metadata['custom_headers']
```

### Buffer Configuration

Optimized for IPTV streaming:
- Minimum buffer: 15 seconds
- Maximum buffer: 50 seconds
- Playback buffer: 2.5 seconds
- Rebuffer threshold: 5 seconds

## Player Toggle

Users can switch between players using the toggle button in the video player screen:

- **Awesome Player**: Green indicator, modern controls
- **Legacy Player**: Orange indicator, Chewie-based

## Error Handling

The implementation provides comprehensive error handling:

1. **Network Errors**: Automatic retry with exponential backoff
2. **Stream Errors**: Clear error messages with retry options
3. **Initialization Errors**: Graceful fallback to legacy player
4. **Resource Cleanup**: Proper disposal of controllers and streams

## Testing

Run the video service tests:

```bash
flutter test test/iptv_video_service_test.dart
```

## Dependencies

### Added Dependencies
```yaml
awesome_video_player: ^2.0.10
```

### Existing Dependencies
```yaml
video_player: ^2.9.2  # Maintained for compatibility
chewie: ^1.8.5        # Legacy player support
```

## Migration Guide

### For Existing Users
No migration is required. The implementation maintains full backward compatibility with the existing video player.

### For New Features
To use Awesome Video Player features:

1. Update to the latest version
2. Use the toggle button to switch to Awesome Player
3. Enjoy enhanced streaming capabilities

## Troubleshooting

### Common Issues

1. **Player Not Loading**
   - Check network connectivity
   - Verify stream URL format
   - Ensure proper authentication headers

2. **Toggle Not Working**
   - Restart the video player screen
   - Check for error messages
   - Try the legacy player option

3. **Fullscreen Issues**
   - Ensure system UI mode permissions
   - Check device orientation settings
   - Try double-tap gesture

### Debug Information

The player status is displayed in the channel info section:
- **Player: Awesome** (green) - Using Awesome Video Player
- **Player: Legacy** (orange) - Using Chewie player

## Future Enhancements

- [ ] Subtitle support
- [ ] Multiple audio track selection
- [ ] Picture-in-picture mode
- [ ] Adaptive streaming quality
- [ ] Offline viewing capabilities
- [ ] Chromecast support

## Support

For issues related to the Awesome Video Player integration, please:

1. Check the error messages in the player
2. Try toggling to the legacy player
3. Review the debug information
4. Report issues with detailed logs