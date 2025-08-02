class AppConstants {
  // App Information
  static const String appName = 'IPTV Flutter';
  static const String appVersion = '1.0.0';
  
  // Cache Configuration
  static const Duration defaultCacheDuration = Duration(hours: 6);
  static const Duration serverInfoCacheDuration = Duration(hours: 24);
  
  // Network Configuration
  static const int connectionTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // UI Configuration
  static const int channelsPerPage = 20;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  
  // Video Player Configuration
  static const Duration playerSeekDuration = Duration(seconds: 10);
  static const Duration playerControlsTimeout = Duration(seconds: 3);
  
  // Grid Configuration
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = 8.0;
  static const double gridAspectRatio = 0.75;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Debounce Durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  
  // Error Messages
  static const String connectionError = 'Connection failed. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidCredentials = 'Invalid credentials. Please check your username and password.';
  static const String noChannelsFound = 'No channels found.';
  static const String noCategoriesFound = 'No categories found.';
  
  // Success Messages
  static const String profileSaved = 'Profile saved successfully.';
  static const String profileDeleted = 'Profile deleted successfully.';
  static const String connectionSuccessful = 'Connection test successful.';
  
  // Validation
  static const int minPasswordLength = 3;
  static const int maxProfileNameLength = 50;
  
  // File Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
  
  // URLs
  static const String supportEmail = 'support@iptvflutter.com';
  static const String privacyPolicyUrl = 'https://iptvflutter.com/privacy';
  static const String termsOfServiceUrl = 'https://iptvflutter.com/terms';
}