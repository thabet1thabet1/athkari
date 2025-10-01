import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:athkari/core/quran_download_service.dart';

void main() {
  group('QuranDownloadService Tests', () {
    testWidgets('showDownloadConfirmation shows dialog with correct content', (WidgetTester tester) async {
      // Build a test widget
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

      // Tap the button to show the dialog
      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      // Verify the dialog is shown with correct content
      expect(find.text('Download Surah'), findsOneWidget);
      expect(find.text('البقرة'), findsOneWidget);
      expect(find.text('Al-Baqarah'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    test('downloadSurahToApp method exists and is callable', () {
      // This test just verifies the method exists and can be called
      expect(QuranDownloadService.downloadSurahToApp, isA<Function>());
    });

    test('isSurahDownloaded method exists and is callable', () {
      // This test just verifies the method exists and can be called
      expect(QuranDownloadService.isSurahDownloaded, isA<Function>());
    });

    test('getDownloadedSurahs method exists and is callable', () {
      // This test just verifies the method exists and can be called
      expect(QuranDownloadService.getDownloadedSurahs, isA<Function>());
    });
  });
} 