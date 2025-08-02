# IPTV Flutter 📺

A comprehensive Flutter IPTV application with multi-profile support, smart caching, and a modern Material Design 3 interface. Built specifically for Android devices with a portrait-focused UI.

## ✨ Features

### 🎭 Multi-Profile System
- **Secure Storage**: Credentials stored securely using Flutter Secure Storage
- **Multiple Providers**: Support for multiple IPTV providers with easy switching
- **Connection Testing**: Built-in connection validation for profiles
- **Profile Management**: Full CRUD operations with intuitive UI

### 🧠 Smart Caching Architecture
- **SQLite Backend**: Robust local caching with SQLite database
- **Profile Isolation**: Separate cache for each profile to prevent data mixing
- **Configurable Duration**: Customizable cache expiration (default: 6 hours)
- **Automatic Cleanup**: Background cleanup of expired cache entries

### 📺 IPTV Streaming
- **Xtream Codes API**: Full integration with Xtream Codes protocol
- **VLC Media Player**: Advanced video player with superior IPTV compatibility
- **HLS Streaming**: Support for HLS, DASH, MP4, and multiple streaming formats
- **Advanced HTTP Headers**: Comprehensive authentication and streaming header support
- **Category Navigation**: Organized content browsing by categories
- **Live & VOD**: Support for both live TV and video-on-demand content
- **Professional Controls**: VLC-powered controls with fullscreen support

### 🎨 Modern UI/UX
- **Material Design 3**: Latest Material Design guidelines
- **Dark/Light Theme**: Automatic theme switching based on system preference
- **Portrait Optimized**: Designed primarily for portrait mode on mobile devices
- **Responsive Grid**: Adaptive layouts that work on different screen sizes

### 🔍 Enhanced Discovery
- **Search Functionality**: Real-time search across all channels
- **Category Filtering**: Filter channels by categories
- **TMDB Integration**: Enhanced metadata with movie/TV show information (optional)

## 🏗️ Architecture

### Clean Architecture Pattern
```
lib/
├── models/           # Data models with JSON serialization
├── services/         # Business logic and external API integration
├── providers/        # State management with Provider pattern
├── screens/          # UI screens and pages
├── widgets/          # Reusable UI components
├── config/           # App configuration (themes, constants)
└── utils/            # Utility functions and helpers
```

### Key Components

#### Models
- **Profile**: User profile with IPTV credentials
- **Channel**: TV channel or VOD content
- **Category**: Content categorization

#### Services
- **ProfileService**: Profile management and storage
- **IPTVService**: IPTV API integration and streaming
- **VLCVideoService**: Professional-grade video player management with VLC Media Player
- **CacheService**: Smart caching with SQLite
- **TMDBService**: Movie/TV metadata enhancement

