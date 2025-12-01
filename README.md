# WatchTheFlix

<p align="center">
  <img src="assets/images/logo.png" alt="WatchTheFlix Logo" width="120"/>
</p>

<p align="center">
  <strong>Your Ultimate IPTV Experience</strong>
</p>

<p align="center">
  A modern, cross-platform Flutter IPTV client for streaming live TV, movies, and series.
</p>

---

## 🌟 Features

### Core Features
- **Multi-Platform Support**: Android, iOS, Windows, macOS, Linux, and Android TV
- **IPTV Source Support**: 
  - M3U playlist (URL and local file import)
  - Xtream Codes API (modern and legacy endpoints)
- **Multiple Profiles**: Support for multiple IPTV providers and user profiles
- **Electronic Program Guide (EPG)**: Live EPG data with timeline overlay in player

### Content
- **Live TV**: Channel listings with EPG now/next display
- **Movies (VOD)**: Poster grid with metadata enrichment
- **TV Series**: Show → Season → Episode navigation
- **Favorites**: Mark channels, movies, and series as favorites
- **Continue Watching**: Track watch progress and resume playback

### User Experience
- **Modern Dark Theme**: GitHub-inspired dark color palette
- **Smooth Animations**: Polished transitions and UI interactions
- **Search**: Search across channels, movies, and series
- **Responsive Design**: Adapts to mobile, tablet, and desktop layouts

### Security & Privacy
- **Parental Controls**: PIN-protected content restrictions
- **Secure Storage**: Credentials stored using platform-secure storage
- **No Credential Logging**: Sensitive data is never logged

### Technical
- **Notification Ready**: Infrastructure prepared for Firebase Cloud Messaging
- **Metadata Enrichment**: Extensible metadata service layer
- **CI/CD**: Automated builds and tests via GitHub Actions
- **Dependabot**: Automated dependency updates

---

## 📱 Screenshots

| Home | Live TV | Movies | Player |
|------|---------|--------|--------|
| ![Home](docs/screenshots/home.png) | ![Live TV](docs/screenshots/live_tv.png) | ![Movies](docs/screenshots/movies.png) | ![Player](docs/screenshots/player.png) |

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Visual Studio / Build Tools (for Windows development)

#### Windows Development Setup
For Windows development, ensure you have:
1. **Visual Studio 2022** (Community Edition or higher) with the "Desktop development with C++" workload
2. **NuGet CLI** - Required for some Flutter plugins (e.g., `flutter_inappwebview_windows`)
   - Download from [nuget.org/downloads](https://www.nuget.org/downloads)
   - Place `nuget.exe` in a folder (e.g., `C:\Tools\NuGet`)
   - Add the folder to your system PATH
   - Verify installation: `nuget -v`

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/GitGoneWild/IPTV-App.git
   cd IPTV-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For mobile
   flutter run

   # For desktop
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 📁 Project Structure

```
lib/
├── app.dart                    # Main application widget
├── main.dart                   # Entry point
├── core/
│   ├── config/
│   │   ├── app_router.dart     # Navigation configuration
│   │   └── app_theme.dart      # Theme configuration
│   ├── constants/
│   │   ├── app_colors.dart     # Color palette
│   │   ├── app_dimensions.dart # Spacing and sizing
│   │   ├── app_strings.dart    # Text constants
│   │   └── app_text_styles.dart# Typography
│   ├── services/
│   │   ├── http_service.dart   # HTTP client
│   │   ├── m3u_parser_service.dart # M3U playlist parser
│   │   ├── notification_service.dart # Push notifications
│   │   ├── storage_service.dart # Local storage
│   │   └── xtream_service.dart # Xtream Codes API
│   └── widgets/
│       └── main_shell.dart     # Navigation shell
├── data/
│   ├── datasources/
│   │   ├── metadata_provider.dart # Metadata abstraction
│   │   ├── metadata_service.dart  # Metadata aggregation
│   │   └── omdb_provider.dart     # OMDb implementation
│   └── models/
│       ├── category_model.dart
│       ├── channel_model.dart
│       ├── epg_model.dart
│       ├── movie_model.dart
│       ├── profile_model.dart
│       ├── provider_model.dart
│       └── series_model.dart
└── features/
    ├── home/                   # Home/Dashboard screen
    ├── live_tv/                # Live TV listings
    ├── movies/                 # Movies catalog
    ├── onboarding/             # First-time setup
    ├── parental/               # Parental controls
    ├── player/                 # Video player
    ├── profiles/               # Profile management
    ├── series/                 # TV series catalog
    ├── settings/               # App settings
    └── splash/                 # Splash screen
```

---

## 🔧 Configuration

### Adding IPTV Sources

The app supports two types of IPTV sources:

#### M3U Playlist
1. Go to Settings → IPTV Accounts → Add Account
2. Select "M3U Playlist"
3. Enter the playlist URL
4. Optionally add an EPG URL
5. Click "Save & Continue"

#### Xtream Codes
1. Go to Settings → IPTV Accounts → Add Account
2. Select "Xtream Codes"
3. Enter server URL, username, and password
4. Click "Validate" to test connection
5. Click "Save & Continue"

### Metadata Enrichment

The app includes an extensible metadata service. To enable metadata enrichment:

1. Get an API key from [OMDb](http://www.omdbapi.com/apikey.aspx) (free tier available)
2. Configure in the app settings (coming soon) or programmatically:

```dart
MetadataService.instance.configureOmdb('YOUR_API_KEY');
```

### Push Notifications

The notification infrastructure is ready for Firebase integration:

1. Create a Firebase project
2. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Uncomment the Firebase configuration in `notification_service.dart`

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## 🛣️ Roadmap

### Current Limitations
- [ ] Web platform support (requires video player compatibility)
- [ ] Real-Debrid integration (designed for future implementation)
- [ ] Full monetization/paywall system
- [ ] Analytics and tracking setup

### Future Enhancements
- [ ] Real-Debrid and Premiumize integration
- [ ] Multiple video player options (VLC, ExoPlayer)
- [ ] Picture-in-Picture mode
- [ ] Chromecast/AirPlay support
- [ ] Recording functionality (where supported)
- [ ] Multi-language interface
- [ ] Cloud sync for favorites and watch history
- [ ] Custom EPG sources
- [ ] Channel sorting and custom groups

---

## 🏗️ Architecture

The app follows a layered architecture pattern:

- **Presentation Layer**: Flutter widgets and screens
- **Business Logic**: BLoC pattern for state management (prepared)
- **Data Layer**: Models, repositories, and data sources
- **Services Layer**: HTTP client, storage, parsers, etc.

Key design decisions:
- **Dependency Injection Ready**: Services can be easily mocked for testing
- **Provider Abstraction**: Metadata providers are abstracted for easy swapping
- **Secure Storage**: Sensitive data uses platform-secure storage APIs
- **Offline First**: Data is cached locally for offline access

---

## 🔐 Security

- Credentials are stored using `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android)
- Parental control PINs are stored securely and never logged
- HTTPS is recommended for all IPTV sources
- No telemetry or analytics are collected without explicit consent

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/GitGoneWild/IPTV-App/issues)
- **Discussions**: [GitHub Discussions](https://github.com/GitGoneWild/IPTV-App/discussions)

---

## ⚠️ Disclaimer

This application is a media player/client. It does not provide any content. Users are responsible for the legality of the content they access through this application. The developers of this application do not host, provide, or take responsibility for any content accessed through this application.

---

<p align="center">
  Made with ❤️ using Flutter
</p>