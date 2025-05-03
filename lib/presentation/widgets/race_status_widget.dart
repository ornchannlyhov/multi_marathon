import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/race.dart';

class RaceStatusWidget extends StatelessWidget {
  final Race race;

  const RaceStatusWidget({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: Text(
          race.raceStatus == RaceStatus.onGoing
              ? 'ONGOING'
              : race.raceStatus.name.toUpperCase(),
          style: GoogleFonts.poppins(
            color: race.raceStatus == RaceStatus.onGoing
                ? AppTheme.success
                : const Color.fromARGB(255, 153, 149, 149),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
