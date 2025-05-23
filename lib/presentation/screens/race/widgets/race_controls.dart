import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:provider/provider.dart';

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
    final isStart = race?.raceStatus == RaceStatus.notStarted;
    final isFinish = race?.raceStatus == RaceStatus.onGoing;
    final buttonColor = isStart
        ? AppTheme.primaryColor
        : isFinish
            ? AppTheme.dangerColor
            : AppTheme.disable;

    return Center(
      child: isStart
          ? ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: AppTheme.backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Start Race',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Provider.of<RaceTimerProvider>(context, listen: false)
                        .reset();
                    onReset?.call();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text('Reset Race', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  onPressed: isFinish ? onFinish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: AppTheme.backgroundColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Finish Race',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }
}