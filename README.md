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
- **Dual Video Players**: Choose between Awesome Video Player and legacy Chewie player
- **HLS Streaming**: Support for HLS video streams with enhanced IPTV features
- **Custom HTTP Headers**: Advanced authentication and streaming header support
- **Category Navigation**: Organized content browsing by categories
- **Live & VOD**: Support for both live TV and video-on-demand content
- **Enhanced Controls**: IPTV-optimized controls with fullscreen support

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
- **IPTVVideoService**: Advanced video player management with Awesome Video Player
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
3. **Choose player** - Toggle between Awesome Video Player and legacy Chewie player
4. **Watch content** - Tap any channel to start streaming
5. **Player controls** - Use enhanced IPTV-optimized controls
6. **Full-screen mode** - Double-tap the player or use the fullscreen button

### Managing Profiles

- **Switch profiles** - Tap the profile icon in the app bar
- **Edit profiles** - Use the menu on profile cards
- **Test connections** - Verify profile connectivity anytime
- **Delete profiles** - Remove unused profiles

## 🎥 Video Player Features

The app now includes dual video player support with enhanced IPTV capabilities:

### Awesome Video Player (Recommended)
- **Modern Implementation**: Latest video player technology optimized for IPTV
- **Custom HTTP Headers**: Enhanced authentication and streaming support  
- **Improved Buffering**: Optimized buffer configuration for live streams
- **Enhanced Controls**: IPTV-specific controls with live/VOD detection
- **Better Error Handling**: Advanced error recovery and retry mechanisms

### Legacy Chewie Player
- **Fallback Option**: Maintained for compatibility
- **Proven Stability**: Well-tested video player implementation
- **Standard Controls**: Traditional video player controls

### Player Toggle
Users can switch between players at runtime using the toggle button in the video player interface. The active player is indicated by a colored status indicator:
- **Green "Awesome"**: Using Awesome Video Player
- **Orange "Legacy"**: Using Chewie player

For detailed information about the video player implementation, see [AWESOME_VIDEO_PLAYER.md](AWESOME_VIDEO_PLAYER.md).

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
│   │   ├── iptv_video_service.dart
│   │   ├── profile_service.dart
│   │   └── tmdb_service.dart
│   ├── widgets/            # Reusable components
│   │   ├── awesome_video_player_widget.dart
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
  
  # Video Player
  video_player: ^2.9.2
  chewie: ^1.8.5
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
