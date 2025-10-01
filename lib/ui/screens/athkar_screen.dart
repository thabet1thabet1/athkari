import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../data/verses.dart';
import '../widgets/category_button.dart';
import '../widgets/swipable_card.dart';
import '../widgets/tasbeeh_counter_page.dart';
import 'morning_athkar_screen.dart';
import 'sleep_athkar_screen.dart';
import 'waking_up_athkar_screen.dart';
import 'after_prayer_duas_screen.dart';
import 'evening_athkar_screen.dart';

class AthkarScreen extends StatelessWidget {
  final ScrollController? scrollController;
  const AthkarScreen({super.key, this.scrollController});

  String getHijriDate() {
    final hijri = HijriCalendar.now();
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH';
  }

  @override
  Widget build(BuildContext context) {
    // Use daily system instead of weekday
    final verse = getDailyVerse();
    final dua = getDailyPalestineDua();
    return Column(
      children: [
        AppBar(
          title: Text('Athkar', style: GoogleFonts.poppins(color: AppColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 22.sp)),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 50.h,
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: AppConstants.spacing8),
              // Swipable Verse/Dua Card
              SizedBox(
                height: AppConstants.verseCardHeight + 6.h,
                child: PageView(
                  controller: PageController(viewportFraction: 0.93),
                  children: [
                    SwipableCard(
                      label: "📖 Today's Verse",
                      content: verse['verse']!,
                      source: verse['source']!,
                      icon: Icons.auto_awesome,
                      borderColor: AppColors.forestGreen,
                      textColor: Colors.black.withValues(alpha: 0.7),
                      fontFamily: 'Amiri',
                    ),
                    SwipableCard(
                      label: "🙏 Today's Dua (for Palestine)",
                      content: dua['dua']!,
                      source: dua['source']!,
                      icon: Icons.favorite,
                      borderColor: AppColors.forestGreen,
                      textColor: Colors.black.withValues(alpha: 0.7),
                      fontFamily: 'Amiri',
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppConstants.spacing8),
              // Hijri Date Row with separators
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.2.h,
                        endIndent: 12.w,
                        color: Color(0xFFB2C2B9),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 3.r,
                            offset: Offset(0, 1.h),
                          ),
                        ],
                      ),
                      child: Text(
                        getHijriDate(),
                        style: GoogleFonts.poppins(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1.2.h,
                        indent: 12.w,
                        color: Color(0xFFB2C2B9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppConstants.spacing8),
              // Category List
              CategoryButton(
                icon: Icons.wb_sunny_outlined,
                title: 'Morning Athkar',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MorningAthkarScreen()),
                  );
                },
              ),
              SizedBox(height: 6.h),
              CategoryButton(
                icon: Icons.bed_outlined,
                title: 'Sleep Athkar',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SleepAthkarScreen()),
                  );
                },
              ),
              SizedBox(height: 6.h),
              CategoryButton(
                icon: Icons.wb_twilight,
                title: 'Waking Up Athkar',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => WakingUpAthkarScreen()),
                  );
                },
              ),
              SizedBox(height: 6.h),
              CategoryButton(
                icon: Icons.self_improvement,
                title: 'Duas After Prayer',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AfterPrayerDuasScreen()),
                  );
                },
              ),
              SizedBox(height: 6.h),
              CategoryButton(
                icon: Icons.exposure,
                title: 'Tasbeeh Counter',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TasbeehCounterPage()),
                  );
                },
              ),
              SizedBox(height: 6.h),
              CategoryButton(
                icon: Icons.nights_stay_outlined,
                title: 'Evening Athkar',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EveningAthkarScreen()),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }
} 