import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';
import '../../core/location_service.dart';
import '../widgets/category_button.dart';
import '../widgets/location_permission_dialog.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../main.dart' as main_app show AppBackground;
import 'package:geocoding/geocoding.dart';
import '../../core/notification_service.dart';
import 'qibla_screen.dart';

// Top-level function for calculation method selection
// Comprehensive mapping of countries to their official calculation methods
int getCalculationMethodForCountry(String? country) {
  if (country == null) return 3; // Default to MWL
  final c = country.toLowerCase();
  
  // GULF COUNTRIES - Umm Al-Qura (Method 4)
  if (c.contains('saudi') || c.contains('arabia')) return 4;
  if (c.contains('qatar')) return 4;
  if (c.contains('kuwait')) return 4;
  if (c.contains('uae') || c.contains('emirates')) return 4;
  if (c.contains('oman')) return 4;
  if (c.contains('bahrain')) return 4;
  if (c.contains('yemen')) return 4;
  
  // TURKEY - Diyanet (Method 13)
  if (c.contains('turkey') || c.contains('türkiye')) return 13;
  
  // SOUTHEAST ASIA - Various methods
  if (c.contains('singapore')) return 15; // MUIS
  if (c.contains('malaysia')) return 8; // JAKIM
  if (c.contains('brunei')) return 8; // JAKIM
  if (c.contains('indonesia')) return 11; // Kemenag
  if (c.contains('thailand')) return 3; // MWL
  if (c.contains('philippines')) return 3; // MWL
  
  // SOUTH ASIA - Karachi method (Method 7)
  if (c.contains('pakistan')) return 7;
  if (c.contains('bangladesh')) return 7;
  if (c.contains('india')) return 7;
  if (c.contains('afghanistan')) return 7;
  if (c.contains('sri lanka')) return 3; // MWL
  if (c.contains('nepal')) return 7;
  if (c.contains('maldives')) return 3; // MWL
  
  // MIDDLE EAST - Various methods
  if (c.contains('egypt')) return 5; // Egyptian General Authority
  if (c.contains('jordan')) return 3; // MWL
  if (c.contains('palestine')) return 5; // Egyptian method
  if (c.contains('lebanon')) return 3; // MWL
  if (c.contains('syria')) return 3; // MWL
  if (c.contains('iraq')) return 3; // MWL
  if (c.contains('iran')) return 99; // Tehran (Jafari)
  
  // NORTH AFRICA - Muslim World League (Method 3)
  if (c.contains('algeria')) return 3;
  if (c.contains('morocco')) return 3;
  if (c.contains('tunisia')) return 3;
  if (c.contains('libya')) return 3;
  if (c.contains('mauritania')) return 3;
  if (c.contains('sudan')) return 3;
  
  // SUB-SAHARAN AFRICA - MWL (Method 3)
  if (c.contains('nigeria')) return 3;
  if (c.contains('senegal')) return 3;
  if (c.contains('mali')) return 3;
  if (c.contains('somalia')) return 3;
  if (c.contains('kenya')) return 3;
  if (c.contains('tanzania')) return 3;
  if (c.contains('ethiopia')) return 3;
  if (c.contains('south africa')) return 3;
  
  // EUROPE - Various methods
  if (c.contains('france')) return 12; // UOIF
  if (c.contains('united kingdom') || c.contains('britain') || c.contains('england') || c.contains('scotland') || c.contains('wales')) return 3; // MWL
  if (c.contains('germany')) return 3; // MWL
  if (c.contains('netherlands')) return 3; // MWL
  if (c.contains('belgium')) return 3; // MWL
  if (c.contains('spain')) return 3; // MWL
  if (c.contains('italy')) return 3; // MWL
  if (c.contains('sweden')) return 3; // MWL
  if (c.contains('norway')) return 3; // MWL
  if (c.contains('denmark')) return 3; // MWL
  if (c.contains('austria')) return 3; // MWL
  if (c.contains('switzerland')) return 3; // MWL
  if (c.contains('bosnia')) return 3; // MWL
  if (c.contains('albania')) return 3; // MWL
  if (c.contains('kosovo')) return 3; // MWL
  
  // RUSSIA & CENTRAL ASIA
  if (c.contains('russia')) return 14; // Russian method
  if (c.contains('kazakhstan')) return 14;
  if (c.contains('uzbekistan')) return 14;
  if (c.contains('turkmenistan')) return 14;
  if (c.contains('kyrgyzstan')) return 14;
  if (c.contains('tajikistan')) return 14;
  if (c.contains('azerbaijan')) return 14;
  
  // NORTH AMERICA - ISNA (Method 2)
  if (c.contains('united states') || c.contains('usa') || c.contains('america')) return 2;
  if (c.contains('canada')) return 2;
  if (c.contains('mexico')) return 2;
  
  // SOUTH AMERICA - ISNA (Method 2)
  if (c.contains('brazil')) return 2;
  if (c.contains('argentina')) return 2;
  if (c.contains('chile')) return 2;
  if (c.contains('colombia')) return 2;
  if (c.contains('venezuela')) return 2;
  
  // OCEANIA - MWL (Method 3)
  if (c.contains('australia')) return 3;
  if (c.contains('new zealand')) return 3;
  
  // EAST ASIA - MWL (Method 3)
  if (c.contains('china')) return 3;
  if (c.contains('japan')) return 3;
  if (c.contains('korea')) return 3;
  
  // Default to Muslim World League for any unspecified country
  return 3; // MWL - Most widely accepted method globally
}

