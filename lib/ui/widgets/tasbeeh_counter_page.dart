import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class TasbeehCounterPage extends StatefulWidget {
  @override
  State<TasbeehCounterPage> createState() => _TasbeehCounterPageState();
}

class _TasbeehCounterPageState extends State<TasbeehCounterPage> {
  int counter = 0;
  int total = 0;

  void _increment() {
    setState(() {
      counter++;
      total++;
      if (counter > 33) {
        counter = 0;
      }
    });
  }

  void _reset() {
    setState(() {
      counter = 0;
      total = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // App background (reuse from main)
          const _TasbeehAppBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 26),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Tasbeeh Counter',
                        style: TextStyle(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.black, size: 26),
                        onPressed: _reset,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Dhikr container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.forestGreen, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestGreen.withOpacity(0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'سبحان الله و بحمده',
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 38,
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 80),
                Center(
                  child: GestureDetector(
                    onTap: _increment,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(80),
                        border: Border.all(color: AppColors.forestGreen, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withOpacity(0.13),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$counter',
                          style: const TextStyle(
                            fontSize: 60,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 53),
                Text(
                  'Tap the circle to count',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 85),
                // Total count horizontal and bold, moved up
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.forestGreen, width: 3.5),
                  ),
                  child: Text(
                    'Total Counts: $total',
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Center(
                    child: Text(
                      'لا تنسو اخوانكم في فلسطين من صالح دعائكم',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the app background for consistency
class _TasbeehAppBackground extends StatelessWidget {
  const _TasbeehAppBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Image background (same as main)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/IMG_1323.PNG'), // Use your main background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White overlay
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