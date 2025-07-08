import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'ui/screens/athkar_screen.dart';
import 'ui/screens/quran_screen.dart';
import 'ui/screens/prayers_screen.dart';
import 'dart:ui';

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
        home: const MainScaffold(),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static final List<Widget Function(ScrollController)> _screenBuilders = [
    (controller) => AthkarScreen(scrollController: controller),
    (controller) => QuranScreen(),
    (controller) => PrayersScreen(scrollController: controller),
  ];

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final ScrollController _scrollController = ScrollController();
  double _slideValue = 0.0; // 0 = shown, 1 = fully hidden

  static const double _hideDistance = 64.0; // nav bar height

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.position.pixels;
    double newSlide = (offset / _hideDistance).clamp(0.0, 1.0);
    if (newSlide != _slideValue) {
      setState(() => _slideValue = newSlide);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<BottomNavProvider>(context);
    final double translateY = _slideValue * (_hideDistance + 32); // 32 for shadow/extra
    return Scaffold(
      body: Stack(
        children: [
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
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
      backgroundColor: Colors.white,
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
            color: Colors.grey.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black12, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