#### Providers (State Management)
- **ProfileProvider**: Profile state and operations
- **IPTVProvider**: Channel data and filtering

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Android Studio / VS Code
- Android device or emulator (API level 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/iptv-flutter.git
   cd iptv-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment (optional)**
   ```bash
   cp .env.example .env
   # Edit .env with your TMDB API key if desired
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Environment Configuration

Create a `.env` file from `.env.example` to configure optional features:

```env
# TMDB API for enhanced metadata (optional)
TMDB_API_KEY=your_api_key_here
TMDB_BASE_URL=https://api.themoviedb.org/3

# Cache configuration
DEFAULT_CACHE_DURATION=21600  # 6 hours in seconds
MAX_RETRY_ATTEMPTS=3
CONNECTION_TIMEOUT=30000      # 30 seconds
```

## 📱 Usage

### Setting Up Your First Profile

1. **Launch the app** - You'll see the splash screen followed by profile management
2. **Add a new profile** - Tap the "+" button
3. **Enter your IPTV details**:
   - Profile Name: A friendly name for identification
   - Server URL: Your IPTV provider's server URL
   - Username: Your IPTV username
   - Password: Your IPTV password
   - Logo URL: Optional logo for the profile
4. **Test connection** - Use the test button to verify connectivity
5. **Save and activate** - Save the profile and set it as active

### Streaming Content

1. **Browse categories** - Use the horizontal category list to filter content
2. **Search channels** - Use the search bar to find specific channels
3. **Watch content** - Tap any channel to start streaming with VLC
4. **Professional controls** - Use VLC's advanced media controls
5. **Full-screen mode** - Automatic landscape mode for optimal viewing
6. **Error handling** - Advanced error recovery and stream diagnostics

### Managing Profiles

- **Switch profiles** - Tap the profile icon in the app bar
- **Edit profiles** - Use the menu on profile cards
- **Test connections** - Verify profile connectivity anytime
- **Delete profiles** - Remove unused profiles

## 🎥 VLC Media Player Features

The app uses VLC Media Player as its core video engine, providing professional-grade streaming capabilities:

### 🚀 VLC Advantages
- **Universal Compatibility**: Supports virtually all video and audio formats
- **Superior IPTV Support**: Excellent handling of HLS, DASH, RTSP, and RTMP streams
- **Hardware Acceleration**: Full hardware acceleration for smooth playback
- **Advanced Buffering**: Intelligent buffering with customizable cache settings
- **Network Resilience**: Robust handling of network interruptions and reconnections
- **Professional Quality**: Industry-standard media player trusted worldwide

### 🔧 Technical Features
- **Multiple Protocol Support**: HTTP, HTTPS, RTSP, RTMP, UDP, and more
- **Custom Headers**: Full support for authentication and streaming headers
- **Adaptive Streaming**: Automatic quality adjustment based on network conditions
- **Error Recovery**: Advanced error handling and automatic retry mechanisms
- **Memory Efficient**: Optimized memory usage for mobile devices

### 🎮 Player Controls
- **Standard Playback**: Play, pause, stop, seek controls
- **Volume Control**: Granular volume adjustment
- **Fullscreen Mode**: Automatic landscape orientation for optimal viewing
- **Stream Information**: Real-time streaming statistics and diagnostics

### 📊 Stream Format Support

| Format | Support Level | Notes |
|--------|---------------|-------|
| HLS (.m3u8) | ✅ Excellent | Perfect for live TV |
| DASH (.mpd) | ✅ Excellent | Adaptive streaming |
| MP4 | ✅ Excellent | Standard video files |
| RTSP | ✅ Excellent | IP cameras and live streams |
| RTMP | ✅ Excellent | Live streaming protocol |
| TS | ✅ Very Good | Transport streams |
| MKV | ✅ Very Good | Container format |
| AVI | ✅ Good | Legacy format |
| FLV | ✅ Good | Flash video |

### 🛠️ IPTV Optimizations
- **Custom User-Agent**: VLC-specific user agent for better server compatibility
- **Network Caching**: Optimized 3-second cache for smooth playback
- **HTTP Reconnect**: Automatic reconnection on network drops
- **TCP for RTSP**: Forced TCP mode for better RTSP compatibility
- **Frame Dropping**: Smart frame dropping for maintaining sync

For detailed technical information, see the VLC implementation in `lib/services/vlc_video_service.dart`.

## 🛠️ Development

### Project Structure

```
├── android/                 # Android-specific files
├── assets/                  # App assets (images, fonts)
├── lib/
│   ├── config/             # Configuration files
│   │   ├── constants.dart  # App constants
│   │   └── theme.dart      # Theme configuration
│   ├── models/             # Data models
│   │   ├── channel.dart    # Channel model
│   │   ├── category.dart   # Category model
│   │   └── profile.dart    # Profile model
│   ├── providers/          # State management
│   │   ├── iptv_provider.dart
│   │   └── profile_provider.dart
│   ├── screens/            # UI screens
│   │   ├── home_screen.dart
│   │   ├── profile_management_screen.dart
│   │   ├── splash_screen.dart
│   │   └── video_player_screen.dart
│   ├── services/           # Business logic
│   │   ├── cache_service.dart
│   │   ├── iptv_service.dart
│   │   ├── vlc_video_service.dart
│   │   ├── profile_service.dart
│   │   └── tmdb_service.dart
│   ├── widgets/            # Reusable components
│   │   ├── vlc_player_widget.dart
│   │   ├── category_list.dart
│   │   ├── channel_grid.dart
│   │   ├── profile_card.dart
│   │   ├── profile_form_dialog.dart
│   │   └── search_bar_widget.dart
│   └── main.dart           # App entry point
├── test/                   # Unit and widget tests
└── pubspec.yaml           # Dependencies and metadata
```

### Key Dependencies

```yaml
dependencies:
  # State Management
  provider: ^6.1.2
  
  # Networking
  http: ^1.2.1
  dio: ^5.4.3+1
  
  # Video Player - VLC Media Player
  flutter_vlc_player: ^7.4.3
  awesome_video_player: ^2.0.10
  
  # Storage
  sqflite: ^2.3.3+1
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.2.3
  
  # UI Enhancement
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/models/profile_test.dart

# Run with coverage
flutter test --coverage
```

### Building for Production

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

## 🔒 Security & Privacy

- **Secure Storage**: All credentials are encrypted using Flutter Secure Storage
- **No Data Collection**: The app doesn't collect or transmit personal data
- **Local Caching**: All cache data is stored locally on the device
- **HTTPS Support**: Secure connections to IPTV providers

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

### Development Guidelines

1. **Code Style**: Follow Dart/Flutter conventions
2. **Testing**: Write tests for new features
3. **Documentation**: Update README for significant changes
4. **Commits**: Use conventional commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Chewie package for video player functionality
- Material Design team for design guidelines
- TMDB for movie/TV metadata API

## 📞 Support

For support and questions:
- 📧 Email: support@iptvflutter.com
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/iptv-flutter/issues)
- 📖 Documentation: [Wiki](https://github.com/your-username/iptv-flutter/wiki)

---

**Made with ❤️ using Flutter**
