import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';

class SegmentInfoWidget extends StatelessWidget {
  final Segment selectedSegment;
  final Map<Segment, Set<String>>? recordedParticipants;
  final List<Participant> participants;

  const SegmentInfoWidget({
    super.key,
    required this.selectedSegment,
    required this.recordedParticipants,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedSegment.name}: ${selectedSegment.progressText}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.primaryColor,
            ),
          ),
          if (recordedParticipants != null)
            Text(
              '${recordedParticipants?[selectedSegment]?.length ?? 0}/${participants.length}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
