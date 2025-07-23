import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../ui/widgets/download_progress_dialog.dart';

class QuranDownloadService {
  static const String _downloadsKey = 'downloaded_surahs';
  static const String _downloadsFolder = 'quran_downloads';
  
  // List of legitimate Quran websites with Noreen recitation
  static const List<Map<String, String>> _quranWebsites = [
    {
      'name': 'Quran.com',
      'url': 'https://quran.com',
      'searchParam': 'q=',
    },
    {
      'name': 'SurahQuran.com',
      'url': 'https://surahquran.com',
      'searchParam': 'surah=',
    },
    {
      'name': 'Quran-Explorer.com',
      'url': 'https://www.quran-explorer.com',
      'searchParam': 'surah=',
    },
    {
      'name': 'Al-Quran.info',
      'url': 'https://al-quran.info',
      'searchParam': 'surah=',
    },
  ];

  // Direct download URL for Noreen recitation (NEW LOGIC)
  static String? getNoreenDownloadUrl(int surahIndex) {
    // Surah 1 (Al-Fatiha) is not downloadable (local asset only)
    if (surahIndex == 1) return null;
    final padded = surahIndex.toString().padLeft(3, '0');
    return 'https://server16.mp3quran.net/download/nourin_siddig/Rewayat-Aldori-A-n-Abi-Amr/$padded.mp3';
  }

