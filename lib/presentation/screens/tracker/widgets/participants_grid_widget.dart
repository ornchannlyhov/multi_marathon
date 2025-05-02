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

      recordedParticipants[selectedSegment]!.add(participantId);

      (context as Element).markNeedsBuild();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  final isRecorded = recordedParticipants[selectedSegment]!
                      .contains(participant.id);

                  return ElevatedButton(
                    onPressed:
                        isRecorded || race.raceStatus != RaceStatus.onGoing
                            ? null
                            : () => _recordParticipantTime(
                                  context,
                                  participant.id,
                                  race.startTime,
                                ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecorded
                          ? AppTheme.disable
                          : AppTheme.secondaryColor,
                      padding: const EdgeInsets.all(8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          participant.bibNumber.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRecorded ? 'Tracked' : 'Track',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
