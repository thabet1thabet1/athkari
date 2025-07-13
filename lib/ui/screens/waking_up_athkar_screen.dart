import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../main.dart' show AppBackground;

class WakingUpAthkarScreen extends StatefulWidget {
  const WakingUpAthkarScreen({super.key});

  @override
  State<WakingUpAthkarScreen> createState() => _WakingUpAthkarScreenState();
}

class _WakingUpAthkarScreenState extends State<WakingUpAthkarScreen> {
  int currentAthkarIndex = 0;

  final List<Map<String, dynamic>> wakingUpAthkar = [
    {
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'translation': 'Praise is to Allah Who gives us life after He has caused us to die and to Him is the return.',
      'count': 1,
    },
    {
      'arabic': 'الحمد لله الذي عافاني في جسدي ورد علي روحي وأذن لي بذكره',
      'translation': 'Praise is to Allah Who gave strength to my body and returned my soul to me and permitted me to remember Him.',
      'count': 1,
    },
    {
      'arabic': 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير، سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر، ولا حول ولا قوة إلا بالله العلي العظيم، رب اغفر لي',
      'translation': 'There is no god but Allah alone, with no partner. His is the dominion and His is the praise and He is able to do all things. Glory is to Allah. Praise is to Allah. There is no god but Allah. Allah is the Greatest. There is no power and no strength except with Allah, the Most High, the Most Great. O Lord, forgive me.',
      'count': 1,
    },
    {
      'arabic': 'اللهم إني أسألك خير هذا اليوم، فتحه ونصره ونوره وبركته وهداه، وأعوذ بك من شر ما فيه وشر ما بعده',
      'translation': 'O Allah, I ask You for the good of this day, its triumphs, its support, its light, its blessings, and its guidance, and I seek refuge in You from the evil of what is in it and the evil of what comes after it.',
      'count': 1,
    },
  ];

  void nextAthkar() {
    if (currentAthkarIndex < wakingUpAthkar.length - 1) {
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
            child: Text('You have completed the Waking Up Athkar', style: GoogleFonts.poppins(fontSize: 18)),
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
    final currentAthkar = wakingUpAthkar[currentAthkarIndex];
    return Stack(
      children: [
        const AppBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Waking Up Athkar',
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
                  value: (currentAthkarIndex + 1) / wakingUpAthkar.length,
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