  /// Downloads a surah directly to the app's local storage (NEW LOGIC)
  static Future<bool> downloadSurahToApp({
    required int surahIndex,
    required String surahName,
    required String surahNameEnglish,
    required BuildContext context,
  }) async {
    try {
      // Al-Fatiha is not downloadable
      if (surahIndex == 1) {
        _showErrorDialog(context, 'Al-Fatiha is already included in the app.');
        return false;
      }
      // Check if already downloaded
      if (await isSurahDownloaded(surahIndex)) {
        _showErrorDialog(context, 'Surah is already downloaded');
        return false;
      }
      // Check permissions
      if (!await _checkPermissions()) {
        _showErrorDialog(context, 'Storage permission is required to download surahs');
        return false;
      }
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return DownloadProgressDialog(
            surahName: surahName,
            surahNameEnglish: surahNameEnglish,
          );
        },
      );
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/$_downloadsFolder');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final fileName = '${surahIndex.toString().padLeft(3, '0')}_$surahNameEnglish.mp3';
      final filePath = '${downloadsDir.path}/$fileName';
      final downloadUrl = getNoreenDownloadUrl(surahIndex);
      if (downloadUrl == null) throw Exception('No download URL for this surah.');
      final response = await Dio().download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          // Optionally update progress dialog
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Download failed with status: \\${response.statusCode}');
      }
      await _saveDownloadRecord(surahIndex, filePath, surahName, surahNameEnglish);
      await Future.delayed(Duration(milliseconds: 100));
      return true;
    } catch (e) {
      _showErrorDialog(context, 'Download error: $e');
      return false;
    }
  }

  /// Opens a Quran website for downloading the specified surah (fallback method)
  static Future<bool> downloadSurahFromWebsite({
    required int surahIndex,
    required String surahName,
    required String surahNameEnglish,
    required BuildContext context,
  }) async {
    try {
      // Show a dialog to let user choose the website
      final selectedWebsite = await _showWebsiteSelectionDialog(context);
      if (selectedWebsite == null) return false;

      // Construct the URL based on the selected website
      String url = selectedWebsite['url']!;
      
      // Add search parameters based on the website
      switch (selectedWebsite['name']) {
        case 'Quran.com':
          url += '/${surahIndex.toString().padLeft(3, '0')}';
          break;
        case 'SurahQuran.com':
          url += '/surah/${surahIndex.toString().padLeft(3, '0')}';
          break;
        case 'Quran-Explorer.com':
          url += '/surah/${surahIndex.toString().padLeft(3, '0')}';
          break;
        case 'Al-Quran.info':
          url += '/surah/${surahIndex.toString().padLeft(3, '0')}';
          break;
        default:
          url += '/${surahIndex.toString().padLeft(3, '0')}';
      }

      // Try to launch the URL
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        _showErrorDialog(context, 'Could not open the website. Please try again.');
        return false;
      }
    } catch (e) {
      _showErrorDialog(context, 'An error occurred while opening the website.');
      return false;
    }
  }

  /// Checks if a surah is downloaded
  static Future<bool> isSurahDownloaded(int surahIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloads = prefs.getStringList(_downloadsKey) ?? [];
      
      // Check if any download record starts with the surah index
      final isDownloaded = downloads.any((download) => download.startsWith('$surahIndex|'));
      
      // Debug logging
      print('Checking if surah $surahIndex is downloaded:');
      print('Downloads list: $downloads');
      print('Is downloaded: $isDownloaded');
      
      return isDownloaded;
    } catch (e) {
      print('Error checking download status: $e');
      return false;
    }
  }

  /// Gets the file path of a downloaded surah (NEW LOGIC)
  static Future<String?> getSurahFilePath(int surahIndex) async {
    try {
      if (surahIndex == 1) {
        // Al-Fatiha is a local asset
        return 'assets/quran/001 Surah Al-Fatiha Sheikh noreen muhammad sadiq.mp3';
      }
      final prefs = await SharedPreferences.getInstance();
      final downloads = prefs.getStringList(_downloadsKey) ?? [];
      for (final download in downloads) {
        final parts = download.split('|');
        if (parts.length >= 2 && parts[0] == surahIndex.toString()) {
          return parts[1];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Gets all downloaded surahs
  static Future<List<Map<String, dynamic>>> getDownloadedSurahs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloads = prefs.getStringList(_downloadsKey) ?? [];
      final List<Map<String, dynamic>> downloadedSurahs = [];
      
      for (final download in downloads) {
        final parts = download.split('|');
        if (parts.length >= 4) {
          downloadedSurahs.add({
            'index': int.parse(parts[0]),
            'filePath': parts[1],
            'arabicName': parts[2],
            'englishName': parts[3],
          });
        }
      }
      
      return downloadedSurahs;
    } catch (e) {
      return [];
    }
  }

  /// Deletes a downloaded surah
  static Future<bool> deleteDownloadedSurah(int surahIndex) async {
    try {
      final filePath = await getSurahFilePath(surahIndex);
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Remove from download records
      final prefs = await SharedPreferences.getInstance();
      final downloads = prefs.getStringList(_downloadsKey) ?? [];
      downloads.removeWhere((download) => download.startsWith('$surahIndex|'));
      await prefs.setStringList(_downloadsKey, downloads);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Shows a dialog for user to select which website to use
  static Future<Map<String, String>?> _showWebsiteSelectionDialog(BuildContext context) async {
    if (!context.mounted) return null;
    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Choose Website',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _quranWebsites.map((website) {
              return ListTile(
                leading: const Icon(Icons.language, color: Colors.green),
                title: Text(
                  website['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Download from ${website['name']}',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.of(dialogContext).pop(website),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Gets real download URL for a surah from MP3Quran.net
  static String _getRealDownloadUrl(int surahIndex) {
    // Using MP3Quran.net API with Abdul Rahman Al-Sudais recitation
    // This is a working server with high-quality audio
    final paddedIndex = surahIndex.toString().padLeft(3, '0');
    return 'https://www.mp3quran.net/sds/$paddedIndex.mp3';
  }

  /// Shows an error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog before downloading
  static Future<bool> showDownloadConfirmation({
    required BuildContext context,
    required String surahName,
    required String surahNameEnglish,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Download Surah',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Download this surah to your device for offline listening:',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                surahName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textDirection: TextDirection.rtl,
              ),
              Text(
                surahNameEnglish,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Note: The surah will be downloaded with Noreen recitation and integrated with the app\'s audio player.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Download'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Shows download progress dialog
  static Future<void> showDownloadProgress({
    required BuildContext context,
    required String surahName,
    required String surahNameEnglish,
    required Function(double) onProgress,
    required VoidCallback onComplete,
    required Function(String) onError,
  }) async {
    double progress = 0.0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Downloading...'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$surahName ($surahNameEnglish)'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toInt()}%'),
                ],
              ),
            );
          },
        );
      },
    );

    // Set up progress callback
    onProgress = (double value) {
      progress = value;
      // Note: In a real implementation, you'd need to use a proper state management solution
      // to update the dialog's progress. For now, this is a simplified version.
    };

    // Set up completion callback
    onComplete = () {
      Navigator.of(context).pop();
      _showSuccessDialog(context, surahName, surahNameEnglish);
    };

    // Set up error callback
    onError = (String error) {
      Navigator.of(context).pop();
      _showErrorDialog(context, error);
    };
  }

  /// Shows success dialog
  static void _showSuccessDialog(BuildContext context, String surahName, String surahNameEnglish) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Download Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text('$surahName ($surahNameEnglish)'),
              const SizedBox(height: 8),
              const Text('has been downloaded successfully. You can now play it offline!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Saves download record to SharedPreferences
  static Future<void> _saveDownloadRecord(
    int surahIndex,
    String filePath,
    String surahName,
    String surahNameEnglish,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloads = prefs.getStringList(_downloadsKey) ?? [];
      final record = '$surahIndex|$filePath|$surahName|$surahNameEnglish';
      
      // Remove existing record if any
      downloads.removeWhere((download) => download.startsWith('$surahIndex|'));
      
      // Add new record
      downloads.add(record);
      await prefs.setStringList(_downloadsKey, downloads);
    } catch (e) {
      print('Error saving download record: $e');
    }
  }

  /// Checks and requests storage permissions
  static Future<bool> _checkPermissions() async {
    try {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      }
      
      final result = await Permission.storage.request();
      return result.isGranted;
    } catch (e) {
      return false;
    }
  }
} 