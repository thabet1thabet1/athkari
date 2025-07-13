import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../main.dart' show AppBackground;

class EveningAthkarScreen extends StatefulWidget {
  const EveningAthkarScreen({super.key});

  @override
  State<EveningAthkarScreen> createState() => _EveningAthkarScreenState();
}

class _EveningAthkarScreenState extends State<EveningAthkarScreen> {
  int currentAthkarIndex = 0;

  final List<Map<String, dynamic>> eveningAthkar = [
    {
      'arabic': 'اللّهـمَّ أَنْتَ رَبِّي لا إِلـهَ إِلاّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لا يَغْفِرُ الذُّنُوبَ إِلاّ أَنْتَ',
      'translation': 'O Allah, You are my Lord, there is no deity except You. You created me and I am Your servant, and I am upon Your covenant and promise as much as I am able. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me, for verily none can forgive sin except You.',
      'count': 1,
    },
    {
      'arabic': 'اللّهـمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللّهُ لا إِلـهَ إِلاّ أَنْتَ وَحْدَكَ لا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّداً عَبْدُكَ وَرَسُولُكَ',
      'translation': 'O Allah, as evening falls I call You to witness, and the bearers of Your Throne, Your angels, and all Your creation, that You are Allah, there is no deity except You, alone with no partner, and that Muhammad is Your servant and Messenger.',
      'count': 4,
    },
    {
      'arabic': 'اللّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ',
      'translation': 'O Allah, I ask You for well-being in this world and in the Hereafter.',
      'count': 1,
    },
    {
      'arabic': 'اللّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
      'translation': 'O Allah, I ask You for forgiveness and well-being in my religion, my worldly affairs, my family, and my wealth.',
      'count': 1,
    },
    {
      'arabic': 'اللّهُمَّ اكْفِنِي بِحَلالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      'translation': 'O Allah, suffice me with what You have allowed instead of what You have forbidden, and make me independent of all others besides You.',
      'count': 1,
    },
    {
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'translation': 'Glory be to Allah and His is the praise.',
      'count': 100,
    },
    {
      'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      'translation': 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
      'count': 3,
    },
  ];

  void nextAthkar() {
    if (currentAthkarIndex < eveningAthkar.length - 1) {
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
            child: Text('You have completed the Evening Athkar', style: GoogleFonts.poppins(fontSize: 18)),
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
    final currentAthkar = eveningAthkar[currentAthkarIndex];
    return Stack(
      children: [
        const AppBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Evening Athkar',
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
                  value: (currentAthkarIndex + 1) / eveningAthkar.length,
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