import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/verses.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import '../../ui/widgets/apple_music_player.dart';

class QuranScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final double slideValue;
  final bool showAudioPlayer;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;
  final VoidCallback onPlayAlFatiha;
  final VoidCallback onPlayPause;
  final VoidCallback onStopAudio;
  final ValueChanged<double> onSeekAudio;
  const QuranScreen({super.key, this.scrollController, required this.slideValue,
    required this.showAudioPlayer, required this.isPlaying, required this.duration, required this.position,
    required this.onPlayAlFatiha, required this.onPlayPause, required this.onStopAudio, required this.onSeekAudio});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  bool isReadMode = true;
  String _search = '';
  int? _lastPageRead;
  bool _showKhatmahDialog = false;
  String? _selectedKhatmahPlan;
  DateTime? _khatmahStartDate;
  int? _khatmahDays;

  @override
  void initState() {
    super.initState();
    _loadKhatmahProgress();
  }

  Future<void> _loadKhatmahProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedKhatmahPlan = prefs.getString('khatmah_plan');
      final start = prefs.getString('khatmah_start');
      _khatmahStartDate = start != null ? DateTime.tryParse(start) : null;
      _khatmahDays = prefs.getInt('khatmah_days');
    });
  }

  Future<void> _saveKhatmahProgress(String plan, int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('khatmah_plan', plan);
    await prefs.setString('khatmah_start', DateTime.now().toIso8601String());
    await prefs.setInt('khatmah_days', days);
    setState(() {
      _selectedKhatmahPlan = plan;
      _khatmahStartDate = DateTime.now();
      _khatmahDays = days;
    });
  }

  List<Map<String, dynamic>> get filteredSurahs {
    if (_search.trim().isEmpty) return surahs;
    final q = _search.trim().toLowerCase();
    return surahs.where((s) {
      return s['arabic'].toString().contains(_search) ||
             s['english'].toString().toLowerCase().contains(q);
    }).toList();
  }

  void _showKhatmahModal() {
    setState(() => _showKhatmahDialog = true);
  }

  void _closeKhatmahModal() {
    setState(() => _showKhatmahDialog = false);
  }

  void _selectKhatmahPlan(String plan) {
    int days = 7;
    if (plan == '1m') days = 30;
    if (plan == '2m') days = 60;
    _saveKhatmahProgress(plan, days);
    Future.delayed(const Duration(milliseconds: 400), _closeKhatmahModal);
  }

  void _openQuranSurah(int surah) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuranPageView(surah: surah, onClose: () => Navigator.of(context).pop()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _QuranBackground(),
        SafeArea(
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              // 1. Fading/sliding title (not sticky)
              SliverPersistentHeader(
                pinned: false,
                floating: false,
                delegate: _QuranTitleHeaderDelegate(),
              ),
              // 2. Sticky Read/Listen toggle
              SliverPersistentHeader(
                pinned: true,
                delegate: _QuranStickyToggleDelegate(
                  isReadMode: isReadMode,
                  onToggle: (val) => setState(() => isReadMode = val),
                ),
              ),
              // 3. Sticky search bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _QuranStickySearchDelegate(
                  search: _search,
                  onSearch: (v) => setState(() => _search = v),
                ),
              ),
              if (isReadMode)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                    child: Column(
                      children: [
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            if (_lastPageRead != null)
                              Expanded(
                                child: _LastPageReadCard(page: _lastPageRead!, onTap: () => _openQuranSurah(_lastPageRead!)),
                              ),
                            if (_lastPageRead != null) const SizedBox(width: 8),
                            Expanded(
                              child: _KhatmahButton(onTap: _showKhatmahModal),
                            ),
                          ],
                        ),
                        if (_selectedKhatmahPlan != null && _khatmahStartDate != null && _khatmahDays != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: _KhatmahProgress(
                              startDate: _khatmahStartDate!,
                              totalDays: _khatmahDays!,
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              if (isReadMode)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) {
                      final surah = filteredSurahs[idx];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        child: _SurahCard(
                          arabic: surah['arabic'],
                          english: surah['english'],
                          page: surah['page'],
                          index: surah['index'],
                          onTap: () {
                            setState(() => _lastPageRead = surah['index']);
                            _openQuranSurah(surah['index']);
                          },
                        ),
                      );
                    },
                    childCount: filteredSurahs.length,
                  ),
                ),
              if (!isReadMode)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) {
                      final surah = filteredSurahs[idx];
                      // Only show play button for Al-Fatiha (index 1)
                      final showPlayButton = surah['index'] == 1;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                        child: _SurahListenCard(
                          arabic: surah['arabic'],
                          english: surah['english'],
                          index: surah['index'],
                          showPlayButton: showPlayButton,
                          isPlaying: widget.showAudioPlayer && surah['index'] == 1 && widget.isPlaying,
                          onPlay: showPlayButton ? widget.onPlayAlFatiha : null,
                        ),
                      );
                    },
                    childCount: filteredSurahs.length,
                  ),
                ),
            ],
          ),
        ),
        if (_showKhatmahDialog)
          _KhatmahModal(
            onClose: _closeKhatmahModal,
            onSelect: _selectKhatmahPlan,
            selected: _selectedKhatmahPlan,
          ),
        // Apple Music-style audio player above nav bar
        if (widget.showAudioPlayer)
          Positioned(
            left: 16,
            right: 16,
            // Animate the player down as you scroll, then dock it in the nav bar's place
            bottom: 105 - (widget.slideValue * 89), // 105 (start) -> 16 (docked)
            child: AppleMusicPlayer(
              surahName: 'الفاتحة',
              englishName: 'Al-Fatiha',
              isPlaying: widget.isPlaying,
              duration: widget.duration,
              position: widget.position,
              onPlayPause: widget.onPlayPause,
              onStop: widget.onStopAudio,
              onSeek: widget.onSeekAudio,
            ),
          ),
      ],
    );
  }
}

