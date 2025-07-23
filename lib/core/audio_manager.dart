import 'package:just_audio/just_audio.dart';
import '../core/quran_download_service.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Current playing state
  int? _currentSurahIndex;
  String? _currentSurahName;
  String? _currentSurahNameEnglish;
  bool _isPlaying = false;
  bool _isDownloaded = false;

  // Callbacks for UI updates
  Function(bool)? onPlayingStateChanged;
  Function(Duration?)? onDurationChanged;
  Function(Duration?)? onPositionChanged;
  Function(String)? onError;

  // Getters
  AudioPlayer get player => _audioPlayer;
  int? get currentSurahIndex => _currentSurahIndex;
  String? get currentSurahName => _currentSurahName;
  String? get currentSurahNameEnglish => _currentSurahNameEnglish;
  bool get isPlaying => _isPlaying;
  bool get isDownloaded => _isDownloaded;

  /// Initialize the audio manager
  Future<void> initialize() async {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      onPlayingStateChanged?.call(_isPlaying);
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      onDurationChanged?.call(duration);
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      onPositionChanged?.call(position);
    });

    // Listen to errors
    _audioPlayer.playerStateStream.listen((state) {
      // Handle completion
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        onPlayingStateChanged?.call(_isPlaying);
      }
    });

    // Listen to error stream
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && state.playing == false) {
        // Audio finished playing
        _isPlaying = false;
        onPlayingStateChanged?.call(_isPlaying);
      }
    });
  }

  /// Play Al-Fatiha (built-in)
  Future<void> playAlFatiha() async {
    try {
      await _audioPlayer.setAsset('assets/quran/001 Surah Al-Fatiha Sheikh noreen muhammad sadiq.mp3');
      await _audioPlayer.setSpeed(1.0); // Reset to normal speed
      await _audioPlayer.play();
      
      _currentSurahIndex = 1;
      _currentSurahName = 'الفاتحة';
      _currentSurahNameEnglish = 'Al-Fatiha';
      _isDownloaded = false;
      _isPlaying = true;
      
      onPlayingStateChanged?.call(_isPlaying);
    } catch (e) {
      onError?.call('Error playing Al-Fatiha: $e');
    }
  }

  /// Play a downloaded surah
  Future<void> playDownloadedSurah(int surahIndex) async {
    try {
      // Check if surah is downloaded
      if (!await QuranDownloadService.isSurahDownloaded(surahIndex)) {
        onError?.call('Surah is not downloaded');
        return;
      }

      // Get file path
      final filePath = await QuranDownloadService.getSurahFilePath(surahIndex);
      if (filePath == null) {
        onError?.call('Could not find downloaded surah file');
        return;
      }

      // Get surah info
      final downloadedSurahs = await QuranDownloadService.getDownloadedSurahs();
      final surahInfo = downloadedSurahs.firstWhere(
        (surah) => surah['index'] == surahIndex,
        orElse: () => {'arabicName': 'Unknown', 'englishName': 'Unknown'},
      );

      // Play the actual downloaded MP3 file
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.setSpeed(1.0); // Normal speed
      await _audioPlayer.play();
      
      _currentSurahIndex = surahIndex;
      _currentSurahName = surahInfo['arabicName'];
      _currentSurahNameEnglish = surahInfo['englishName'];
      _isDownloaded = true;
      _isPlaying = true;
      
      onPlayingStateChanged?.call(_isPlaying);
    } catch (e) {
      onError?.call('Error playing downloaded surah: $e');
    }
  }

  /// Play any surah (built-in or downloaded)
  Future<void> playSurah(int surahIndex) async {
    if (surahIndex == 1) {
      await playAlFatiha();
    } else {
      await playDownloadedSurah(surahIndex);
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      onPlayingStateChanged?.call(_isPlaying);
    } catch (e) {
      onError?.call('Error pausing audio: $e');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      _isPlaying = true;
      onPlayingStateChanged?.call(_isPlaying);
    } catch (e) {
      onError?.call('Error resuming audio: $e');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSurahIndex = null;
      _currentSurahName = null;
      _currentSurahNameEnglish = null;
      _isDownloaded = false;
      onPlayingStateChanged?.call(_isPlaying);
    } catch (e) {
      onError?.call('Error stopping audio: $e');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      onError?.call('Error seeking audio: $e');
    }
  }

  /// Get current position
  Duration get position => _audioPlayer.position;

  /// Get duration
  Duration? get duration => _audioPlayer.duration;

  /// Check if a surah can be played (built-in or downloaded)
  Future<bool> canPlaySurah(int surahIndex) async {
    if (surahIndex == 1) {
      return true; // Al-Fatiha is always available
    }
    return await QuranDownloadService.isSurahDownloaded(surahIndex);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
} 