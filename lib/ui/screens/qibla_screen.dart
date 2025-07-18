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

  double _qiblaDirection = 0.0;
  double _deviceDirection = 0.0;
  bool _isCalibrating = false;
  bool _hasLocationPermission = false;
  bool _isLoading = true;
  String _currentLocation = '';
  Position? _currentPosition;

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
    _checkLocationPermission();
    _startCompassListener();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      // Try to get current location using the location service
      final locationData = await LocationService.getCurrentLocation();
      
      if (locationData != null) {
        // Calculate qibla direction
        double qiblaDirection = await _calculateQiblaDirection(
          locationData['lat'],
          locationData['lng'],
        );

        if (mounted) {
          setState(() {
            _hasLocationPermission = true;
            _isLoading = false;
            _currentLocation = locationData['city'];
            _qiblaDirection = qiblaDirection;
          });
        }
      } else {
        // If no location available, show permission dialog
        if (mounted) {
          setState(() {
            _hasLocationPermission = false;
            _isLoading = false;
          });
          _showLocationPermissionDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasLocationPermission = false;
          _isLoading = false;
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
        message: 'To show the correct qibla direction, we need access to your current location.',
        onAllow: () async {
          Navigator.of(context).pop();
          final locationData = await LocationService.getCurrentLocation(forceRequest: true);
          if (locationData != null && mounted) {
            double qiblaDirection = await _calculateQiblaDirection(
              locationData['lat'],
              locationData['lng'],
            );
            setState(() {
              _hasLocationPermission = true;
              _isLoading = false;
              _currentLocation = locationData['city'];
              _qiblaDirection = qiblaDirection;
            });
          } else if (mounted) {
            setState(() {
              _hasLocationPermission = false;
              _isLoading = false;
            });
          }
        },
        onDeny: () {
          Navigator.of(context).pop();
          setState(() {
            _hasLocationPermission = false;
            _isLoading = false;
          });
        },
      ),
    );
  }

  void _startCompassListener() {
    // For now, we'll use a simpler approach without the compass sensor
    // The qibla direction will be calculated based on location only
  }

  Future<double> _calculateQiblaDirection(double latitude, double longitude) async {
    try {
      // Manual calculation using the great circle formula
      const double kaabaLat = 21.4225;
      const double kaabaLng = 39.8262;
      
      // Convert to radians
      double lat1 = latitude * math.pi / 180;
      double lng1 = longitude * math.pi / 180;
      double lat2 = kaabaLat * math.pi / 180;
      double lng2 = kaabaLng * math.pi / 180;
      
      // Calculate qibla direction using the great circle formula
      double y = math.sin(lng2 - lng1) * math.cos(lat2);
      double x = math.cos(lat1) * math.sin(lat2) - 
                 math.sin(lat1) * math.cos(lat2) * math.cos(lng2 - lng1);
      
      double qiblaDirection = math.atan2(y, x) * 180 / math.pi;
      
      // Convert to 0-360 range
      qiblaDirection = (qiblaDirection + 360) % 360;
      
      print('Qibla direction calculated: $qiblaDirection degrees for lat: $latitude, lng: $longitude');
      
      return qiblaDirection;
    } catch (e) {
      print('Error calculating qibla direction: $e');
      return 0.0;
    }
  }

  void _calibrateCompass() async {
    setState(() {
      _isCalibrating = true;
    });
    
    try {
      await _checkLocationPermission();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isCalibrating = false;
        });
      }
    }
  }

  Future<void> _showLocationServicesDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Location Services Disabled',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.forestGreen,
            ),
          ),
          content: Text(
            'Please enable location services in your device settings to use the Qibla compass.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: AppColors.forestGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (_isLoading)
              _buildLoadingWidget()
            else if (_hasLocationPermission)
              _buildCompassWidget()
            else
              _buildLocationPermissionRequest(),
            const SizedBox(height: 200),
            Center(
              child: SizedBox(
                width: 220,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isCalibrating ? null : _calibrateCompass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: _isCalibrating
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Setting Location...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Set Location',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (_hasLocationPermission && _currentLocation.isNotEmpty)
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
          ],
        ),
      ),
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
      child: Container(
        width: 4,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.forestGreen,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildQiblaDirectionInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Qibla Direction',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_qiblaDirection.toStringAsFixed(1)}°',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Point your device towards the green arrow',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
    return Center(
      child: Transform.rotate(
        angle: -_qiblaDirection * math.pi / 180, // Negative because we want to rotate the compass, not the needle
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
              _buildQiblaIndicator(),
            ],
          ),
        ),
      ),
    );
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
              await _checkLocationPermission();
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