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

void main() {
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Athkar App',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
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
    // Check if this is the first time
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('has_seen_welcome') != true;
    
    // Check if location permission was previously granted
    bool wasGranted = await LocationService.wasLocationPermissionGranted();
    
    if (!wasGranted) {
      // Show location permission dialog after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _showLocationPermissionDialog();
        return;
      }
    }
    
    _proceedToMainApp();
  }

  Future<void> _checkLocationPermission() async {
    // Check if location permission was previously granted
    bool wasGranted = await LocationService.wasLocationPermissionGranted();
    
    if (!wasGranted) {
      // Show location permission dialog after a short delay
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
          await LocationService.getCurrentLocation(forceRequest: true);
          if (mounted) {
            _proceedToMainApp();
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
                pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(
                  onContinue: () async {
                    // Mark that user has seen welcome screen
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_seen_welcome', true);
                    
                    // Navigate to main app
                    if (mounted) {
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
                          transitionDuration: const Duration(milliseconds: 800),
                        ),
                      );
                    }
                  },
                ),
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
    setState(() { _showAudioPlayer = true; });
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
                surahName: 'الفاتحة',
                englishName: 'Al-Fatiha',
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
