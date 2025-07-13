import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'dart:ui';

class AppleMusicPlayer extends StatelessWidget {
  final String surahName;
  final String englishName;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;

  const AppleMusicPlayer({
    Key? key,
    required this.surahName,
    required this.englishName,
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(46),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color.fromARGB(255, 225, 223, 223), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB6EFC6).withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'lib/images/19B88BD8-0E7F-4783-B0F6-EDF720F48C4E.jpeg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      englishName,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black.withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 28, color: Colors.black),
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 28, color: Colors.black),
                onPressed: () {}, // No next track for now
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24, color: Colors.black54),
                onPressed: onStop,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
} 