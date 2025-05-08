import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/data/models/race.dart';

class ParticipantsGridWidget extends StatefulWidget {
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

  @override
  State<ParticipantsGridWidget> createState() => _ParticipantsGridWidgetState();
}

class _ParticipantsGridWidgetState extends State<ParticipantsGridWidget> {
 Future<void> _handleParticipantAction(
  String participantId,
  int raceStartTime,
  bool isCurrentlyRecorded,
) async {
  bool proceed = true;

  if (isCurrentlyRecorded) {
    proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Untrack'),
            content: const Text(
              'Are you sure you want to untrack this participant?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Untrack'),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed
  }

  if (!proceed) return;

  try {
    if (isCurrentlyRecorded) {
      await widget.trackingProvider.deleteSegmentTimeForParticipant(
        participantId,
        widget.selectedSegment,
      );
      widget.recordedParticipants[widget.selectedSegment]!
          .remove(participantId);
    } else {
      await widget.trackingProvider.recordSegmentTime(
        participantId,
        widget.selectedSegment,
        raceStartTime,
      );
      widget.recordedParticipants[widget.selectedSegment]!
          .add(participantId);
    }

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyRecorded
                ? 'Participant untracked successfully.'
                : 'Participant tracked successfully.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${isCurrentlyRecorded ? 'untrack' : 'track'}: $e',
            style: const TextStyle(color: Colors.green),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          borderRadius: BorderRadius.circular(6),
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
                itemCount: widget.participants.length,
                itemBuilder: (context, index) {
                  final participant = widget.participants[index];
                  final isRecorded = widget
                      .recordedParticipants[widget.selectedSegment]!
                      .contains(participant.id);

                  return ElevatedButton(
                    onPressed: widget.race.raceStatus != RaceStatus.onGoing
                        ? null
                        : () => _handleParticipantAction(
                              participant.id,
                              widget.race.startTime,
                              isRecorded,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecorded
                          ? AppTheme.dangerColor
                          : AppTheme.primaryColor,
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
                          isRecorded ? 'Untrack' : 'Track',
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
