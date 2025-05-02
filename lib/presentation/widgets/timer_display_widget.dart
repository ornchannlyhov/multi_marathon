import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';

class TimerDisplayWidget extends StatelessWidget {
  final int elapsedSeconds;

  const TimerDisplayWidget({super.key, required this.elapsedSeconds});

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _formatTime(elapsedSeconds),
        style: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