// 1. Fading/sliding title
class _QuranTitleHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 0;
  @override
  double get maxExtent => 56;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final double fade = 1.0 - percent;
    final double yOffset = -24 * percent;
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Opacity(
        opacity: fade,
        child: Transform.translate(
          offset: Offset(0, yOffset),
          child: Text(
            'Quran',
            style: GoogleFonts.poppins(
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _QuranTitleHeaderDelegate oldDelegate) => false;
}

// 2. Sticky toggle
class _QuranStickyToggleDelegate extends SliverPersistentHeaderDelegate {
  final bool isReadMode;
  final ValueChanged<bool> onToggle;
  _QuranStickyToggleDelegate({required this.isReadMode, required this.onToggle});

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  static const double fadeStart = 0; // Start fading after title is gone
  static const double fadeRange = 56; // Fade in over 56px
  static const double maxBlur = 18.0;
  static const int maxAlpha = 220;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Only start fading in after the title header (56px) is gone
    final double fade = ((shrinkOffset - fadeStart) / fadeRange).clamp(0.0, 1.0);
    final int alpha = (maxAlpha * fade).toInt();
    final double blur = maxBlur * fade;
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: Colors.white.withAlpha(alpha),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _GlassToggle(
              isRead: isReadMode,
              onChanged: onToggle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _QuranStickyToggleDelegate oldDelegate) {
    return isReadMode != oldDelegate.isReadMode;
  }
}

// 3. Sticky search bar
class _QuranStickySearchDelegate extends SliverPersistentHeaderDelegate {
  final String search;
  final ValueChanged<String> onSearch;
  _QuranStickySearchDelegate({required this.search, required this.onSearch});

  @override
  double get minExtent => 80; // 64 + 16 extra
  @override
  double get maxExtent => 80;

  static const double fadeStart = 0; // Start fading after title is gone
  static const double fadeRange = 56; // Fade in over 56px
  static const double maxBlur = 18.0;
  static const int maxAlpha = 220;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Only start fading in after the title header (56px) is gone
    final double fade = ((shrinkOffset - fadeStart) / fadeRange).clamp(0.0, 1.0);
    final int alpha = (maxAlpha * fade).toInt();
    final double blur = maxBlur * fade;
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          color: Colors.white.withAlpha(alpha),
          alignment: Alignment.center,
                      child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0), // reduced bottom padding
              child: _GlassSearchBar(
                hintText: 'Search Surah (Arabic or English)',
                onChanged: onSearch,
              ),
            ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _QuranStickySearchDelegate oldDelegate) {
    return search != oldDelegate.search;
  }
}

