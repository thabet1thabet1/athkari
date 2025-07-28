import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/location_service.dart';
import 'ui/screens/athkar_screen.dart';
import 'ui/screens/quran_screen.dart';
import 'ui/screens/prayers_screen.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/widgets/location_permission_dialog.dart';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';
import 'ui/widgets/apple_music_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/quran_download_service.dart';
import 'core/notification_service.dart';
import 'core/prayer_times_service.dart';
import 'data/verses.dart';
import 'package:geolocator/geolocator.dart';

Future<void> rescheduleAllPrayerNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  // Fetch today's prayer times
  final prayerTimes = await PrayerTimesService.getPrayerTimes();
  if (prayerTimes == null) return;
  // List of prayer names in the same order as your UI
  final List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  final List<DateTime?> times = [
    prayerTimes.fajr,
    prayerTimes.dhuhr,
    prayerTimes.asr,
    prayerTimes.maghrib,
    prayerTimes.isha,
  ];
  for (int i = 0; i < prayerNames.length; i++) {
    final enabled = prefs.getBool('prayer_notif_enabled_$i') ?? false;
    final offset = prefs.getInt('prayer_offset_$i') ?? 0;
    final time = times[i];
    if (enabled && time != null) {
      await NotificationService.schedulePrayerNotification(
        id: i + 1,
        title: "It's time for ${prayerNames[i]}",
        body: 'Time to pray ${prayerNames[i]}.',
        scheduledTime: time.add(Duration(minutes: offset)),
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  // Schedule daily athkar notifications
  await NotificationService.scheduleAthkarNotification(
    id: 100,
    title: 'Morning Athkar',
    body: 'Remember to recite your morning athkar.',
    hour: 5,
    minute: 50,
  );
  await NotificationService.scheduleAthkarNotification(
    id: 101,
    title: 'Evening Athkar',
    body: 'Remember to recite your evening athkar.',
    hour: 17,
    minute: 30,
  );
  await NotificationService.scheduleAthkarNotification(
    id: 102,
    title: 'Sleep Athkar',
    body: 'Remember to recite your sleep athkar.',
    hour: 22,
    minute: 0,
  );
  // Reschedule prayer notifications on app start
  await rescheduleAllPrayerNotifications();
  runApp(const MyApp());
}

// Simple provider for bottom navigation index
class BottomNavProvider with ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int idx) {
    _currentIndex = idx;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BottomNavProvider(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Athkar App',
            theme: AppTheme.lightTheme,
            home: const SplashScreen(),
            builder: (context, child) {
              // Force textScaleFactor to 1.0 everywhere
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _locationChecked = false;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _checkFirstTimeAndLocation();
  }

  Future<void> _checkFirstTimeAndLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('has_seen_welcome') != true;

    // Check actual OS permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Show your custom dialog
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _showLocationPermissionDialog();
        return;
      }
    }
    _proceedToMainApp();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _showLocationPermissionDialog();
        return;
      }
    }
    _proceedToMainApp();
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        title: 'Location Access',
        message: 'This app needs location access to provide accurate prayer times and qibla direction for your current location.',
        onAllow: () async {
          Navigator.of(context).pop();
          // Request OS permission
          LocationPermission permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            if (mounted) {
              _proceedToMainApp();
            }
          } else {
            // Permission still denied, stay on dialog or show a message
            if (mounted) {
              _showLocationPermissionDialog();
            }
          }
        },
        onDeny: () {
          Navigator.of(context).pop();
          _proceedToMainApp();
        },
      ),
    );
  }

  void _proceedToMainApp() {
    if (!_locationChecked) {
      _locationChecked = true;
      // Start fade out after location check
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          if (_isFirstTime) {
            // Show welcome screen for first-time users
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 1500),
              ),
            );
          } else {
            // Go directly to main app for returning users
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const MainScaffold(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 1500),
              ),
            );
          }
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/E7CA2E33-394F-4EBE-873D-F072281FF8B7.JPEG'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static final List<Widget Function(ScrollController?)> _screenBuilders = [
    (controller) => AthkarScreen(scrollController: controller),
    (controller) => SizedBox.shrink(), // QuranScreen handled specially
    (controller) => PrayersScreen(scrollController: controller),
  ];

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  double _slideValue = 0.0; // 0 = shown, 1 = fully hidden
  static const double _hideDistance = 64.0; // nav bar height
  final ScrollController _scrollController = ScrollController();
  double _lastOffset = 0.0;
  final bool _isNavHidden = false;

  // Audio player state
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _showAudioPlayer = false;
  Duration? _duration;
  Duration? _position;
  int? _currentSurahIndex;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _audioPlayer = AudioPlayer();
    _audioPlayer.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _audioPlayer.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.position.pixels;
    // The amount to slide: 0 = shown, 1 = fully hidden
    double slide = (offset / _hideDistance).clamp(0.0, 1.0);
    if ((slide - _slideValue).abs() > 0.01) {
      setState(() {
        _slideValue = slide;
      });
    }
    _lastOffset = offset;
  }

  Future<void> _playAlFatiha() async {
    setState(() { _showAudioPlayer = true; _currentSurahIndex = 1; });
    try {
      await _audioPlayer.setAsset('assets/quran/001 Surah Al-Fatiha Sheikh noreen muhammad sadiq.mp3');
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Future<void> _playSurah(int surahIndex) async {
    setState(() { _showAudioPlayer = true; _currentSurahIndex = surahIndex; });
    try {
      String? audioPath;
      if (surahIndex == 1) {
        audioPath = 'assets/quran/001 Surah Al-Fatiha Sheikh noreen muhammad sadiq.mp3';
      } else {
        audioPath = await QuranDownloadService.getSurahFilePath(surahIndex);
      }
      if (audioPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio file not found. Please download the surah.')),
          );
        }
        return;
      }
      if (audioPath.startsWith('assets/')) {
        await _audioPlayer.setAsset(audioPath);
      } else {
        await _audioPlayer.setFilePath(audioPath);
      }
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() { _showAudioPlayer = false; });
  }

  void _seekAudio(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);
    final double translateY = _slideValue * (_hideDistance + 32); // 32 for shadow/extra
    // Get surah name for AppleMusicPlayer
    String surahName = 'الفاتحة';
    String englishName = 'Al-Fatiha';
    if (_currentSurahIndex != null) {
      final surah = surahs.firstWhere((s) => s['index'] == _currentSurahIndex, orElse: () => surahs[0]);
      surahName = surah['arabic'] ?? 'الفاتحة';
      englishName = surah['english'] ?? 'Al-Fatiha';
    }
    return Scaffold(
      body: Stack(
        children: [
          // Custom background layer
          const AppBackground(),
          // Main content
          // Pass the shared ScrollController and _slideValue to each screen
          if (navProvider.currentIndex == 1)
            QuranScreen(
              scrollController: _scrollController,
              slideValue: _slideValue,
              showAudioPlayer: _showAudioPlayer,
              isPlaying: _isPlaying,
              duration: _duration,
              position: _position,
              onPlayAlFatiha: _playAlFatiha,
              onPlaySurah: _playSurah,
              onPlayPause: _togglePlayPause,
              onStopAudio: _stopAudio,
              onSeekAudio: _seekAudio,
            )
          else
            MainScaffold._screenBuilders[navProvider.currentIndex](_scrollController),
          // Glassy background behind nav bar (follows scroll, now taller and moved down)
          Positioned(
            left: 16,
            right: 16,
            bottom: -(140.0 - 64.0),
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: IgnorePointer(
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(90),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Apple Music-style audio player (persistent)
          if (_showAudioPlayer)
            Positioned(
              left: 16,
              right: 16,
              bottom: 105 - (_slideValue * 89),
              child: AppleMusicPlayer(
                surahName: surahName,
                englishName: englishName,
                isPlaying: _isPlaying,
                duration: _duration,
                position: _position,
                onPlayPause: _togglePlayPause,
                onStop: _stopAudio,
                onSeek: _seekAudio,
              ),
            ),
          // Floating Glassmorphic Bottom Bar (follows scroll)
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 16),
                child: GlassNavBar(
                  currentIndex: navProvider.currentIndex,
                  onTap: navProvider.setIndex,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

// Custom background widget with image background
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Image background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/IMG_1323.PNG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White overlay for better text readability
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const GlassNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(46),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color.fromARGB(255, 225, 223, 223), width: 1.5), // gray border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB6EFC6).withOpacity(0.25), // green shadow
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _GlassNavBarItem(
                icon: Icons.list_alt,
                label: 'Athkar',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _GlassNavBarItem(
                icon: Icons.menu_book,
                label: 'Quran',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _GlassNavBarItem(
                icon: Icons.mosque_outlined,
                label: 'Prayers',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GlassNavBarItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          constraints: const BoxConstraints(minWidth: 60, maxWidth: 120, minHeight: 48, maxHeight: 64),
          decoration: BoxDecoration(
            color: selected ? Colors.black.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? Colors.black : Colors.black.withValues(alpha: 0.6),
                size: 28,
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: selected ? Colors.black : Colors.black.withValues(alpha: 0.6),
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this widget below MainScaffold
class MainScaffoldWithIndex extends StatelessWidget {
  final int initialIndex;
  const MainScaffoldWithIndex({super.key, required this.initialIndex});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = BottomNavProvider();
        provider.setIndex(initialIndex);
        return provider;
      },
      child: const MainScaffold(),
    );
  }
}
