import 'package:flutter/material.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/segment_time.dart';

class SegmentSwitcher extends StatelessWidget {
  final Segment selectedSegment;
  final ValueChanged<Segment> onSegmentChanged;

  const SegmentSwitcher({
    super.key,
    required this.selectedSegment,
    required this.onSegmentChanged,
  });

  static const double _circleDiameter = 50.0;
  static const double _iconSize = 28.0;
  static const double _barHeight = 16.0;
  static const double _spacing = 200.0;
  static const Color _inactiveColor = Color(0xFFDCDCDC);
  static const Color _iconColorInactive = Colors.black;
  static const Color _iconColorActive = Colors.white;

  @override
  Widget build(BuildContext context) {
    final double totalWidth =
        _circleDiameter + (_spacing * (Segment.values.length - 1));

    return SizedBox(
      height: _circleDiameter,
      width: totalWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: (_circleDiameter - _barHeight) / 2,
            left: _circleDiameter / 2,
            right: _circleDiameter / 2,
            child: Container(
              height: _barHeight,
              color: _inactiveColor,
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: Segment.values.map((segment) {
                return _buildSegmentCircle(segment);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentCircle(Segment segment) {
    final bool isSelected = segment == selectedSegment;
    final Color circleColor =
        isSelected ? AppTheme.primaryColor : _inactiveColor;
    final Color iconColor = isSelected ? _iconColorActive : _iconColorInactive;

    return SizedBox(
      width: _circleDiameter,
      height: _circleDiameter,
      child: Material(
        color: circleColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onSegmentChanged(segment),
          child: Center(
            child: Icon(
              _getIconForSegment(segment),
              size: _iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForSegment(Segment segment) {
    switch (segment) {
      case Segment.running:
        return Icons.directions_run;
      case Segment.swimming:
        return Icons.pool;
      case Segment.cycling:
        return Icons.directions_bike;
    }
  }
}

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  Segment _currentSegment = Segment.running;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segment Switcher Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentSwitcher(
              selectedSegment: _currentSegment,
              onSegmentChanged: (newSegment) {
                setState(() {
                  _currentSegment = newSegment;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Selected: ${_currentSegment.name}'),
          ],
        ),
      ),
    );
  }
}
