import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/core/utils/async_value.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/data/models/race.dart';

class LeaderboardGridWidget extends StatelessWidget {
  final List<Participant> participants;
  final Race race;
  final Segment selectedSegment;
  final Map<Segment, Set<String>> recordedParticipants;
  final SegmentTrackingProvider trackingProvider;

  const LeaderboardGridWidget({
    super.key,
    required this.participants,
    required this.race,
    required this.selectedSegment,
    required this.recordedParticipants,
    required this.trackingProvider,
  });

  Future<void> _recordParticipantTime(
    BuildContext context,
    String participantId,
    int raceStartTime,
  ) async {
    try {
      await trackingProvider.recordSegmentTime(
        participantId,
        selectedSegment,
        raceStartTime,
      );

      recordedParticipants[selectedSegment]?.add(participantId);
      (context as Element).markNeedsBuild(); // Force UI update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final segmentMap = trackingProvider.segmentsByParticipantState;

    return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.primaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranking',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              final segmentTimes = segmentMap.data?[participant.id] ?? [];

              final recordedSegment = segmentTimes.firstWhere(
                (t) => t.segment == selectedSegment.name,
                orElse: () => SegmentTime(
                  id: '',
                  segment: selectedSegment,
                  participantId: participant.id,
                  elapsedTimeInSeconds: 0,
                ),
              );

              final isTracked = segmentTimes.any(
                (t) => t.segment == selectedSegment.name,
              );

              final elapsedFormatted = isTracked
                  ? _formatElapsed(recordedSegment.elapsedTimeInSeconds)
                  : '--:--';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    'Bib #${participant.bibNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    'Time: $elapsedFormatted',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: isTracked ||
                            race.raceStatus != RaceStatus.onGoing
                        ? null
                        : () => _recordParticipantTime(
                              context,
                              participant.id,
                              race.startTime,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTracked
                          ? AppTheme.disable
                          : AppTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isTracked ? 'Tracked' : 'Track',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);
}

  String _formatElapsed(int elapsedMilliseconds) {
    final seconds = (elapsedMilliseconds / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
