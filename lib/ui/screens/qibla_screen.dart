import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/location_service.dart';
import '../widgets/location_permission_dialog.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007A4D)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              'Qibla',
              style: GoogleFonts.poppins(
                color: AppColors.forestGreen,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          body: const QiblaCompassBody(),
        ),
      ],
    );
  }
}

class QiblaCompassBody extends StatefulWidget {
  const QiblaCompassBody({super.key});

  @override
  State<QiblaCompassBody> createState() => _QiblaCompassBodyState();
}

class _QiblaCompassBodyState extends State<QiblaCompassBody> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isCalibrating = false;
  bool _isLoading = true;
  String _currentLocation = '';
  Future<bool?>? _deviceSupportFuture;
  double? _manualQiblaBearing;
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _startPulseAnimation();
    _getLocation();
    _deviceSupportFuture = FlutterQiblah.androidDeviceSensorSupport();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() { _isLoading = true; });
    try {
      final locationData = await LocationService.getCurrentLocation();
      if (locationData != null && mounted) {
        setState(() {
          _currentLocation = locationData['city'] ?? '';
          _isLoading = false;
          _currentLat = locationData['lat'];
          _currentLng = locationData['lng'];
          _manualQiblaBearing = _calculateQiblaBearing(_currentLat!, _currentLng!);
        });
      } else if (mounted) {
        setState(() {
          _currentLocation = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = '';
          _isLoading = false;
        });
      }
    }
  }

  double _calculateQiblaBearing(double lat, double lng) {
    // Kaaba coordinates
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    double toRadians(double deg) => deg * math.pi / 180;
    double toDegrees(double rad) => rad * 180 / math.pi;
    double dLon = toRadians(kaabaLng - lng);
    double lat1 = toRadians(lat);
    double lat2 = toRadians(kaabaLat);
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
               math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    double bearing = math.atan2(y, x);
    double bearingDegrees = (toDegrees(bearing) + 360) % 360;
    return bearingDegrees;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }
    return FutureBuilder<bool?>(
      future: _deviceSupportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Sensor error: \n${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        if (snapshot.data == false) {
          return Center(child: Text('Device does not support required sensors for compass.', style: TextStyle(color: Colors.red)));
        }
        // Only show compass if sensors are supported
        return StreamBuilder<QiblahDirection>(
          stream: FlutterQiblah.qiblahStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Compass error: \n${snapshot.error}', style: TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return _buildLoadingWidget();
        }
        final qiblahDirection = snapshot.data!;
            print('Qiblah: ${qiblahDirection.qiblah}, Device: ${qiblahDirection.direction}, Offset: ${qiblahDirection.offset}');
            // Rotate the whole compass so the north arrow always points to Qibla
            final qiblaCompassAngle = ((_manualQiblaBearing ?? 0) - qiblahDirection.direction) * (math.pi / 180);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kGreenShadow.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                        // Rotate the whole compass so the north arrow points to Qibla
                    Center(
                      child: Transform.rotate(
                            angle: qiblaCompassAngle,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.95),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              _buildCompassNeedle(),
                              _buildDegreeMarkers(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildKaabaIcon(),
                  ],
                ),
              ),
              if (_currentLocation.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _currentLocation,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.forestGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 200),
            ],
          ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompassWidget() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.kGreenShadow.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                _buildOuterRing(),
                _buildInnerCompass(),
                _buildKaabaIcon(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaIndicator() {
    return Center(
      child: Icon(
        Icons.arrow_upward,
        color: Colors.red,
        size: 80,
      ),
    );
  }

  Widget _buildQiblaDirectionInfo() {
    // This widget is no longer used, as direction is handled by the stream.
    return SizedBox.shrink();
  }

  Widget _buildOuterRing() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE0F2F1),
            const Color(0xFFB2DFDB),
            AppColors.forestGreen.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
            _buildDirectionLabel('شمال', 0, Icons.keyboard_arrow_up),
          _buildDirectionLabel('جنوب', 180, Icons.keyboard_arrow_down),
          _buildDirectionLabel('شرق', 90, Icons.keyboard_arrow_right),
          _buildDirectionLabel('غرب', 270, Icons.keyboard_arrow_left),
        ],
      ),
    );
  }

  Widget _buildDirectionLabel(String text, double angle, IconData icon) {
    final radians = angle * 3.14159 / 180;
    final radius = 120.0;
    final x = radius * math.sin(radians);
    final y = -radius * math.cos(radians);
    return Positioned(
      left: 140 + x - 20,
      top: 140 + y - 20,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.forestGreen),
            Text(
              text,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.forestGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInnerCompass() {
    // This widget is no longer used, as rotation is handled by the stream.
    return SizedBox.shrink();
  }

  Widget _buildCompassNeedle() {
    return Center(
      child: SizedBox(
        width: 4,
        height: 160,
        child: CustomPaint(
          painter: CompassNeedlePainter(),
        ),
      ),
    );
  }

  Widget _buildDegreeMarkers() {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: DegreeMarkersPainter(),
      ),
    );
  }

  Widget _buildKaabaIcon() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestGreen.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque,
                color: Colors.white,
                size: 30,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationPermissionRequest() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.kGreenShadow.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: AppColors.forestGreen.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Location Permission Required',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.forestGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please enable location access to use the Qibla compass',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _getLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Enable Location',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.kGreenShadow.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.forestGreen,
            strokeWidth: 4,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.forestGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/IMG_1323.PNG'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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

class CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forestGreen
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, -80);
    path.lineTo(-8, 0);
    path.lineTo(0, 80);
    path.lineTo(8, 0);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DegreeMarkersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.forestGreen.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    for (int i = 0; i < 360; i += 30) {
      final angle = i * 3.14159 / 180;
      final startPoint = Offset(
        center.dx + (radius - 15) * math.cos(angle),
        center.dy + (radius - 15) * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 