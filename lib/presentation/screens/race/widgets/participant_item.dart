import 'package:flutter/material.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/data/models/segment_time.dart';

class ParticipantItem extends StatelessWidget {
  final Participant participant;
  final Race? race;
  final String selectedSegment;
  final Map<Segment, Set<String>> recordedParticipants;
  final VoidCallback onRecord;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  // New callback for adding a participant

  const ParticipantItem({
    super.key,
    required this.participant,
    required this.race,
    required this.selectedSegment,
    required this.recordedParticipants,
    required this.onRecord,
    required this.onEdit,
    required this.onDelete,
    // Include in constructor
  });

  @override
  Widget build(BuildContext context) {
    final bool isRaceOngoing = race?.raceStatus == RaceStatus.onGoing;
    final bool canEdit = race?.raceStatus == RaceStatus.notStarted;
    final bool hasCompletedSegment = recordedParticipants[selectedSegment]?.contains(participant.id) ?? false;

    final age = 18 + (participant.bibNumber % 5);

    return InkWell(
      onTap: isRaceOngoing ? onRecord : null,
      child: Container(
        decoration: BoxDecoration(
          color: hasCompletedSegment ? Colors.green.withOpacity(0.1) : null,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text(participant.bibNumber.toString())),
              Expanded(child: Text(participant.name)),
              SizedBox(width: 40, child: Text(age.toString())),
              SizedBox(
                width: 35,
                
              ),
              SizedBox(
                width: 35,
                child: IconButton(
                  icon: Icon(Icons.edit, size: 20, color: canEdit ? Colors.blue : Colors.grey),
                  onPressed: canEdit ? onEdit : null,
                ),
              ),
              SizedBox(
                width: 35,
                child: IconButton(
                  icon: Icon(Icons.delete, size: 20, color: canEdit ? Colors.red : Colors.grey),
                  onPressed: canEdit ? onDelete : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}