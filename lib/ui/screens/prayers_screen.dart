import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme.dart';
import 'dart:ui';

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
          if (prayerTimes.sunrise != null)
            PrayerTime(name: 'Sunrise', icon: Icons.wb_sunny, time: prayerTimes.sunrise!),
          if (prayerTimes.dhuhr != null)
            PrayerTime(name: 'Dhuhr', icon: Icons.wb_sunny_outlined, time: prayerTimes.dhuhr!),
          if (prayerTimes.asr != null)
            PrayerTime(name: 'Asr', icon: Icons.wb_twilight, time: prayerTimes.asr!),
          if (prayerTimes.maghrib != null)
            PrayerTime(name: 'Maghrib', icon: Icons.nights_stay, time: prayerTimes.maghrib!),
          if (prayerTimes.isha != null)
            PrayerTime(name: 'Isha', icon: Icons.nightlight, time: prayerTimes.isha!),
        ];
        _updateNextPrayer();
      });
    } catch (e) {
      setState(() {
        _city = 'Location error';
      });
    }
  }

  void _updateNextPrayer() {
    final now = DateTime.now();
    for (final pt in _prayerTimes) {
      if (pt.time.isAfter(now)) {
        _nextPrayerName = pt.name;
        _nextPrayerTime = pt.time;
        _timeLeft = pt.time.difference(now);
        setState(() {});
        return;
      }
    }
    // If all passed, next is tomorrow's Fajr
    final tomorrowFajr = _prayerTimes.first.time.add(const Duration(days: 1));
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
        if (prayerTimes.sunrise != null)
          PrayerTime(name: 'Sunrise', icon: Icons.wb_sunny, time: prayerTimes.sunrise!),
        if (prayerTimes.dhuhr != null)
          PrayerTime(name: 'Dhuhr', icon: Icons.wb_sunny_outlined, time: prayerTimes.dhuhr!),
        if (prayerTimes.asr != null)
          PrayerTime(name: 'Asr', icon: Icons.wb_twilight, time: prayerTimes.asr!),
        if (prayerTimes.maghrib != null)
          PrayerTime(name: 'Maghrib', icon: Icons.nights_stay, time: prayerTimes.maghrib!),
        if (prayerTimes.isha != null)
          PrayerTime(name: 'Isha', icon: Icons.nightlight, time: prayerTimes.isha!),
      ];
      _updateNextPrayer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final forestGreen = AppColors.forestGreen;
    final white = AppColors.white;
    final timeFormat = DateFormat('h:mm a');
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text('Prayers', style: GoogleFonts.poppins(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),
          // 1. Next Prayer Box (GLASSMORPHIC STYLE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: 200.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(color: AppColors.forestGreen, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withValues(alpha: 0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: null,
                    ),
                  ),
                  Container(
                    height: 200.0,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.transparent),
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
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.access_time, color: Colors.black.withValues(alpha: 0.7), size: 20),
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    height: 1.5,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black12,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            _city,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
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
                        color: Colors.black.withValues(alpha: 0.03),
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
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: _prayerTimes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final pt = _prayerTimes[idx];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: forestGreen.withValues(alpha: 0.13)),
                  boxShadow: [
                    BoxShadow(
                      color: forestGreen.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(pt.icon, color: forestGreen, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        pt.name,
                        style: GoogleFonts.poppins(
                          color: forestGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Text(
                      timeFormat.format(pt.time),
                      style: GoogleFonts.poppins(
                        color: forestGreen,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _toggleNotification(idx),
                      child: Icon(
                        pt.notificationEnabled ? Icons.notifications_active : Icons.notifications_none,
                        color: pt.notificationEnabled ? forestGreen : forestGreen.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // 4. Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _ActionPillButton(
                  label: 'Prayer Settings',
                  icon: Icons.settings,
                  onTap: () {},
                ),
                _ActionPillButton(
                  label: 'Sleep Mode',
                  icon: Icons.nightlight,
                  onTap: () {},
                ),
                _ActionPillButton(
                  label: 'Monthly Calendar',
                  icon: Icons.calendar_month,
                  onTap: () {},
                ),
                _ActionPillButton(
                  label: 'Qiyam & Midnight',
                  icon: Icons.notifications_off,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
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