class _GlassToggle extends StatelessWidget {
  final bool isRead;
  final ValueChanged<bool> onChanged;
  const _GlassToggle({required this.isRead, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 44,
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(80),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.forestGreen.withOpacity(0.18), width: 1.5),
          ),
          child: Row(
            children: [
              _ToggleBtn(
                label: 'Read',
                selected: isRead,
                onTap: () => onChanged(true),
              ),
              _ToggleBtn(
                label: 'Listen',
                selected: !isRead,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Apple Music-style audio player widget
class _AppleMusicPlayer extends StatelessWidget {
  final String surahName;
  final String englishName;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;

  const _AppleMusicPlayer({
    required this.surahName,
    required this.englishName,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(46),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color.fromARGB(255, 225, 223, 223), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB6EFC6).withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'lib/images/19B88BD8-0E7F-4783-B0F6-EDF720F48C4E.jpeg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      englishName,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 28, color: Colors.black),
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 28, color: Colors.black),
                onPressed: () {}, // No next track for now
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24, color: Colors.black54),
                onPressed: onStop,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.forestGreen.withOpacity(0.13) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: selected ? AppColors.forestGreen : Colors.black.withOpacity(0.6),
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuranListenMode extends StatefulWidget {
  final ScrollController? scrollController;
  const _QuranListenMode({this.scrollController});

  @override
  State<_QuranListenMode> createState() => _QuranListenModeState();
}

class _QuranListenModeState extends State<_QuranListenMode> {
  String _selectedReciter = 'Al-Husary';
  int? _playingSurahIndex;
  bool _isPlaying = false;
  String? _error;
  bool _showPopup = false;

  final List<Map<String, String>> reciters = [
    {'name': 'Mashari Al Affasi', 'id': 'alafasy'},
    {'name': 'Noreen Mohamed Al Siddiq', 'id': 'noreen'},
  ];

  void _pickReciter() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return _ReciterPickerModal(
          reciters: reciters,
          selected: _selectedReciter,
          onSelect: (name) => Navigator.of(context).pop(name),
        );
      },
    );
    if (picked != null && picked != _selectedReciter) {
      setState(() => _selectedReciter = picked);
    }
  }

  void _playSurah(int index) {
    setState(() {
      _playingSurahIndex = index;
      _isPlaying = true;
      _showPopup = true;
    });
    // TODO: Integrate audio playback
  }

  void _pause() {
    setState(() => _isPlaying = false);
  }

  bool _isSurahValid(Map<String, dynamic> surah) {
    return surah.containsKey('index') &&
           surah.containsKey('arabic') &&
           surah.containsKey('english') &&
           surah['index'] != null &&
           surah['arabic'] != null &&
           surah['english'] != null;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> validSurahs = surahs.where((s) => _isSurahValid(s)).toList();
    String? error;
    if (validSurahs.isEmpty) {
      error = 'No valid surah data found.';
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add gap between search bar and reciter button
              const SizedBox(height: 8),
              // Reciter Picker Button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _pickReciter,
                  icon: const Icon(Icons.person, color: Colors.white, size: 20),
                  label: Text('Reciter :  A0$_selectedReciter', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Surah List or Error
              Expanded(
                child: error != null
                    ? Center(child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 16)))
                    : ListView.separated(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.only(bottom: 160), // More space for popup and nav bar
                        itemCount: validSurahs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final surah = validSurahs[idx];
                          final isPlaying = _playingSurahIndex == surah['index'] && _isPlaying;
                          return _SurahListenCard(
                            arabic: surah['arabic'],
                            english: surah['english'],
                            index: surah['index'],
                            showPlayButton: surah['index'] == 1,
                            isPlaying: isPlaying,
                            onPlay: surah['index'] == 1 ? () => _playSurah(surah['index']) : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        // Audio Player Bar (placeholder)
        if (_playingSurahIndex != null && error == null && validSurahs.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _AudioPlayerBar(
              surah: validSurahs.firstWhere((s) => s['index'] == _playingSurahIndex, orElse: () => validSurahs.first),
              reciter: _selectedReciter,
              isPlaying: _isPlaying,
              onPause: _pause,
              onPlay: () => _playSurah(_playingSurahIndex!),
            ),
          ),
        if (_showPopup && _playingSurahIndex == 1 && _selectedReciter == 'Noreen Mohamed Al Siddiq')
          QuranAudioPlayerPopup(
            surahName: validSurahs.firstWhere((s) => s['index'] == 1)['arabic'],
            surahIndex: 1,
            reciterId: 'noreen',
            onClose: () => setState(() => _showPopup = false),
            onNext: null, // implement next if needed
          ),
      ],
    );
  }
}

class _ReciterSwitch extends StatelessWidget {
  final List<Map<String, String>> reciters;
  final String selected;
  final ValueChanged<String> onChanged;
  const _ReciterSwitch({required this.reciters, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(80),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.forestGreen.withOpacity(0.13)),
          ),
          child: Row(
            children: reciters.map((r) {
              final isSelected = selected == r['name'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(r['name']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.forestGreen.withOpacity(0.13) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      r['name']!,
                      style: GoogleFonts.poppins(
                        color: isSelected ? AppColors.forestGreen : Colors.black.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SurahListenCard extends StatelessWidget {
  final String arabic;
  final String english;
  final int index;
  final bool isPlaying;
  final bool showPlayButton;
  final VoidCallback? onPlay;
  const _SurahListenCard({
    required this.arabic, 
    required this.english, 
    required this.index, 
    required this.isPlaying, 
    required this.showPlayButton,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.forestGreen.withOpacity(0.13)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.forestGreen, fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arabic,
                      style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      english,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              if (showPlayButton)
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: AppColors.forestGreen, size: 36),
                  onPressed: onPlay,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioPlayerBar extends StatelessWidget {
  final Map<String, dynamic> surah;
  final String reciter;
  final bool isPlaying;
  final VoidCallback onPause;
  final VoidCallback onPlay;
  const _AudioPlayerBar({required this.surah, required this.reciter, required this.isPlaying, required this.onPause, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.forestGreen.withOpacity(0.13)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forestGreen.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.menu_book, color: AppColors.forestGreen, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah['arabic'],
                        style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        reciter,
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.forestGreen),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.forestGreen, size: 32),
                  onPressed: isPlaying ? onPause : onPlay,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuranBackground extends StatelessWidget {
  const _QuranBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Background image (reuse your app's style)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/IMG_1323.PNG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White overlay for readability
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  const _GlassSearchBar({required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey[500]!, width: 2.2),
        ),
        child: TextField(
          onChanged: onChanged,
          textAlign: TextAlign.start,
          style: GoogleFonts.amiri(fontSize: 19),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 16, fontWeight: FontWeight.w600),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FFa-zA-Z\s]')),
          ],
        ),
      ),
    );
  }
}

class _LastPageReadCard extends StatelessWidget {
  final int page;
  final VoidCallback onTap;
  const _LastPageReadCard({required this.page, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.bookmark, color: Colors.white, size: 20),
        label: Text('Continue : $page', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ),
    );
  }
}

class _KhatmahButton extends StatelessWidget {
  final VoidCallback onTap;
  const _KhatmahButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.flag, color: Colors.white, size: 20),
        label: Text('Start New Khatmah', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
      ),
    );
  }
}

class _KhatmahModal extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onSelect;
  final String? selected;
  const _KhatmahModal({required this.onClose, required this.onSelect, this.selected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.18),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 340,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start a New Khatmah',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.black.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _KhatmahPlanCard(label: '1 Week', selected: selected == '1w', onTap: () => onSelect('1w')),
                  const SizedBox(height: 12),
                  _KhatmahPlanCard(label: '1 Month', selected: selected == '1m', onTap: () => onSelect('1m')),
                  const SizedBox(height: 12),
                  _KhatmahPlanCard(label: '2 Months', selected: selected == '2m', onTap: () => onSelect('2m')),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18824B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KhatmahPlanCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _KhatmahPlanCard({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFF18824B) : Colors.grey[200]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.85),
                fontSize: 16,
              ),
            ),
            if (selected)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF18824B),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const SizedBox(),
              ),
          ],
        ),
      ),
    );
  }
}

