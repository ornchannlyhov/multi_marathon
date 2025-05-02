import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/race.dart';
class RaceHeader extends StatelessWidget {
  final Race? race;

  const RaceHeader({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return   
     Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Half-marathon',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        // RaceStatusWidget(
        //   race: race ??
        //       Race(raceStatus: RaceStatus.notStarted, startTime: 0, endTime: 0),
        // ),
      ],
    );
  }
}
