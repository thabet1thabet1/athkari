import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamicapp/core/quran_download_service.dart';
import 'package:islamicapp/core/audio_manager.dart';

void main() {
  group('Quran Download Integration Tests', () {
    testWidgets('AudioManager can be instantiated and initialized', (WidgetTester tester) async {
      final audioManager = AudioManager();
      expect(audioManager, isNotNull);
      
      // Test initialization
      await audioManager.initialize();
      expect(audioManager.player, isNotNull);
    });

    testWidgets('AudioManager can play Al-Fatiha', (WidgetTester tester) async {
      final audioManager = AudioManager();
      await audioManager.initialize();
      
      // Test playing Al-Fatiha
      await audioManager.playAlFatiha();
      expect(audioManager.currentSurahIndex, equals(1));
      expect(audioManager.currentSurahName, equals('الفاتحة'));
      expect(audioManager.currentSurahNameEnglish, equals('Al-Fatiha'));
      expect(audioManager.isDownloaded, isFalse);
    });

    testWidgets('QuranDownloadService can check download status', (WidgetTester tester) async {
      // Test checking if a surah is downloaded
      final isDownloaded = await QuranDownloadService.isSurahDownloaded(2);
      expect(isDownloaded, isA<bool>());
    });

    testWidgets('QuranDownloadService can get downloaded surahs', (WidgetTester tester) async {
      // Test getting list of downloaded surahs
      final downloadedSurahs = await QuranDownloadService.getDownloadedSurahs();
      expect(downloadedSurahs, isA<List<Map<String, dynamic>>>());
    });

    testWidgets('AudioManager can check if surah can be played', (WidgetTester tester) async {
      final audioManager = AudioManager();
      
      // Test Al-Fatiha (should always be playable)
      final canPlayAlFatiha = await audioManager.canPlaySurah(1);
      expect(canPlayAlFatiha, isTrue);
      
      // Test other surahs (should depend on download status)
      final canPlayOtherSurah = await audioManager.canPlaySurah(2);
      expect(canPlayOtherSurah, isA<bool>());
    });

    testWidgets('Download confirmation dialog shows correct content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await QuranDownloadService.showDownloadConfirmation(
                    context: context,
                    surahName: 'البقرة',
                    surahNameEnglish: 'Al-Baqarah',
                  );
                },
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(find.text('Download Surah'), findsOneWidget);
      expect(find.text('البقرة'), findsOneWidget);
      expect(find.text('Al-Baqarah'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    test('AudioManager singleton pattern works correctly', () {
      final instance1 = AudioManager();
      final instance2 = AudioManager();
      expect(identical(instance1, instance2), isTrue);
    });

    test('AudioManager can pause and resume', () async {
      final audioManager = AudioManager();
      await audioManager.initialize();
      
      // Test pause
      await audioManager.pause();
      expect(audioManager.isPlaying, isFalse);
      
      // Test resume
      await audioManager.resume();
      expect(audioManager.isPlaying, isTrue);
    });

    test('AudioManager can stop playback', () async {
      final audioManager = AudioManager();
      await audioManager.initialize();
      
      await audioManager.stop();
      expect(audioManager.isPlaying, isFalse);
      expect(audioManager.currentSurahIndex, isNull);
      expect(audioManager.currentSurahName, isNull);
      expect(audioManager.currentSurahNameEnglish, isNull);
    });
  });
} 