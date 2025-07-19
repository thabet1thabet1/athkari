// Daily verses that change at midnight (based on day of year)
const List<Map<String, String>> versesOfTheDay = [
  {
    'verse': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    'source': 'Surah Al-Baqarah, 152',
  },
  {
    'verse': 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ',
    'source': 'Surah Ar-Ra\'d, 28',
  },
  {
    'verse': 'وَاذْكُر رَّبَّكَ كَثِيرًا وَسَبِّحْ بِالْعَشِيِّ وَالْإِبْكَارِ',
    'source': 'Surah Al-Imran, 41',
  },
  {
    'verse': 'فَسَبِّحْ بِاسْمِ رَبِّكَ الْعَظِيمِ',
    'source': 'Surah Al-Waqi\'ah, 74',
  },
  {
    'verse': 'إِنَّمَا الْمُؤْمِنُونَ الَّذِينَ إِذَا ذُكِرَ اللَّهُ وَجِلَتْ قُلُوبُهُمْ',
    'source': 'Surah Al-Anfal, 2',
  },
  {
    'verse': 'وَسَبِّحْهُ بُكْرَةً وَأَصِيلًا',
    'source': 'Surah Al-Furqan, 58',
  },
  {
    'verse': 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ',
    'source': 'Surah An-Nasr, 3',
  },
  // Additional 10 verses
  {
    'verse': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    'source': 'Surah Al-Baqarah, 153',
  },
  {
    'verse': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
    'source': 'Surah At-Talaq, 3',
  },
  {
    'verse': 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ',
    'source': 'Surah Ar-Ra\'d, 11',
  },
  {
    'verse': 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ',
    'source': 'Surah Yusuf, 87',
  },
  {
    'verse': 'إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ',
    'source': 'Surah Al-Baqarah, 195',
  },
  {
    'verse': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
    'source': 'Surah At-Talaq, 2',
  },
  {
    'verse': 'إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ',
    'source': 'Surah At-Tawbah, 120',
  },
  {
    'verse': 'وَلَا تَقُولُوا لِمَن يُقْتَلُ فِي سَبِيلِ اللَّهِ أَمْوَاتٌ',
    'source': 'Surah Al-Baqarah, 154',
  },
  {
    'verse': 'إِنَّ اللَّهَ مَعَنَا',
    'source': 'Surah At-Tawbah, 40',
  },
  {
    'verse': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مِنْ أَمْرِهِ يُسْرًا',
    'source': 'Surah At-Talaq, 4',
  },
];

// Palestine duas that change daily
const List<Map<String, String>> palestineDuas = [
  {
    'dua': 'اللَّهُمَّ انْصُرْ أَهْلَ فِلَسْطِينَ وَاحْفَظْهُمْ مِنْ كُلِّ سُوءٍ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ اكْشِفْ الْغُمَّةَ عَنْ أَهْلِ فِلَسْطِينَ وَأَصْلِحْ أَحْوَالَهُمْ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ ارْحَمْ أَهْلَ فِلَسْطِينَ وَاجْعَلْ لَهُمْ فَرَجًا قَرِيبًا',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ احْفَظْ أَطْفَالَ فِلَسْطِينَ وَاحْرُسْهُمْ بِعَيْنِكَ الَّتِي لَا تَنَامُ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ أَصْلِحْ أَحْوَالَ الْمُسْلِمِينَ فِي فِلَسْطِينَ وَفِي كُلِّ مَكَانٍ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ انْصُرْ الْمُسْتَضْعَفِينَ فِي فِلَسْطِينَ وَفِي كُلِّ أَرْضٍ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ اكْشِفْ الْبَلَاءَ عَنْ أَهْلِ فِلَسْطِينَ وَاجْعَلْ لَهُمْ نُصْرَةً مِنْ عِنْدِكَ',
    'source': 'Dua for Palestine',
  },
  // Additional 10 duas for Palestine
  {
    'dua': 'اللَّهُمَّ احْفَظْ الْمَسَاجِدَ فِي فِلَسْطِينَ وَاجْعَلْهَا مَأْمَنًا لِلْمُؤْمِنِينَ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ ارْزُقْ أَهْلَ فِلَسْطِينَ الصَّبْرَ وَالثَّبَاتَ وَالْإِيمَانَ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ اكْشِفْ الْحِجَابَ عَنْ أَهْلِ فِلَسْطِينَ وَأَرِهِمْ نُورَ الْحَقِّ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ احْفَظْ الْعُلَمَاءَ وَالطُّلَّابَ فِي فِلَسْطِينَ وَاجْعَلْهُمْ حُجَّةً عَلَى الظَّالِمِينَ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ انْصُرْ الْمُقَاوِمِينَ فِي فِلَسْطِينَ وَاجْعَلْهُمْ ظَاهِرِينَ عَلَى عَدُوِّهِمْ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ اكْشِفْ الْغُمَّةَ عَنْ أَهْلِ الْقُدْسِ وَاحْفَظْ الْمَسْجِدَ الْأَقْصَى',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ ارْحَمْ الشُّهَدَاءَ فِي فِلَسْطِينَ وَاجْعَلْهُمْ مِنَ السَّابِقِينَ إِلَى الْجَنَّةِ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ أَصْلِحْ أَحْوَالَ الْمُسْلِمِينَ فِي كُلِّ مَكَانٍ وَاجْعَلْهُمْ أُمَّةً وَاحِدَةً',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ اكْشِفْ الْبَلَاءَ عَنْ جَمِيعِ الْمُسْلِمِينَ وَاجْعَلْ لَهُمُ النَّصْرَ وَالْفَتْحَ',
    'source': 'Dua for Palestine',
  },
  {
    'dua': 'اللَّهُمَّ احْفَظْ أَرْضَ فِلَسْطِينَ وَاجْعَلْهَا أَرْضَ الْإِسْلَامِ وَالْإِيمَانِ',
    'source': 'Dua for Palestine',
  },
];

