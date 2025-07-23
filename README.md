# Islamic App (Athkari)

A comprehensive Islamic application built with Flutter that provides various Islamic features including prayers, Quran, Athkar, and more.

## Features

### Prayer Times & Qibla
- Accurate prayer times based on location
- Qibla compass direction
- Prayer notifications

### Quran
- Complete Quran text with Arabic and English names
- **NEW: Download functionality for all surahs (except Al-Fatiha)**
  - Click the download button on any surah to be redirected to legitimate Quran websites
  - Choose from multiple websites including Quran.com, SurahQuran.com, and more
  - All websites offer Noreen recitation
  - Users can download surahs individually to keep app size small

### Athkar (Remembrance)
- Morning and Evening Athkar
- After Prayer Duas
- Sleep and Waking Up Athkar
- Tasbeeh counter

### Location Services
- Automatic location detection for prayer times
- Qibla direction calculation

## Quran Download Feature

The app now includes a download feature for all surahs except Al-Fatiha (which is already included in the app). Here's how it works:

1. **Navigate to Quran Screen**: Go to the Quran section in the app
2. **Switch to Listen Mode**: Toggle from "Read" to "Listen" mode
3. **Find Your Surah**: Browse or search for the surah you want to download
4. **Download**: Click the download button (green circle with download icon) next to any surah
5. **Confirmation**: A dialog will appear showing the surah name and asking for confirmation
6. **Choose Website**: Select from multiple legitimate Quran websites
7. **Download**: You'll be redirected to the chosen website where you can download the surah

### Supported Websites
- **Quran.com** - Official Quran website
- **SurahQuran.com** - Dedicated Quran recitation site
- **Quran-Explorer.com** - Comprehensive Quran resource
- **Al-Quran.info** - Islamic Quran platform

All websites offer high-quality Noreen recitation and are legitimate sources for Quran downloads.

## Technical Details

### Dependencies Added
- `url_launcher: ^6.2.5` - For opening external websites

### Platform Permissions
- **Android**: Added internet permission and URL scheme queries
- **iOS**: Added LSApplicationQueriesSchemes for HTTP/HTTPS

### Architecture
- `QuranDownloadService` - Handles all download-related functionality
- Confirmation dialogs for user safety
- Website selection for user choice
- Error handling for failed URL launches

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Testing

Run the tests with:
```bash
flutter test
```

The Quran download functionality is tested in `test/quran_download_test.dart`.

## Contributing

Feel free to contribute to this project by submitting issues or pull requests.

## License

This project is licensed under the MIT License.
