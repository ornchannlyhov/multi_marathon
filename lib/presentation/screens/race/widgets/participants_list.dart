import 'package:flutter/material.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/participant_item.dart';

class ParticipantsList extends StatelessWidget {
  final List<Participant> participants;
  final Race? race;
  final void Function(Participant participant) onEdit;
  final void Function(String participantId) onDelete;
  final void Function()? onAdd; 

  const ParticipantsList({
    super.key,
    required this.participants,
    required this.race,
    required this.onEdit,
    required this.onDelete,
    this.onAdd, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [   
                const Text(
                  'Participants',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (onAdd != null)
                  IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ),
          Container(
            // ignore: deprecated_member_use
            color: AppTheme.primaryColor.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              children: [
                SizedBox(
                    width: 40,
                    child: Text('BIB',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Name',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 70),
              ],
            ),
          ),
          
          Expanded(
            child: participants.isEmpty
                ? const Center(child: Text('No participants added'))
                : ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      return ParticipantItem(
                        participant: participant,
                        race: race,
                        onEdit: () => onEdit(participant),
                        onDelete: () => onDelete(participant.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