// Function to get daily verse based on day of year (changes at midnight)
Map<String, String> getDailyVerse() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  return versesOfTheDay[dayOfYear % versesOfTheDay.length];
}

// Function to get daily dua for Palestine based on day of year (changes at midnight)
Map<String, String> getDailyPalestineDua() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  return palestineDuas[dayOfYear % palestineDuas.length];
}

/// List of all surahs with Arabic name, English name, and page number
const List<Map<String, dynamic>> surahs = [
  {"index": 1, "arabic": "الفاتحة", "english": "Al-Fatiha", "page": 1},
  {"index": 2, "arabic": "البقرة", "english": "Al-Baqarah", "page": 2},
  {"index": 3, "arabic": "آل عمران", "english": "Aal Imran", "page": 50},
  {"index": 4, "arabic": "النساء", "english": "An-Nisa'", "page": 77},
  {"index": 5, "arabic": "المائدة", "english": "Al-Ma'idah", "page": 106},
  {"index": 6, "arabic": "الأنعام", "english": "Al-An'am", "page": 128},
  {"index": 7, "arabic": "الأعراف", "english": "Al-A'raf", "page": 151},
  {"index": 8, "arabic": "الأنفال", "english": "Al-Anfal", "page": 177},
  {"index": 9, "arabic": "التوبة", "english": "At-Tawbah", "page": 187},
  {"index": 10, "arabic": "يونس", "english": "Yunus", "page": 208},
  {"index": 11, "arabic": "هود", "english": "Hud", "page": 221},
  {"index": 12, "arabic": "يوسف", "english": "Yusuf", "page": 235},
  {"index": 13, "arabic": "الرعد", "english": "Ar-Ra'd", "page": 249},
  {"index": 14, "arabic": "إبراهيم", "english": "Ibrahim", "page": 255},
  {"index": 15, "arabic": "الحجر", "english": "Al-Hijr", "page": 262},
  {"index": 16, "arabic": "النحل", "english": "An-Nahl", "page": 267},
  {"index": 17, "arabic": "الإسراء", "english": "Al-Isra'", "page": 282},
  {"index": 18, "arabic": "الكهف", "english": "Al-Kahf", "page": 293},
  {"index": 19, "arabic": "مريم", "english": "Maryam", "page": 305},
  {"index": 20, "arabic": "طه", "english": "Ta-Ha", "page": 312},
  {"index": 21, "arabic": "الأنبياء", "english": "Al-Anbiya'", "page": 322},
  {"index": 22, "arabic": "الحج", "english": "Al-Hajj", "page": 332},
  {"index": 23, "arabic": "المؤمنون", "english": "Al-Mu'minun", "page": 342},
  {"index": 24, "arabic": "النور", "english": "An-Nur", "page": 350},
  {"index": 25, "arabic": "الفرقان", "english": "Al-Furqan", "page": 359},
  {"index": 26, "arabic": "الشعراء", "english": "Ash-Shu'ara'", "page": 367},
  {"index": 27, "arabic": "النمل", "english": "An-Naml", "page": 377},
  {"index": 28, "arabic": "القصص", "english": "Al-Qasas", "page": 385},
  {"index": 29, "arabic": "العنكبوت", "english": "Al-Ankabut", "page": 396},
  {"index": 30, "arabic": "الروم", "english": "Ar-Rum", "page": 404},
  {"index": 31, "arabic": "لقمان", "english": "Luqman", "page": 411},
  {"index": 32, "arabic": "السجدة", "english": "As-Sajda", "page": 415},
  {"index": 33, "arabic": "الأحزاب", "english": "Al-Ahzab", "page": 418},
  {"index": 34, "arabic": "سبإ", "english": "Saba'", "page": 428},
  {"index": 35, "arabic": "فاطر", "english": "Fatir", "page": 434},
  {"index": 36, "arabic": "يس", "english": "Ya-Sin", "page": 440},
  {"index": 37, "arabic": "الصافات", "english": "As-Saffat", "page": 446},
  {"index": 38, "arabic": "ص", "english": "Sad", "page": 453},
  {"index": 39, "arabic": "الزمر", "english": "Az-Zumar", "page": 458},
  {"index": 40, "arabic": "غافر", "english": "Ghafir", "page": 467},
  {"index": 41, "arabic": "فصلت", "english": "Fussilat", "page": 477},
  {"index": 42, "arabic": "الشورى", "english": "Ash-Shura", "page": 482},
  {"index": 43, "arabic": "الزخرف", "english": "Az-Zukhruf", "page": 489},
  {"index": 44, "arabic": "الدخان", "english": "Ad-Dukhan", "page": 496},
  {"index": 45, "arabic": "الجاثية", "english": "Al-Jathiyah", "page": 499},
  {"index": 46, "arabic": "الأحقاف", "english": "Al-Ahqaf", "page": 502},
  {"index": 47, "arabic": "محمد", "english": "Muhammad", "page": 507},
  {"index": 48, "arabic": "الفتح", "english": "Al-Fath", "page": 511},
  {"index": 49, "arabic": "الحجرات", "english": "Al-Hujurat", "page": 515},
  {"index": 50, "arabic": "ق", "english": "Qaf", "page": 518},
  {"index": 51, "arabic": "الذاريات", "english": "Adh-Dhariyat", "page": 520},
  {"index": 52, "arabic": "الطور", "english": "At-Tur", "page": 523},
  {"index": 53, "arabic": "النجم", "english": "An-Najm", "page": 526},
  {"index": 54, "arabic": "القمر", "english": "Al-Qamar", "page": 528},
  {"index": 55, "arabic": "الرحمن", "english": "Ar-Rahman", "page": 531},
  {"index": 56, "arabic": "الواقعة", "english": "Al-Waqi'ah", "page": 534},
  {"index": 57, "arabic": "الحديد", "english": "Al-Hadid", "page": 537},
  {"index": 58, "arabic": "المجادلة", "english": "Al-Mujadila", "page": 542},
  {"index": 59, "arabic": "الحشر", "english": "Al-Hashr", "page": 545},
  {"index": 60, "arabic": "الممتحنة", "english": "Al-Mumtahina", "page": 549},
  {"index": 61, "arabic": "الصف", "english": "As-Saff", "page": 551},
  {"index": 62, "arabic": "الجمعة", "english": "Al-Jumu'ah", "page": 553},
  {"index": 63, "arabic": "المنافقون", "english": "Al-Munafiqun", "page": 554},
  {"index": 64, "arabic": "التغابن", "english": "At-Taghabun", "page": 556},
  {"index": 65, "arabic": "الطلاق", "english": "At-Talaq", "page": 558},
  {"index": 66, "arabic": "التحريم", "english": "At-Tahrim", "page": 560},
  {"index": 67, "arabic": "الملك", "english": "Al-Mulk", "page": 562},
  {"index": 68, "arabic": "القلم", "english": "Al-Qalam", "page": 564},
  {"index": 69, "arabic": "الحاقة", "english": "Al-Haqqah", "page": 566},
  {"index": 70, "arabic": "المعارج", "english": "Al-Ma'arij", "page": 568},
  {"index": 71, "arabic": "نوح", "english": "Nuh", "page": 570},
  {"index": 72, "arabic": "الجن", "english": "Al-Jinn", "page": 572},
  {"index": 73, "arabic": "المزمل", "english": "Al-Muzzammil", "page": 574},
  {"index": 74, "arabic": "المدثر", "english": "Al-Muddathir", "page": 575},
  {"index": 75, "arabic": "القيامة", "english": "Al-Qiyamah", "page": 577},
  {"index": 76, "arabic": "الانسان", "english": "Al-Insan", "page": 578},
  {"index": 77, "arabic": "المرسلات", "english": "Al-Mursalat", "page": 580},
  {"index": 78, "arabic": "النبأ", "english": "An-Naba'", "page": 582},
  {"index": 79, "arabic": "النازعات", "english": "An-Nazi'at", "page": 583},
  {"index": 80, "arabic": "عبس", "english": "Abasa", "page": 585},
  {"index": 81, "arabic": "التكوير", "english": "At-Takwir", "page": 586},
  {"index": 82, "arabic": "الانفطار", "english": "Al-Infitar", "page": 587},
  {"index": 83, "arabic": "المطففين", "english": "Al-Mutaffifin", "page": 587},
  {"index": 84, "arabic": "الانشقاق", "english": "Al-Inshiqaq", "page": 589},
  {"index": 85, "arabic": "البروج", "english": "Al-Buruj", "page": 590},
  {"index": 86, "arabic": "الطارق", "english": "At-Tariq", "page": 591},
  {"index": 87, "arabic": "الأعلى", "english": "Al-A'la", "page": 591},
  {"index": 88, "arabic": "الغاشية", "english": "Al-Ghashiyah", "page": 592},
  {"index": 89, "arabic": "الفجر", "english": "Al-Fajr", "page": 593},
  {"index": 90, "arabic": "البلد", "english": "Al-Balad", "page": 594},
  {"index": 91, "arabic": "الشمس", "english": "Ash-Shams", "page": 595},
  {"index": 92, "arabic": "الليل", "english": "Al-Layl", "page": 595},
  {"index": 93, "arabic": "الضحى", "english": "Ad-Duhaa", "page": 596},
  {"index": 94, "arabic": "الشرح", "english": "Ash-Sharh", "page": 596},
  {"index": 95, "arabic": "التين", "english": "At-Tin", "page": 597},
  {"index": 96, "arabic": "العلق", "english": "Al-Alaq", "page": 597},
  {"index": 97, "arabic": "القدر", "english": "Al-Qadr", "page": 598},
  {"index": 98, "arabic": "البينة", "english": "Al-Bayyina", "page": 598},
  {"index": 99, "arabic": "الزلزلة", "english": "Az-Zalzalah", "page": 599},
  {"index": 100, "arabic": "العاديات", "english": "Al-Adiyat", "page": 599},
  {"index": 101, "arabic": "القارعة", "english": "Al-Qari'ah", "page": 600},
  {"index": 102, "arabic": "التكاثر", "english": "At-Takathur", "page": 600},
  {"index": 103, "arabic": "العصر", "english": "Al-Asr", "page": 601},
  {"index": 104, "arabic": "الهمزة", "english": "Al-Humazah", "page": 601},
  {"index": 105, "arabic": "الفيل", "english": "Al-Fil", "page": 601},
  {"index": 106, "arabic": "قريش", "english": "Quraysh", "page": 602},
  {"index": 107, "arabic": "الماعون", "english": "Al-Ma'un", "page": 602},
  {"index": 108, "arabic": "الكوثر", "english": "Al-Kawthar", "page": 602},
  {"index": 109, "arabic": "الكافرون", "english": "Al-Kafirun", "page": 603},
  {"index": 110, "arabic": "النصر", "english": "An-Nasr", "page": 603},
  {"index": 111, "arabic": "المسد", "english": "Al-Masad", "page": 603},
  {"index": 112, "arabic": "الإخلاص", "english": "Al-Ikhlas", "page": 604},
  {"index": 113, "arabic": "الفلق", "english": "Al-Falaq", "page": 604},
  {"index": 114, "arabic": "الناس", "english": "An-Nas", "page": 604},
];
