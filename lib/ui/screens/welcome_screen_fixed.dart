import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isNavigating = false;

  Future<void> _continueToApp() async {
    if (_isNavigating) return;
    setState(() { _isNavigating = true; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainScaffoldWithIndex(initialIndex: 0),
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
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 50.h),
                          Text(
                            'Welcome to Athkar App',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.forestGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 40.h),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'هذا التطبيق غير ربحي بالكامل، ولا يحتوي على أي إعلانات أو مصادر للربح. تم تطويره بالكامل من قِبل ثابت شارف خوجة، ونُشر من قِبل احمد السيد روشبيك كصدقة جارية نرجو أن ينفعنا الله بها في دنيانا وآخرتنا.',
                              style: GoogleFonts.cairo(
                                fontSize: 18.sp,
                                height: 1.7,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'This application is entirely non-profit, with no advertisements or sources of income. It was fully developed by Thabet Charef Khodja and published by Ahmed Elsayed Roshbaik as a form of ongoing charity (sadaqah jariyah). We pray that Allah allows it to benefit us in our dunya and akhirah.',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                height: 1.5,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isNavigating ? null : _continueToApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        shadowColor: AppColors.forestGreen.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to App',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_forward, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
