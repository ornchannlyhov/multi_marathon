import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/data/models/race.dart';

class RaceControls extends StatelessWidget {
  final Race? race;
  final VoidCallback? onStart;
  final VoidCallback? onFinish;
  final VoidCallback? onReset;

  const RaceControls({
    super.key,
    required this.race,
    this.onStart,
    this.onFinish,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: race?.raceStatus == RaceStatus.onGoing ||
                  race?.raceStatus == RaceStatus.finished
              ? onReset
              : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text('Reset Race', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: race?.raceStatus == RaceStatus.notStarted
              ? onStart
              : race?.raceStatus == RaceStatus.onGoing
                  ? onFinish
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            race?.raceStatus == RaceStatus.onGoing ? 'Finish Race' : 'Start Race',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
