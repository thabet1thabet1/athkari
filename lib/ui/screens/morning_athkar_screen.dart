import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../main.dart' show AppBackground;

class MorningAthkarScreen extends StatefulWidget {
  const MorningAthkarScreen({super.key});

  @override
  State<MorningAthkarScreen> createState() => _MorningAthkarScreenState();
}

class _MorningAthkarScreenState extends State<MorningAthkarScreen> {
  int currentAthkarIndex = 0;
  int currentCount = 0;

  final List<Map<String, dynamic>> morningAthkar = [
    {
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'translation': 'Glory be to Allah and His is the praise',
      'count': 100,
    },
    {
      'arabic': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      'translation': 'I seek forgiveness from Allah and repent to Him',
      'count': 100,
    },
    {
      'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'translation': 'There is no deity except Allah, alone without partner. To Him belongs dominion and to Him belongs [all] praise, and He is over all things competent',
      'count': 10,
    },
    {
      'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      'translation': 'O Allah, send prayers upon Muhammad and the family of Muhammad',
      'count': 100,
    },
    {
      'arabic': 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      'translation': 'Glory be to Allah, and praise be to Allah, and there is no deity except Allah, and Allah is the Greatest',
      'count': 33,
    },
    {
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'translation': 'There is no power and no strength except with Allah',
      'count': 100,
    },
    {
      'arabic': 'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ وَأُشْهِدُ حَمَلَةَ عَرْشِكَ وَمَلَائِكَتَكَ وَجَمِيعَ خَلْقِكَ أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
      'translation': 'O Allah, I have reached the morning and at this very time all those who are in Your heavens and earth bear witness that You are Allah, there is no god but You, the One, the Self-Sufficient Master, Who has no partner, and that Muhammad is Your servant and Your Messenger',
      'count': 4,
    },
  ];

  void nextAthkar() {
    if (currentAthkarIndex < morningAthkar.length - 1) {
      setState(() {
        currentAthkarIndex++;
        currentCount = 0;
      });
    } else {
      // Show completion dialog (iPhone style, English)
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Well done!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text('You have completed the Morning Athkar', style: GoogleFonts.poppins(fontSize: 18)),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Done', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.forestGreen)),
            ),
          ],
        ),
      );
    }
  }

  void incrementCount() {
    if (currentCount < morningAthkar[currentAthkarIndex]['count']) {
      setState(() {
        currentCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAthkar = morningAthkar[currentAthkarIndex];
    
    return Stack(
      children: [
        const AppBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Morning Athkar',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.forestGreen,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppColors.forestGreen),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (currentAthkarIndex + 1) / morningAthkar.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                ),
                SizedBox(height: AppConstants.spacing24 + 12), // More space above card
                // Main Athkar Card
                SizedBox(
                  height: 500,
                  child: GestureDetector(
                    onTap: null, // No tap
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                        border: Border.all(
                          color: AppColors.forestGreen,
                          width: 3.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Arabic Text
                            Text(
                              currentAthkar['arabic'],
                              style: GoogleFonts.amiri(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forestGreen,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: AppConstants.spacing16),
                            // Translation
                            Text(
                              currentAthkar['translation'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.spacing24 * 2), // Larger gap between card and buttons
                // Counter and Next Button Row
                Row(
                  children: [
                    // Counter Display
                    Expanded(
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                          border: Border.all(
                            color: AppColors.forestGreen,
                            width: 2.0,
                          ),
                        ),
                        child: Text(
                          '${currentAthkar['count']} times',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacing24), // Larger gap between buttons
                    // Next Button
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: nextAthkar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 