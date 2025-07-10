import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../data/verses.dart';
import '../widgets/category_button.dart';
import 'package:islamicapp/ui/widgets/swipable_card.dart';
import '../widgets/tasbeeh_counter_page.dart';

class AthkarScreen extends StatelessWidget {
  final ScrollController? scrollController;
  const AthkarScreen({super.key, this.scrollController});

  String getHijriDate() {
    final hijri = HijriCalendar.now();
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH';
  }

  @override
  Widget build(BuildContext context) {
    final weekday = DateTime.now().weekday;
    final verse = versesOfTheDay[(weekday - 1) % versesOfTheDay.length];
    final dua = palestineDuas[(weekday - 1) % palestineDuas.length];
    return Column(
      children: [
        AppBar(
          title: Text('Athkar', style: GoogleFonts.poppins(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: AppConstants.spacing16),
              // Swipable Verse/Dua Card
              SizedBox(
                height: AppConstants.verseCardHeight + 8,
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
              const SizedBox(height: AppConstants.spacing16),
              // Hijri Date Row with separators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(
                        thickness: 1.2,
                        endIndent: 12,
                        color: Color(0xFFB2C2B9),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        getHijriDate(),
                        style: GoogleFonts.poppins(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 1.2,
                        indent: 12,
                        color: Color(0xFFB2C2B9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              // Category List
              const CategoryButton(
                icon: Icons.wb_sunny_outlined,
                title: 'Morning Athkar',
              ),
              SizedBox(height: 8),
              const CategoryButton(
                icon: Icons.bed_outlined,
                title: 'Sleep Athkar',
              ),
              SizedBox(height: 8),
              const CategoryButton(
                icon: Icons.wb_twilight,
                title: 'Waking Up Athkar',
              ),
              SizedBox(height: 8),
              const CategoryButton(
                icon: Icons.self_improvement,
                title: 'Duas After Prayer',
              ),
              SizedBox(height: 8),
              CategoryButton(
                icon: Icons.exposure,
                title: 'Tasbeeh Counter',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TasbeehCounterPage()),
                  );
                },
              ),
              SizedBox(height: 8),
              const CategoryButton(
                icon: Icons.nights_stay_outlined,
                title: 'Evening Athkar',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
} 