class PrayerTime {
  final String name;
  final IconData icon;
  final DateTime time;
  bool notificationEnabled;
  PrayerTime({required this.name, required this.icon, required this.time, this.notificationEnabled = false});
}

class PrayersScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const PrayersScreen({super.key, this.scrollController});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

// Helper widget for circular icon buttons
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _CircleIconButton({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 16, color: iconColor ?? Colors.grey[700]),
        ),
      ),
    );
  }
}

class _PrayersScreenState extends State<PrayersScreen> {
  List<int>? _manualOffsets; // null = never touched, otherwise manual offsets in minutes
  // Placeholder for city name
  String _city = 'Barika';
  // Placeholder for prayer times
  List<PrayerTime> _prayerTimes = [];
  // Next prayer info
  String _nextPrayerName = '';
  DateTime? _nextPrayerTime;
  Duration _timeLeft = Duration.zero;
  // Timer
  late final Ticker _ticker;
  // Notification states for Qiyam and Midnight
  bool qiyamNotif = false;
  bool midnightNotif = false;
  // Calculated times for Qiyam and Midnight
  DateTime? _calculatedMidnight;
  DateTime? _calculatedQiyam;
  // Add a mapping from prayer name to image asset
  final Map<String, String> _prayerImages = {
    'Fajr': 'lib/images/500640FA-FF23-4FBE-B72F-43E8DD396CBD.JPEG',
    'Dhuhr': 'lib/images/8D16B5CB-AB41-46CF-8D32-6A8980E2C93A.JPEG',
    'Asr': 'lib/images/IMG_1298.PNG',
    'Maghrib':'lib/images/IMG_1290.JPG' ,
    'Isha': 'lib/images/D1F96321-607E-4FCC-A79F-6E45365E1CF2.JPEG',
  };

