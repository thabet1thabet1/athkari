import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'dart:math';

class AyahNumberCircle extends StatelessWidget {
  final int number;
  const AyahNumberCircle({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main circle with gold border and green shadow
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFD4AF37), // Gold
                width: 2.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kGreenShadow.withOpacity(0.45),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Subtle geometric star (optional, for Islamic vibe)
          Positioned.fill(
            child: CustomPaint(
              painter: _StarPainter(),
            ),
          ),
          // Ayah number
          Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
                color: Color(0xFF18824B),
                fontSize: 15,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple 8-pointed star for subtle Islamic geometric accent
class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.18) // Gold, subtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final double r = size.width / 2.2;
    final Offset c = Offset(size.width / 2, size.height / 2);
    final Path path = Path();
    for (int i = 0; i < 8; i++) {
      final double angle = (i * 45) * 3.1415926535 / 180;
      final double x = c.dx + r * cos(angle);
      final double y = c.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 