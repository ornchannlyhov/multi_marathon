import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/race.dart';

class RaceStatusWidget extends StatelessWidget {
  final Race race;

  const RaceStatusWidget({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color dotColor;
    Color textColor;
    String statusText;
    bool isBlinking = false;

    switch (race.raceStatus) {
      case RaceStatus.onGoing:
        // ignore: deprecated_member_use
        backgroundColor = AppTheme.success.withOpacity(0.2);
        dotColor = AppTheme.success;
        textColor = AppTheme.success;
        statusText = 'on going';
        isBlinking = true;
        break;
      case RaceStatus.notStarted:
        // ignore: deprecated_member_use
        backgroundColor = Colors.grey.withOpacity(0.2);
        dotColor = Colors.grey;
        textColor = Colors.grey;
        statusText = 'not started';
        break;
      case RaceStatus.finished:
        // ignore: deprecated_member_use
        backgroundColor = AppTheme.dangerColor.withOpacity(0.2);
        dotColor = AppTheme.dangerColor;
        textColor = AppTheme.dangerColor;
        statusText = 'finished';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BlinkingDot(
              color: dotColor,
              isBlinking: isBlinking,
            ),
            const SizedBox(width: 6.0),
            Text(
              statusText,
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  final Color color;
  final bool isBlinking;

  const _BlinkingDot({
    required this.color,
    required this.isBlinking,
  });

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isBlinking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _BlinkingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isBlinking && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.isBlinking ? _opacity : kAlwaysCompleteAnimation,
      child: Container(
        width: 8.0,
        height: 8.0,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}