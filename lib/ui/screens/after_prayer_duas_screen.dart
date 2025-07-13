import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../main.dart' show AppBackground;

class AfterPrayerDuasScreen extends StatefulWidget {
  const AfterPrayerDuasScreen({super.key});

  @override
  State<AfterPrayerDuasScreen> createState() => _AfterPrayerDuasScreenState();
}

class _AfterPrayerDuasScreenState extends State<AfterPrayerDuasScreen> {
  int currentDuaIndex = 0;

  final List<Map<String, dynamic>> afterPrayerDuas = [
    {
      'arabic': 'أستغفر الله، أستغفر الله، أستغفر الله',
      'translation': 'I seek forgiveness from Allah (three times).',
      'count': 1,
    },
    {
      'arabic': 'اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام',
      'translation': 'O Allah, You are peace and from You comes peace. Blessed are You, O Owner of majesty and honor.',
      'count': 1,
    },
    {
      'arabic': 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير. اللهم لا مانع لما أعطيت ولا معطي لما منعت ولا ينفع ذا الجد منك الجد',
      'translation': 'There is no god but Allah alone, with no partner. His is the dominion and His is the praise and He is able to do all things. O Allah, none can withhold what You give, and none can give what You withhold, and the fortune of the fortunate avails nothing against You.',
      'count': 1,
    },
    {
      'arabic': 'سبحان الله (33 مرة)، الحمد لله (33 مرة)، الله أكبر (33 مرة)، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
      'translation': 'Glory be to Allah (33 times), Praise be to Allah (33 times), Allah is the Greatest (33 times), There is no god but Allah alone, with no partner. His is the dominion and His is the praise and He is able to do all things.',
      'count': 1,
    },
    {
      'arabic': 'آية الكرسي: اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
      'translation': 'Ayat al-Kursi: Allah! There is no deity except Him, the Ever-Living, the Sustainer of [all] existence... (Al-Baqarah 2:255)',
      'count': 1,
    },
    {
      'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ، قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
      'translation': 'Recite: Surah Al-Ikhlas, Surah Al-Falaq, and Surah An-Nas (once after each prayer, three times after Fajr and Maghrib).',
      'count': 1,
    },
  ];

  void nextDua() {
    if (currentDuaIndex < afterPrayerDuas.length - 1) {
      setState(() {
        currentDuaIndex++;
      });
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Well done!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text('You have completed the After Prayer Duas', style: GoogleFonts.poppins(fontSize: 18)),
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
    final currentDua = afterPrayerDuas[currentDuaIndex];
    return Stack(
      children: [
        const AppBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'After Prayer Duas',
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
                  value: (currentDuaIndex + 1) / afterPrayerDuas.length,
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentDua['arabic'],
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
                                  currentDua['translation'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
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
                          '${currentDua['count']} times',
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
                          onPressed: nextDua,
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