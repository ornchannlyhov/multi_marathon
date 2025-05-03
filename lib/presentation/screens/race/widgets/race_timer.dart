import 'package:flutter/material.dart';
import 'package:multi_marathon/presentation/widgets/timer_display_widget.dart';

class RaceTimer extends StatelessWidget {
  final int elapsedSeconds;

  const RaceTimer({super.key, required this.elapsedSeconds});

  @override
  Widget build(BuildContext context) {
    return TimerDisplayWidget(elapsedSeconds: elapsedSeconds);
  }
}