  @override
  void initState() {
    super.initState();
    _loadNotificationStates();
    _initLocationAndPrayerTimes();
    _ticker = Ticker(_updateCountdown, mountedCheck: () => mounted)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // Load notification states from SharedPreferences
  void _loadNotificationStates() {
    SharedPreferences.getInstance().then((prefs) {
      if (mounted) {
        setState(() {
          qiyamNotif = prefs.getBool('qiyam_notification') ?? false;
          midnightNotif = prefs.getBool('midnight_notification') ?? false;
        });
      }
    });
  }

  // Load prayer notification states from SharedPreferences
  Future<void> _loadPrayerNotificationStates() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _prayerTimes.length; i++) {
      final key = 'prayer_notification_${_prayerTimes[i].name.toLowerCase()}';
      _prayerTimes[i].notificationEnabled = prefs.getBool(key) ?? false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  // Save notification state to SharedPreferences
  Future<void> _saveNotificationState(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Calculate Islamic Midnight and Qiyam times
  void _calculateNightTimes() {
    if (_prayerTimes.isEmpty) return;
    
    // Find Maghrib and Fajr times
    DateTime? maghribTime;
    DateTime? fajrTime;
    
    for (var prayer in _prayerTimes) {
      if (prayer.name == 'Maghrib') maghribTime = prayer.time;
      if (prayer.name == 'Fajr') fajrTime = prayer.time;
    }
    
    if (maghribTime == null || fajrTime == null) return;
    
    // Fajr is next day, so add 24 hours if it appears before Maghrib
    if (fajrTime.isBefore(maghribTime)) {
      fajrTime = fajrTime.add(const Duration(days: 1));
    }
    
    // Islamic Midnight = Halfway between Maghrib and Fajr
    final nightDuration = fajrTime.difference(maghribTime);
    _calculatedMidnight = maghribTime.add(Duration(milliseconds: (nightDuration.inMilliseconds / 2).round()));
    
    // Last Third of Night (Best time for Qiyam) = Maghrib + (2/3 of night duration)
    _calculatedQiyam = maghribTime.add(Duration(milliseconds: ((nightDuration.inMilliseconds * 2) / 3).round()));
    
    if (mounted) {
      setState(() {});
    }
  }

  // Toggle Qiyam notification
  void _toggleQiyamNotif() async {
    setState(() {
      qiyamNotif = !qiyamNotif;
    });
    await _saveNotificationState('qiyam_notification', qiyamNotif);
    
    if (qiyamNotif) {
      // Use calculated Qiyam time (last third of night)
      if (_calculatedQiyam == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Unable to calculate Qiyam time. Please wait for prayer times to load.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      var scheduledTime = _calculatedQiyam!;
      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      await NotificationService.schedulePrayerNotification(
        id: 100, // Unique ID for Qiyam
        title: "It's time for Qiyam (Last Third of Night)",
        body: 'The best time for night prayer has arrived.',
        scheduledTime: scheduledTime,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Qiyam notification enabled'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black.withOpacity(0.85),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await NotificationService.cancelNotification(100);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Qiyam notification disabled'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black.withOpacity(0.85),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Toggle Midnight notification
  void _toggleMidnightNotif() async {
    setState(() {
      midnightNotif = !midnightNotif;
    });
    await _saveNotificationState('midnight_notification', midnightNotif);
    
    if (midnightNotif) {
      // Use calculated Islamic Midnight (halfway between Maghrib and Fajr)
      if (_calculatedMidnight == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Unable to calculate Midnight time. Please wait for prayer times to load.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      var scheduledTime = _calculatedMidnight!;
      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      await NotificationService.schedulePrayerNotification(
        id: 101, // Unique ID for Midnight
        title: "It's time for Islamic Midnight",
        body: 'Halfway through the night - a blessed time for prayer.',
        scheduledTime: scheduledTime,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Midnight notification enabled'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black.withOpacity(0.85),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await NotificationService.cancelNotification(101);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Midnight notification disabled'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black.withOpacity(0.85),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _initLocationAndPrayerTimes() async {
    if (mounted) {
      setState(() {
        _city = 'Loading...';
      });
    }
    
    try {
      // Try to get current location using the location service
      final locationData = await LocationService.getCurrentLocation();
      
      if (locationData != null) {
        _updatePrayerTimes(locationData['lat'], locationData['lng'], locationData['city'], locationData['country']);
      } else {
        // If no location available, show permission dialog
        if (mounted) {
          _showLocationPermissionDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _city = 'Location error';
        });
      }
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        title: 'Location Required',
        message: 'To provide accurate prayer times for your location, we need access to your location.',
        onAllow: () async {
          Navigator.of(context).pop();
          final locationData = await LocationService.getCurrentLocation(forceRequest: true);
          if (locationData != null && mounted) {
            _updatePrayerTimes(locationData['lat'], locationData['lng'], locationData['city'], locationData['country']);
          } else if (mounted) {
            setState(() {
              _city = 'Location denied';
            });
          }
        },
        onDeny: () {
          Navigator.of(context).pop();
          if (mounted) {
            setState(() {
              _city = 'Location denied';
            });
          }
        },
      ),
    );
  }

  Future<void> _updatePrayerTimes(double lat, double lng, String city, [String? country]) async {
    try {
      final apiPrayerTimes = await _fetchPrayerTimesFromAPI(lat, lng, country);
      if (apiPrayerTimes != null && apiPrayerTimes.isNotEmpty) {
        if (mounted) {
          setState(() {
            _city = city;
            _prayerTimes = apiPrayerTimes;
            _updateNextPrayer();
          });
        }
        _loadManualOffsets();
        // Calculate night times (Midnight and Qiyam)
        _calculateNightTimes();
        // Load notification states after prayer times are set
        await _loadPrayerNotificationStates();
        return;
      }
    } catch (e) {
      print('API prayer times failed: $e');
    }
    if (mounted) {
      setState(() {
        _city = city;
        _prayerTimes = [];
        _nextPrayerName = 'Error';
        _nextPrayerTime = null;
        _timeLeft = Duration.zero;
      });
    }
  }

  Future<List<PrayerTime>?> _fetchPrayerTimesFromAPI(double lat, double lng, [String? country]) async {
    try {
      final date = DateTime.now();
      final method = getCalculationMethodForCountry(country);
      
      // Use calendar endpoint with DD-MM-YYYY format and timezone auto-detection for most accurate results
      final dateStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      final url = 'https://api.aladhan.com/v1/timings/$dateStr?latitude=$lat&longitude=$lng&method=$method';
      
      print('Fetching prayer times for $country from: $url');
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        final meta = data['data']['meta'];
        print('API Response - Location: ${meta['timezone']}, Method: ${meta['method']['name']}');
        print('Prayer times: Fajr=${timings['Fajr']}, Dhuhr=${timings['Dhuhr']}, Asr=${timings['Asr']}, Maghrib=${timings['Maghrib']}, Isha=${timings['Isha']}');
        return [
          if (timings['Fajr'] != null)
            PrayerTime(
              name: 'Fajr', 
              icon: Icons.nightlight_round, 
              time: _parseTimeString(timings['Fajr'])
            ),
          if (timings['Dhuhr'] != null)
            PrayerTime(
              name: 'Dhuhr', 
              icon: Icons.wb_sunny_outlined, 
              time: _parseTimeString(timings['Dhuhr'])
            ),
          if (timings['Asr'] != null)
            PrayerTime(
              name: 'Asr', 
              icon: Icons.wb_twilight, 
              time: _parseTimeString(timings['Asr'])
            ),
          if (timings['Maghrib'] != null)
            PrayerTime(
              name: 'Maghrib', 
              icon: Icons.nights_stay, 
              time: _parseTimeString(timings['Maghrib'])
            ),
          if (timings['Isha'] != null)
            PrayerTime(
              name: 'Isha', 
              icon: Icons.nightlight_round, 
              time: _parseTimeString(timings['Isha'])
            ),
        ];
      }
    } catch (e) {
      print('Error fetching prayer times from API: $e');
    }
    return null;
  }

  DateTime _parseTimeString(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    // Create time in local timezone
    // The API returns times in the location's local time, so we create a DateTime
    // that represents that time in the user's current timezone
    final localTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // Debug: Print the parsed time
    print('Parsed time: $timeStr -> ${localTime.toString()}');
    
    return localTime;
  }

  Future<void> _loadManualOffsets() async {
    final prefs = await SharedPreferences.getInstance();
    final offsets = List<int>.generate(_prayerTimes.length, (i) => prefs.getInt('prayer_offset_$i') ?? 0);
    final touched = offsets.any((o) => o != 0);
    if (mounted) {
      setState(() {
        _manualOffsets = touched ? offsets : null;
      });
    }
  }

  DateTime getEffectivePrayerTime(int idx) {
    if (_manualOffsets != null && idx < _manualOffsets!.length) {
      return _prayerTimes[idx].time.add(Duration(minutes: _manualOffsets![idx]));
    }
    return _prayerTimes[idx].time;
  }

  void _updateNextPrayer() {
    final now = DateTime.now();
    for (int i = 0; i < _prayerTimes.length; i++) {
      final pt = _prayerTimes[i];
      final effectiveTime = getEffectivePrayerTime(i);
      if (effectiveTime.isAfter(now)) {
        _nextPrayerName = pt.name;
        _nextPrayerTime = effectiveTime;
        _timeLeft = effectiveTime.difference(now);
        if (mounted) {
          setState(() {});
        }
        return;
      }
    }
    // If all passed, next is tomorrow's Fajr (with offset if any)
    final firstEffective = getEffectivePrayerTime(0);
    final tomorrowFajr = firstEffective.add(const Duration(days: 1));
    _nextPrayerName = _prayerTimes.first.name;
    _nextPrayerTime = tomorrowFajr;
    _timeLeft = tomorrowFajr.difference(now);
    if (mounted) {
      setState(() {});
    }
  }

  void _updateCountdown(Duration _) {
    if (_nextPrayerTime != null && mounted) {
      final now = DateTime.now();
      setState(() {
        _timeLeft = _nextPrayerTime!.difference(now);
        if (_timeLeft.isNegative) {
          _updateNextPrayer();
        }
      });
    }
  }

  void _toggleNotification(int idx) async {
    if (mounted) {
      setState(() {
        _prayerTimes[idx].notificationEnabled = !_prayerTimes[idx].notificationEnabled;
      });
      final pt = _prayerTimes[idx];
      final id = idx + 1; // Unique ID per prayer
      
      // Save notification state to SharedPreferences
      final key = 'prayer_notification_${pt.name.toLowerCase()}';
      await _saveNotificationState(key, pt.notificationEnabled);
      
      if (pt.notificationEnabled) {
        await NotificationService.schedulePrayerNotification(
          id: id,
          title: "It's time for ${pt.name}",
          body: 'Time to pray ${pt.name}.',
          scheduledTime: getEffectivePrayerTime(idx),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pt.name} notification enabled'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await NotificationService.cancelNotification(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pt.name} notification disabled'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black.withOpacity(0.85),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _showCityPicker() async {
    final List<Map<String, Object>> cityData = [
      // North African Cities
      {'name': 'Algiers', 'lat': 36.7538, 'lng': 3.0588},
      {'name': 'Casablanca', 'lat': 33.5731, 'lng': -7.5898},
      {'name': 'Tunis', 'lat': 36.8065, 'lng': 10.1815},
      {'name': 'Cairo', 'lat': 30.0444, 'lng': 31.2357},
      {'name': 'Barika', 'lat': 35.3894, 'lng': 5.3658},
    ];
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose a city'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: cityData.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, idx) {
              final city = cityData[idx];
              return ListTile(
                title: Text(city['name'] as String),
                onTap: () => Navigator.of(context).pop(city),
              );
            },
          ),
        ),
      ),
    );
    if (selected != null) {
      final name = selected['name'] as String;
      final lat = (selected['lat'] as num).toDouble();
      final lng = (selected['lng'] as num).toDouble();
      await _setManualLocation(name, lat, lng);
    }
  }

  Future<void> _setManualLocation(String city, double lat, double lng) async {
    // Use the same improved calculation logic as _updatePrayerTimes
    await _updatePrayerTimes(lat, lng, city);
  }

  void _showManualSettingsDialog() {
    final timeFormat = DateFormat('h:mm a');
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final prefs = snapshot.data!;
            List<int> manualOffsets = List.generate(_prayerTimes.length, (i) => prefs.getInt('prayer_offset_$i') ?? 0);
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  backgroundColor: const Color(0xFFF8FAF8), // Soft background
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.92, // Wider dialog
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Manual Settings',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(_prayerTimes.length, (i) {
                          final pt = _prayerTimes[i];
                          final adjustedTime = pt.time.add(Duration(minutes: manualOffsets[i]));
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pt.name,
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      timeFormat.format(adjustedTime),
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _CircleIconButton(
                                      icon: Icons.remove,
                                      onTap: () async {
                                        setStateDialog(() {
                                          manualOffsets[i]--;
                                        });
                                        await prefs.setInt('prayer_offset_$i', manualOffsets[i]);
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    _CircleIconButton(
                                      icon: Icons.add,
                                      onTap: () async {
                                        setStateDialog(() {
                                          manualOffsets[i]++;
                                        });
                                        await prefs.setInt('prayer_offset_$i', manualOffsets[i]);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              if (i != _prayerTimes.length - 1)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(height: 1, thickness: 0.5, color: Color(0xFFB2C2B9)),
                                ),
                            ],
                          );
                        }),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _manualOffsets = List<int>.from(manualOffsets);
                              });
                              for (int i = 0; i < _prayerTimes.length; i++) {
                                if (_prayerTimes[i].notificationEnabled) {
                                  await NotificationService.schedulePrayerNotification(
                                    id: i + 1,
                                    title: "It's time for ${_prayerTimes[i].name}",
                                    body: 'Time to pray ${_prayerTimes[i].name}.',
                                    scheduledTime: _prayerTimes[i].time.add(Duration(minutes: manualOffsets[i])),
                                  );
                                }
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Prayer notifications updated to manual times'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.black.withOpacity(0.85),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.forestGreen,
                              elevation: 2,
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showQiyamMidnightDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Persist state within the dialog
            return _QiyamMidnightDialogContent(
              calculatedQiyam: _calculatedQiyam,
              calculatedMidnight: _calculatedMidnight,
              onQiyamToggle: _toggleQiyamNotif,
              onMidnightToggle: _toggleMidnightNotif,
              qiyamEnabled: qiyamNotif,
              midnightEnabled: midnightNotif,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final forestGreen = AppColors.forestGreen;
    final white = AppColors.white;
    final timeFormat = DateFormat('h:mm a');
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: Icon(Icons.explore_outlined, color: AppColors.forestGreen, size: 32),
            padding: const EdgeInsets.only(left: 12.0, right: 4.0), // moves the icon, not the tap area
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const QiblaPage()),
              );
            },
          ),
          title: Text('Prayers', style: GoogleFonts.poppins(color: AppColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 24)),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),
              // 1. Next Prayer Box (IMAGE BACKGROUND STYLE)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Stack(
                    children: [
                      // Remove BackdropFilter and glassmorphic container, use image background
                      Container(
                        height: 200.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(color: AppColors.forestGreen, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.forestGreen.withOpacity(0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          image: _prayerImages[_nextPrayerName] != null
                              ? DecorationImage(
                                  image: AssetImage(_prayerImages[_nextPrayerName]!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: null,
                      ),
                      Container(
                        height: 200.0,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(color: Colors.transparent),
                          color: Colors.white.withOpacity(0.15), // reduced overlay for less blur
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Next Prayer • ${_formatDuration(_timeLeft)} left',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 6,
                                        offset: Offset(0, 0), // thick border
                                      ),
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(2, 2), // reduced soft shadow
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.access_time, color: Colors.black.withOpacity(0.7), size: 20),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _nextPrayerName,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 8,
                                            offset: Offset(0, 0), // thick border
                                          ),
                                          Shadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(2, 2), // reduced soft shadow
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _nextPrayerTime != null ? timeFormat.format(_nextPrayerTime!) : '--:--',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 8,
                                            offset: Offset(0, 0), // thick border
                                          ),
                                          Shadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(2, 2), // reduced soft shadow
                                          ),
                                        ],
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
              ),
              // 2. Location Display Row styled like hijri date in Athkar
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(
                        thickness: 1.2,
                        endIndent: 12,
                        color: Color(0xFFB2C2B9),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: forestGreen, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _city,
                            style: GoogleFonts.poppins(
                              color: forestGreen,
                              fontWeight: FontWeight.bold, // changed from w500 to bold
                              fontSize: 18, // changed from 15 to 18
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showCityPicker(),
                            child: Icon(Icons.add_circle_outline, color: forestGreen, size: 22),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 1.2,
                        indent: 12,
                        color: Color(0xFFB2C2B9),
                      ),
                    ),
                  ],
                ),
              ),
              // 3. Prayer Times List
              // Prayer cards container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.32),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withOpacity(0.10),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.forestGreen.withOpacity(0.13), width: 3.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_prayerTimes.length, (idx) {
                          final pt = _prayerTimes[idx];
                          if (pt.name == 'Sunrise') return SizedBox.shrink(); // filter out Sunrise
                          final effectiveTime = getEffectivePrayerTime(idx);
                          return Padding(
                            padding: EdgeInsets.only(bottom: idx == _prayerTimes.length - 1 ? 0 : 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.forestGreen.withOpacity(0.13),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(color: AppColors.forestGreen.withOpacity(0.18)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                  child: Row(
                                    children: [
                                      Icon(pt.icon, color: AppColors.forestGreen, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          pt.name,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 16.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                      Text(
                                        timeFormat.format(effectiveTime),
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                              IconButton(
                                                icon: Icon(
                                                  pt.notificationEnabled ? Icons.notifications_active : Icons.notifications_none,
                                                  color: pt.notificationEnabled ? AppColors.forestGreen : Colors.grey[600],
                                                ),
                                                onPressed: () => _toggleNotification(idx),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              // 4. Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Column(
                  children: [
                    CategoryButton(
                      icon: Icons.settings,
                      title: 'Prayer Settings',
                      onTap: _showManualSettingsDialog,
                    ),
                    SizedBox(height: 8),
                    CategoryButton(
                      icon: Icons.bed_outlined,
                      title: 'Sleep Mode',
                      onTap: () {},
                    ),
                    SizedBox(height: 8),
                    CategoryButton(
                      icon: Icons.calendar_month,
                      title: 'Monthly Calendar',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MonthlyPrayerCalendarPage(city: _city),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    CategoryButton(
                      icon: Icons.notifications_off,
                      title: 'Qiyam & Midnight',
                      onTap: _showQiyamMidnightDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds < 0) return '--:--:--';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _ActionPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionPillButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final forestGreen = AppColors.forestGreen;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: forestGreen, width: 1.5),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: forestGreen, size: 20),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: forestGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ticker for live countdown
class Ticker {
  final void Function(Duration) onTick;
  final bool Function()? mountedCheck;
  late final Stopwatch _stopwatch;
  late final Duration _interval;
  bool _running = false;
  
  Ticker(this.onTick, {Duration interval = const Duration(seconds: 1), this.mountedCheck}) {
    _interval = interval;
    _stopwatch = Stopwatch();
  }
  
  void start() {
    if (_running) return;
    _running = true;
    _stopwatch.start();
    _tick();
  }
  
  void _tick() async {
    while (_running) {
      await Future.delayed(_interval);
      if (!_running) break;
      
      // Check if widget is still mounted before calling onTick
      if (mountedCheck == null || mountedCheck!()) {
        onTick(_stopwatch.elapsed);
      } else {
        // Widget is no longer mounted, stop the ticker
        _running = false;
        break;
      }
    }
  }
  
  void dispose() {
    _running = false;
    _stopwatch.stop();
  }
}

class _QiyamMidnightCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String time;
  final bool notificationEnabled;
  final VoidCallback onBellTap;
  const _QiyamMidnightCard({
    required this.label,
    required this.icon,
    required this.time,
    required this.notificationEnabled,
    required this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EC),
        borderRadius: BorderRadius.circular(38),
        border: Border.all(color: AppColors.forestGreen.withOpacity(0.10), width: 2), // Green frame like prayer cards
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.forestGreen, size: 24), // No circle, just green icon
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500, // Slightly bolder
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              notificationEnabled ? Icons.notifications_active : Icons.notifications_none,
              color: notificationEnabled ? AppColors.forestGreen : Colors.grey[500],
              size: 24, // Make bell bigger
            ),
            onPressed: onBellTap,
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}

class _QiyamMidnightDialogContent extends StatelessWidget {
  final DateTime? calculatedQiyam;
  final DateTime? calculatedMidnight;
  final VoidCallback onQiyamToggle;
  final VoidCallback onMidnightToggle;
  final bool qiyamEnabled;
  final bool midnightEnabled;

  const _QiyamMidnightDialogContent({
    required this.calculatedQiyam,
    required this.calculatedMidnight,
    required this.onQiyamToggle,
    required this.onMidnightToggle,
    required this.qiyamEnabled,
    required this.midnightEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final qiyamTimeStr = calculatedQiyam != null ? timeFormat.format(calculatedQiyam!) : '--:--';
    final midnightTimeStr = calculatedMidnight != null ? timeFormat.format(calculatedMidnight!) : '--:--';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: const Color(0xFFF8FAF8), // Soft background
      child: Container(
        width: MediaQuery.of(context).size.width * 0.99, // Even wider dialog
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Qiyam & Midnight',
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 24),
            _QiyamMidnightCard(
              label: 'Qiyam',
              icon: Icons.nightlight_round,
              time: qiyamTimeStr,
              notificationEnabled: qiyamEnabled,
              onBellTap: onQiyamToggle,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1, thickness: 0.5, color: Color(0xFFB2C2B9)),
            ),
            _QiyamMidnightCard(
              label: 'Midnight',
              icon: Icons.nights_stay,
              time: midnightTimeStr,
              notificationEnabled: midnightEnabled,
              onBellTap: onMidnightToggle,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.forestGreen,
                  elevation: 2,
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyPrayerCalendarPage extends StatefulWidget {
  final String city;
  const MonthlyPrayerCalendarPage({super.key, required this.city});

  @override
  State<MonthlyPrayerCalendarPage> createState() => _MonthlyPrayerCalendarPageState();
}

class _MonthlyPrayerCalendarPageState extends State<MonthlyPrayerCalendarPage> {
  late DateTime _now;
  late int _hijriMonth;
  late int _hijriYear;
  late String _hijriMonthName;
  List<List<PrayerTime>>? _monthPrayerTimes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    final hijri = HijriCalendar.now();
    _hijriMonth = hijri.hMonth;
    _hijriYear = hijri.hYear;
    _hijriMonthName = hijri.longMonthName;
    _fetchMonthlyPrayerTimes();
  }

  Future<void> _fetchMonthlyPrayerTimes() async {
    if (mounted) {
      setState(() { _loading = true; _error = null; });
    }
    try {
      // Get location (reuse logic from PrayersScreen)
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double lng = position.longitude;
      // Get country using reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      String country = placemarks.isNotEmpty ? (placemarks.first.country ?? 'Unknown') : 'Unknown';
      int method = getCalculationMethodForCountry(country);
      // Get first day of this hijri month in Gregorian
      final hijri = HijriCalendar()
        ..hYear = _hijriYear
        ..hMonth = _hijriMonth
        ..hDay = 1;
      DateTime firstDay = hijri.hijriToGregorian(_hijriYear, _hijriMonth, 1);
      int daysInMonth = hijri.getDaysInMonth(_hijriYear, _hijriMonth);
      // Load manual offsets
      final prefs = await SharedPreferences.getInstance();
      final List<int> manualOffsets = [
        prefs.getInt('prayer_offset_0') ?? 0,
        prefs.getInt('prayer_offset_1') ?? 0,
        prefs.getInt('prayer_offset_2') ?? 0,
        prefs.getInt('prayer_offset_3') ?? 0,
        prefs.getInt('prayer_offset_4') ?? 0,
      ];
      final List<String> prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      List<List<PrayerTime>> monthTimes = [];
      for (int i = 0; i < daysInMonth; i++) {
        DateTime day = firstDay.add(Duration(days: i));
        final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final url = 'http://api.aladhan.com/v1/timings/$dayStr?latitude=$lat&longitude=$lng&method=$method';
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final timings = data['data']['timings'];
            // Build the list and apply manual offsets
            final List<PrayerTime> dayPrayers = [];
            int offsetIdx = 0;
            if (timings['Fajr'] != null) {
              dayPrayers.add(PrayerTime(
                name: 'Fajr',
                icon: Icons.nightlight_round,
                time: _parseTimeStringForCalendar(timings['Fajr'], day).add(Duration(minutes: manualOffsets[0])),
              ));
              offsetIdx++;
            }
            if (timings['Sunrise'] != null) {
              dayPrayers.add(PrayerTime(
                name: 'Sunrise',
                icon: Icons.wb_sunny,
                time: _parseTimeStringForCalendar(timings['Sunrise'], day),
              ));
            }
            if (timings['Dhuhr'] != null) {
              dayPrayers.add(PrayerTime(
                name: 'Dhuhr',
                icon: Icons.wb_sunny_outlined,
                time: _parseTimeStringForCalendar(timings['Dhuhr'], day).add(Duration(minutes: manualOffsets[1])),
              ));
              offsetIdx++;
            }
            if (timings['Asr'] != null) {
              dayPrayers.add(PrayerTime(
                name: 'Asr',
                icon: Icons.wb_twilight,
                time: _parseTimeStringForCalendar(timings['Asr'], day).add(Duration(minutes: manualOffsets[2])),
              ));
              offsetIdx++;
            }
            if (timings['Maghrib'] != null) {
              dayPrayers.add(PrayerTime(
                name: 'Maghrib',
                icon: Icons.nights_stay,
                time: _parseTimeStringForCalendar(timings['Maghrib'], day).add(Duration(minutes: manualOffsets[3])),
              ));
              offsetIdx++;
            }
            if (timings['Isha'] != null) {
              dayPrayers.add(PrayerTime(
                name: 'Isha',
                icon: Icons.nightlight_round,
                time: _parseTimeStringForCalendar(timings['Isha'], day).add(Duration(minutes: manualOffsets[4])),
              ));
              offsetIdx++;
            }
            monthTimes.add(dayPrayers);
          } else {
            monthTimes.add([]);
          }
        } catch (e) {
          print('Error fetching prayer times for day $dayStr: $e');
          monthTimes.add([]);
        }
      }
      if (mounted) {
        setState(() {
          _monthPrayerTimes = monthTimes;
          _loading = false;
        });
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('denied')) {
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Location Permission Needed'),
              content: Text('To show the monthly prayer calendar, please enable location permissions in your device settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() { _error = errorMsg; _loading = false; });
        }
      }
    }
  }

  DateTime _parseTimeStringForCalendar(String timeStr, DateTime day) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final forestGreen = AppColors.forestGreen;
    return Stack(
      children: [
        const main_app.AppBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('$_hijriMonthName $_hijriYear', style: GoogleFonts.poppins(color: forestGreen, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: forestGreen),
            centerTitle: true,
          ),
          body: _loading
              ? Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.32),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: forestGreen.withOpacity(0.10),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              border: Border.all(color: forestGreen.withOpacity(0.13), width: 3.5),
                            ),
                            child: ListView.builder(
                              itemCount: _monthPrayerTimes!.length,
                              itemBuilder: (context, idx) {
                                final hijriDay = idx + 1;
                                final prayers = _monthPrayerTimes![idx];
                                final hijriDayObj = HijriCalendar()
                                  ..hYear = _hijriYear
                                  ..hMonth = _hijriMonth
                                  ..hDay = hijriDay;
                                final gregorianDate = hijriDayObj.hijriToGregorian(_hijriYear, _hijriMonth, hijriDay);
                                
                                // Check if this is today
                                final isToday = gregorianDate.year == _now.year && 
                                                gregorianDate.month == _now.month && 
                                                gregorianDate.day == _now.day;
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isToday 
                                          ? forestGreen.withOpacity(0.18) 
                                          : forestGreen.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(24),
                                      border: isToday 
                                          ? Border.all(color: forestGreen.withOpacity(0.4), width: 2)
                                          : null,
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        childrenPadding: const EdgeInsets.only(bottom: 12),
                                        title: Row(
                                          children: [
                                            Text(
                                              'Day $hijriDay',
                                              style: GoogleFonts.poppins(
                                                color: forestGreen,
                                                fontWeight: isToday ? FontWeight.w800 : FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            if (isToday) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: forestGreen,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Today',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            const SizedBox(width: 12),
                                            Text(
                                              DateFormat('EEE, d MMM').format(gregorianDate),
                                              style: GoogleFonts.poppins(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        children: prayers.map((pt) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(pt.icon, color: forestGreen, size: 24),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      pt.name,
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 15,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('h:mm a').format(pt.time),
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: forestGreen,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const QiblaScreen();
  }
}