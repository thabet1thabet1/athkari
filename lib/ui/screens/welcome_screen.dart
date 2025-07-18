import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/theme.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  
  const WelcomeScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with the same image as main app
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/IMG_1323.PNG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White overlay for better readability
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Welcome Title (English only) - positioned like other page titles
                  const SizedBox(height: 50),
                  Text(
                    'Welcome to Athkar App',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Arabic Text
                  Container(
                    width: double.infinity,
                    child: Text(
                      'هذا التطبيق غير ربحي بالكامل، ولا يحتوي على أي إعلانات أو مصادر للربح. تم تطويره بالكامل من قِبل ثابت شارف خوجة، ونُشر من قِبل [اسم] كصدقة جارية نرجو أن ينفعنا الله بها في دنيانا وآخرتنا.',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        height: 1.8,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // English Text
                  Container(
                    width: double.infinity,
                    child: Text(
                      'This application is entirely non-profit, with no advertisements or sources of income. It was fully developed by Thabet Charef Khodja and published by [Name] as a form of ongoing charity (sadaqah jariyah). We pray that Allah allows it to benefit us in our dunya and akhirah.',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        height: 1.6,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: AppColors.forestGreen.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to App',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 