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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: Segment.values.map((segment) {
              final isSelected = segment == selectedSegment;
              return Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Material(
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => onSegmentChanged(segment),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForSegment(segment),
                              size: 20,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              segment.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _getIconForSegment(Segment segment) {
    switch (segment) {
      case Segment.running:
        return Icons.directions_run;
      case Segment.cycling:
        return Icons.directions_bike;
      case Segment.swimming:
        return Icons.pool;
    }
  }
}
