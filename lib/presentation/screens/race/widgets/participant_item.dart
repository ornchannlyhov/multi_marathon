import 'package:flutter/material.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/race.dart';

class ParticipantItem extends StatelessWidget {
  final Participant participant;
  final Race? race;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ParticipantItem({
    super.key,
    required this.participant,
    required this.race,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canEdit = race?.raceStatus == RaceStatus.notStarted;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            SizedBox(width: 40, child: Text(participant.bibNumber.toString())),
            Expanded(child: Text(participant.name)),
            const SizedBox(
              width: 35,
            ),
            SizedBox(
              width: 35,
              child: IconButton(
                icon: Icon(Icons.edit, size: 20, color: canEdit ? AppTheme.warningColor : Colors.grey),
                onPressed: canEdit ? onEdit : null,
              ),
            ),
            SizedBox(
              width: 35,
              child: IconButton(
                icon: Icon(Icons.delete, size: 20, color: canEdit ? AppTheme.dangerColor : Colors.grey),
                onPressed: canEdit ? onDelete : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
