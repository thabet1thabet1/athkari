import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../widgets/category_button.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../main.dart';
import 'qibla_screen.dart';

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
  // Add a mapping from prayer name to image asset
  final Map<String, String> _prayerImages = {
    'Fajr': 'lib/images/8D16B5CB-AB41-46CF-8D32-6A8980E2C93A.JPEG',
    'Dhuhr': 'lib/images/500640FA-FF23-4FBE-B72F-43E8DD396CBD.JPEG',
    'Asr': 'lib/images/IMG_1298.PNG',
    'Maghrib': 'lib/images/IMG_1290.JPG',
    'Isha': 'lib/images/D1F96321-607E-4FCC-A79F-6E45365E1CF2.JPEG',
  };

  @override
  void initState() {
    super.initState();
    _initLocationAndPrayerTimes();
    _ticker = Ticker(_updateCountdown)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initLocationAndPrayerTimes() async {
    setState(() {
      _city = 'Loading...';
    });
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _city = 'Location denied';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _city = 'Location denied';
        });
        return;
      }
      // Get current position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double lng = position.longitude;
      // Reverse geocode to get city name
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      String city = placemarks.isNotEmpty ? (placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? placemarks.first.administrativeArea ?? 'Unknown') : 'Unknown';
      // Calculate prayer times
      final params = CalculationMethod.karachi();
      params.madhab = Madhab.hanafi;
      final date = DateTime.now();
      final coordinates = Coordinates(lat, lng);
      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
      );
      setState(() {
        _city = city;
        _prayerTimes = [
          if (prayerTimes.fajr != null)
            PrayerTime(name: 'Fajr', icon: Icons.nightlight_round, time: prayerTimes.fajr!),
          // if (prayerTimes.sunrise != null)
          //   PrayerTime(name: 'Sunrise', icon: Icons.wb_sunny, time: prayerTimes.sunrise!),
          if (prayerTimes.dhuhr != null)
            PrayerTime(name: 'Dhuhr', icon: Icons.wb_sunny_outlined, time: prayerTimes.dhuhr!),
          if (prayerTimes.asr != null)
            PrayerTime(name: 'Asr', icon: Icons.wb_twilight, time: prayerTimes.asr!),
          if (prayerTimes.maghrib != null)
            PrayerTime(name: 'Maghrib', icon: Icons.nights_stay, time: prayerTimes.maghrib!),
          if (prayerTimes.isha != null)
            PrayerTime(name: 'Isha', icon: Icons.nightlight_round, time: prayerTimes.isha!),
        ];
        // Try to load manual offsets if present
        _loadManualOffsets();
        _updateNextPrayer();
      });
    } catch (e) {
      setState(() {
        _city = 'Location error';
      });
    }
  }

  Future<void> _loadManualOffsets() async {
    final prefs = await SharedPreferences.getInstance();
    final offsets = List<int>.generate(_prayerTimes.length, (i) => prefs.getInt('prayer_offset_$i') ?? 0);
    final touched = offsets.any((o) => o != 0);
    setState(() {
      _manualOffsets = touched ? offsets : null;
    });
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
        setState(() {});
        return;
      }
    }
    // If all passed, next is tomorrow's Fajr (with offset if any)
    final firstEffective = getEffectivePrayerTime(0);
    final tomorrowFajr = firstEffective.add(const Duration(days: 1));
    _nextPrayerName = _prayerTimes.first.name;
    _nextPrayerTime = tomorrowFajr;
    _timeLeft = tomorrowFajr.difference(now);
    setState(() {});
  }

  void _updateCountdown(Duration _) {
    if (_nextPrayerTime != null) {
      final now = DateTime.now();
      setState(() {
        _timeLeft = _nextPrayerTime!.difference(now);
        if (_timeLeft.isNegative) {
          _updateNextPrayer();
        }
      });
    }
  }

  void _toggleNotification(int idx) {
    setState(() {
      _prayerTimes[idx].notificationEnabled = !_prayerTimes[idx].notificationEnabled;
      // TODO: Schedule/cancel notification using flutter_local_notifications
    });
  }

  void _showCityPicker() async {
    final List<Map<String, Object>> cityData = [
      {'name': 'Cairo', 'lat': 30.0444, 'lng': 31.2357},
      {'name': 'Riyadh', 'lat': 24.7136, 'lng': 46.6753},
      {'name': 'Istanbul', 'lat': 41.0082, 'lng': 28.9784},
      {'name': 'Jakarta', 'lat': -6.2088, 'lng': 106.8456},
      {'name': 'London', 'lat': 51.5074, 'lng': -0.1278},
      {'name': 'New York', 'lat': 40.7128, 'lng': -74.0060},
      {'name': 'Kuala Lumpur', 'lat': 3.139, 'lng': 101.6869},
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
      _setManualLocation(name, lat, lng);
    }
  }

  void _setManualLocation(String city, double lat, double lng) {
    final params = CalculationMethod.karachi();
    params.madhab = Madhab.hanafi;
    final date = DateTime.now();
    final coordinates = Coordinates(lat, lng);
    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
    );
    setState(() {
      _city = city;
      _prayerTimes = [
        if (prayerTimes.fajr != null)
          PrayerTime(name: 'Fajr', icon: Icons.nightlight_round, time: prayerTimes.fajr!),
        // if (prayerTimes.sunrise != null)
        //   PrayerTime(name: 'Sunrise', icon: Icons.wb_sunny, time: prayerTimes.sunrise!),
        if (prayerTimes.dhuhr != null)
          PrayerTime(name: 'Dhuhr', icon: Icons.wb_sunny_outlined, time: prayerTimes.dhuhr!),
        if (prayerTimes.asr != null)
          PrayerTime(name: 'Asr', icon: Icons.wb_twilight, time: prayerTimes.asr!),
        if (prayerTimes.maghrib != null)
          PrayerTime(name: 'Maghrib', icon: Icons.nights_stay, time: prayerTimes.maghrib!),
        if (prayerTimes.isha != null)
          PrayerTime(name: 'Isha', icon: Icons.nightlight_rounded, time: prayerTimes.isha!),
      ];
      _updateNextPrayer();
    });
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
                  backgroundColor: Colors.white,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Manual Settings',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ...List.generate(_prayerTimes.length, (i) {
                          final pt = _prayerTimes[i];
                          final adjustedTime = pt.time.add(Duration(minutes: manualOffsets[i]));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  Text(
                                    timeFormat.format(adjustedTime),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline, color: Colors.grey[600]),
                                    onPressed: () async {
                                      setStateDialog(() {
                                        manualOffsets[i]--;
                                      });
                                      await prefs.setInt('prayer_offset_$i', manualOffsets[i]);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline, color: Colors.grey[600]),
                                    onPressed: () async {
                                      setStateDialog(() {
                                        manualOffsets[i]++;
                                      });
                                      await prefs.setInt('prayer_offset_$i', manualOffsets[i]);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // Save and update main list with manual offsets
                                setState(() {
                                  _manualOffsets = List<int>.from(manualOffsets);
                                });
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
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
            return _QiyamMidnightDialogContent();
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
          title: Text('Prayers', style: GoogleFonts.poppins(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
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
                            onTap: _showCityPicker,
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
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
;    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
;  }
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
  late final Stopwatch _stopwatch;
  late final Duration _interval;
  bool _running = false;
  Ticker(this.onTick, {Duration interval = const Duration(seconds: 1)}) {
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
      onTick(_stopwatch.elapsed);
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.forestGreen, size: 24),
            const SizedBox(width: 12),
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
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                notificationEnabled ? Icons.notifications_active : Icons.notifications_none,
                color: notificationEnabled ? AppColors.forestGreen : Colors.grey[600],
              ),
              onPressed: onBellTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _QiyamMidnightDialogContent extends StatefulWidget {
  @override
  State<_QiyamMidnightDialogContent> createState() => _QiyamMidnightDialogContentState();
}

class _QiyamMidnightDialogContentState extends State<_QiyamMidnightDialogContent> {
  bool qiyamNotif = false;
  bool midnightNotif = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Qiyam & Midnight',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Qiyam Card
            _QiyamMidnightCard(
              label: 'Qiyam',
              icon: Icons.nightlight_round,
              time: '1:09',
              notificationEnabled: qiyamNotif,
              onBellTap: () {
                setState(() {
                  qiyamNotif = !qiyamNotif;
                });
              },
            ),
            const SizedBox(height: 12),
            // Midnight Card
            _QiyamMidnightCard(
              label: 'Midnight',
              icon: Icons.nights_stay,
              time: '11:52',
              notificationEnabled: midnightNotif,
              onBellTap: () {
                setState(() {
                  midnightNotif = !midnightNotif;
                });
              },
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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
    setState(() { _loading = true; _error = null; });
    try {
      // Get location (reuse logic from PrayersScreen)
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double lng = position.longitude;
      // Get first day of this hijri month in Gregorian
      final hijri = HijriCalendar()
        ..hYear = _hijriYear
        ..hMonth = _hijriMonth
        ..hDay = 1;
      DateTime firstDay = hijri.hijriToGregorian(_hijriYear, _hijriMonth, 1);
      int daysInMonth = hijri.getDaysInMonth(_hijriYear, _hijriMonth);
      List<List<PrayerTime>> monthTimes = [];
      for (int i = 0; i < daysInMonth; i++) {
        DateTime day = firstDay.add(Duration(days: i));
        final params = CalculationMethod.karachi();
        params.madhab = Madhab.hanafi;
        final coordinates = Coordinates(lat, lng);
        final prayerTimes = PrayerTimes(
          coordinates: coordinates,
          date: day,
          calculationParameters: params,
        );
        monthTimes.add([
          if (prayerTimes.fajr != null)
            PrayerTime(name: 'Fajr', icon: Icons.nightlight_round, time: prayerTimes.fajr!),
          if (prayerTimes.sunrise != null)
            PrayerTime(name: 'Sunrise', icon: Icons.wb_sunny, time: prayerTimes.sunrise!),
          if (prayerTimes.dhuhr != null)
            PrayerTime(name: 'Dhuhr', icon: Icons.wb_sunny_outlined, time: prayerTimes.dhuhr!),
          if (prayerTimes.asr != null)
            PrayerTime(name: 'Asr', icon: Icons.wb_twilight, time: prayerTimes.asr!),
          if (prayerTimes.maghrib != null)
            PrayerTime(name: 'Maghrib', icon: Icons.nights_stay, time: prayerTimes.maghrib!),
          if (prayerTimes.isha != null)
            PrayerTime(name: 'Isha', icon: Icons.nightlight_round, time: prayerTimes.isha!),
        ]);
      }
      setState(() {
        _monthPrayerTimes = monthTimes;
        _loading = false;
      });
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('denied')) {
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
        if (mounted) Navigator.of(context).pop();
        return;
      }
      setState(() { _error = 'Failed to load calendar: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final forestGreen = AppColors.forestGreen;
    return Scaffold(
      appBar: AppBar(
        title: Text('$_hijriMonthName $_hijriYear', style: GoogleFonts.poppins(color: forestGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: forestGreen),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
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
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: forestGreen.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: ExpansionTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        'Day $hijriDay',
                                        style: GoogleFonts.poppins(
                                          color: forestGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(width: 12),
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
                                    return ListTile(
                                      leading: Icon(pt.icon, color: forestGreen),
                                      title: Text(pt.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                      trailing: Text(DateFormat('h:mm a').format(pt.time), style: GoogleFonts.poppins()),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
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