class _KhatmahProgress extends StatelessWidget {
  final DateTime startDate;
  final int totalDays;
  const _KhatmahProgress({required this.startDate, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = now.difference(startDate).inDays + 1;
    final finished = day > totalDays;
    return SizedBox(
      height: 54,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: finished ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: finished ? Colors.green : Colors.grey[400]!, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(finished ? Icons.check_circle : Icons.calendar_today, color: finished ? Colors.green : Colors.black, size: 22),
            const SizedBox(width: 10),
            Text(
              finished ? 'Khatmah Complete!' : 'Day $day of $totalDays',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final String arabic;
  final String english;
  final int page;
  final int index;
  final VoidCallback onTap;
  const _SurahCard({required this.arabic, required this.english, required this.page, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.forestGreen.withOpacity(0.13)),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.forestGreen, fontSize: 20),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arabic,
                        style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        english,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Page $page',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.forestGreen, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuranPageView extends StatefulWidget {
  final int surah;
  final VoidCallback onClose;
  const QuranPageView({super.key, required this.surah, required this.onClose});

  @override
  State<QuranPageView> createState() => _QuranPageViewState();
}

class _QuranPageViewState extends State<QuranPageView> {
  List<dynamic>? _ayahs;
  String? _surahName;
  String? _surahNameArabic;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQuranSurah();
  }

  Future<void> _fetchQuranSurah() async {
    setState(() { _loading = true; _error = null; });
    try {
      final url = 'https://api.alquran.cloud/v1/surah/${widget.surah}/editions/quran-uthmani,en.sahih';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final ar = (data['data'] as List).firstWhere((e) => e['edition']['identifier'] == 'quran-uthmani');
        if (!mounted) return;
        setState(() {
          _ayahs = ar['ayahs'];
          _surahName = ar['englishName'];
          _surahNameArabic = ar['name'];
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() { _error = 'Failed to load Quran data.'; _loading = false; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  bool get _showBasmala {
    // Do not show Basmala for At-Tawbah (Surah 9)
    return widget.surah != 9;
  }

  bool get _isFatiha => widget.surah == 1;

  String? get _centeredBasmala {
    if (_ayahs == null) return null;
    if (_isFatiha || widget.surah == 9) return null;
    if (_ayahs!.isNotEmpty && _ayahs![0]['text'].trim().startsWith('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ')) {
      return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    }
    return null;
  }

  String get _blockQuranText {
    if (_ayahs == null) return '';
    // For Al-Fatiha, show as-is. For surah 9, show as-is (no Basmala). For others, split Basmala from first ayah if present.
    if (_isFatiha || widget.surah == 9) {
      return _ayahs!.map((ayah) => ayah['text'] + ' ﴿' + ayah['numberInSurah'].toString() + '﴾').join(' ');
    }
    List<dynamic> ayat = List.from(_ayahs!);
    if (ayat.isNotEmpty && ayat[0]['text'].trim().startsWith('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ')) {
      // Remove Basmala from first ayah
      final rest = ayat[0]['text'].replaceFirst('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '').trim();
      if (rest.isEmpty) {
        ayat.removeAt(0);
      } else {
        ayat[0]['text'] = rest;
      }
    }
    // Renumber ayat starting from 1
    return ayat.asMap().entries.map((entry) {
      final idx = entry.key;
      final ayah = entry.value;
      return ayah['text'] + ' ﴿' + (idx + 1).toString() + '﴾';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 0),
              child: Column(
                children: [
                  SizedBox(height: 2),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.forestGreen),
                        onPressed: widget.onClose,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 280),
                          child: Text(
                            'Surah ${widget.surah}', 
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, 
                              color: AppColors.forestGreen,
                              fontSize: 18,
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  if (_loading)
                    const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.forestGreen))),
                  if (_error != null)
                    Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))),
                  if (!_loading && _error == null && _ayahs != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Decorative Surah Name Banner
                            if (_surahNameArabic != null)
                              Container(
                                margin: const EdgeInsets.only(top: 0, bottom: 20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(1),
                                      child: Image.asset('lib/images/surah_banner.png',
                                        
                                        width: double.infinity,
                                        height: 75,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('Error loading surah banner: $error');
                                          return Container(
                                            width: double.infinity,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.forestGreen.withOpacity(0.1),
                                                  AppColors.forestGreen.withOpacity(0.2),
                                                  AppColors.forestGreen.withOpacity(0.1),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(0),
                                              border: Border.all(
                                                color: AppColors.forestGreen.withOpacity(0.3),
                                                width: 2,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 24 ,
                                      child: Text(
                                        _surahNameArabic!,
                                        style: GoogleFonts.amiri(
                                          fontSize: 28,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Centered Basmala if present
                            if (_centeredBasmala != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 0, bottom: 0),
                                child: Text(
                                  _centeredBasmala!,
                                  style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            // Block Quran Text
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: SelectableText(
                                _blockQuranText,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.amiri(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.black,
                                  height: 2.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reciter Picker Modal styled like Khatmah modal
class _ReciterPickerModal extends StatelessWidget {
  final List<Map<String, String>> reciters;
  final String selected;
  final ValueChanged<String> onSelect;
  const _ReciterPickerModal({required this.reciters, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.18),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 340,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pick a Reciter',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.black.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...reciters.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReciterOptionCard(
                          label: r['name']!,
                          selected: selected == r['name'],
                          onTap: () => onSelect(r['name']!),
                        ),
                      )),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF18824B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReciterOptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ReciterOptionCard({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFF18824B) : Colors.grey[200]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.85),
                fontSize: 16,
              ),
            ),
            if (selected)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF18824B),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const SizedBox(),
              ),
          ],
        ),
      ),
    );
  }
}

class QuranAudioPlayerPopup extends StatefulWidget {
  final String surahName;
  final int surahIndex;
  final String reciterId;
  final VoidCallback? onNext;
  final VoidCallback? onClose;
  const QuranAudioPlayerPopup({
    required this.surahName,
    required this.surahIndex,
    required this.reciterId,
    this.onNext,
    this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  State<QuranAudioPlayerPopup> createState() => _QuranAudioPlayerPopupState();
}

class _QuranAudioPlayerPopupState extends State<QuranAudioPlayerPopup> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _loading = true;
  Duration? _duration;
  Duration? _position;

  String get _audioUrl {
    if (widget.reciterId == 'noreen' && widget.surahIndex == 1) {
      return 'assets/quran/001 Surah Al-Fatiha Sheikh noreen muhammad sadiq.mp3';
    }
    // fallback to network for other surahs/reciters
    return 'https://verses.quran.com/Noreen_Mohamed_Al_Siddiq/mp3/${widget.surahIndex.toString().padLeft(3, '0')}.mp3';
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      if (widget.reciterId == 'noreen' && widget.surahIndex == 1) {
        await _player.setAsset(_audioUrl);
      } else {
        await _player.setUrl(_audioUrl);
      }
      setState(() {
        _loading = false;
      });
      _player.positionStream.listen((pos) {
        setState(() {
          _position = pos;
        });
      });
      _player.durationStream.listen((dur) {
        setState(() {
          _duration = dur;
        });
      });
      _player.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _stop() {
    _player.stop();
    if (widget.onClose != null) widget.onClose!();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.menu_book, color: Colors.green[900]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.surahName, style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                        const SizedBox(height: 2),
                        Text('Noreen Mohamed Al Siddiq', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
                        if (_duration != null && _position != null)
                          Slider(
                            value: _position!.inSeconds.toDouble(),
                            min: 0,
                            max: _duration!.inSeconds.toDouble(),
                            onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32, color: Colors.black),
                    onPressed: _togglePlay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 32, color: Colors.black),
                    onPressed: widget.onNext,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28, color: Colors.black54),
                    onPressed: _stop,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 