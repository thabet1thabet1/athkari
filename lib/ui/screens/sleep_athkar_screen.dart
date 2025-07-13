import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../main.dart' show AppBackground;

class SleepAthkarScreen extends StatefulWidget {
  const SleepAthkarScreen({super.key});

  @override
  State<SleepAthkarScreen> createState() => _SleepAthkarScreenState();
}

class _SleepAthkarScreenState extends State<SleepAthkarScreen> {
  int currentAthkarIndex = 0;

  final List<Map<String, dynamic>> sleepAthkar = [
    {
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'translation': 'In Your name, O Allah, I die and I live.',
      'count': 1,
    },
    {
      'arabic': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      'translation': 'O Allah, save me from Your punishment on the Day You resurrect Your slaves.',
      'count': 1,
    },
    {
      'arabic': 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
      'translation': 'O Allah, in Your name I die and I live.',
      'count': 1,
    },
    {
      'arabic': 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ...',
      'translation': 'O Allah, I have submitted myself to You...',
      'count': 1,
    },
    {
      'arabic': 'سُبْحَانَ اللَّهِ',
      'translation': 'Glory be to Allah',
      'count': 33,
    },
    {
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'translation': 'All praise is due to Allah',
      'count': 33,
    },
    {
      'arabic': 'اللَّهُ أَكْبَرُ',
      'translation': 'Allah is the Greatest',
      'count': 34,
    },
  ];

  void nextAthkar() {
    if (currentAthkarIndex < sleepAthkar.length - 1) {
      setState(() {
        currentAthkarIndex++;
      });
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Well done!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text('You have completed the Sleep Athkar', style: GoogleFonts.poppins(fontSize: 18)),
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

  @override
  Widget build(BuildContext context) {
    final currentAthkar = sleepAthkar[currentAthkarIndex];
    return Stack(
      children: [
        const AppBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Sleep Athkar',
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
                LinearProgressIndicator(
                  value: (currentAthkarIndex + 1) / sleepAthkar.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                ),
                SizedBox(height: AppConstants.spacing24 + 12),
                SizedBox(
                  height: 500,
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
                SizedBox(height: AppConstants.spacing24 * 2),
                Row(
                  children: [
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
                    SizedBox(width: AppConstants.spacing24),
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