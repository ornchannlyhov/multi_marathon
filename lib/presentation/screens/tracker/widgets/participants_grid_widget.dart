import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/data/models/race.dart';

class ParticipantsGridWidget extends StatelessWidget {
  final List<Participant> participants;
  final Race race;
  final Segment selectedSegment;
  final Map<Segment, Set<String>> recordedParticipants;
  final SegmentTrackingProvider trackingProvider;

  const ParticipantsGridWidget({
    super.key,
    required this.participants,
    required this.race,
    required this.selectedSegment,
    required this.recordedParticipants,
    required this.trackingProvider,
  });

  Color _getParticipantColor(Participant participant) {
    if (participant.isTracked) {
      return AppTheme.secondaryColor;
    } else {
      return Colors.grey[200]!;
    }
  }

  Future<void> _recordParticipantTime(
    SegmentTrackingProvider provider,
    String participantId,
    int raceStartTime,
  ) async {
    try {
      await provider.recordSegmentTime(
        participantId,
        selectedSegment,
        raceStartTime,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final isRecorded =
            recordedParticipants[selectedSegment]!.contains(participant.id);

        return ElevatedButton(
          onPressed: isRecorded || race.raceStatus != RaceStatus.onGoing
              ? null
              : () => _recordParticipantTime(
                    trackingProvider,
                    participant.id,
                    race.startTime,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isRecorded ? Colors.grey : _getParticipantColor(participant),
            padding: const EdgeInsets.all(8),
            elevation: 4,
          ),
          child: Text(
            participant.name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
