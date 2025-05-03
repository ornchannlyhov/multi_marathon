import 'package:flutter/material.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/participant_item.dart';

class ParticipantsList extends StatelessWidget {
  final List<Participant> participants;
  final Race? race;
  final String selectedSegment;
  final Map<Segment, Set<String>> recordedParticipants;
  final void Function(Participant participant) onEdit;
  final void Function(String participantId) onDelete;
  final void Function()? onAdd; // Nullable function to add a participant

  const ParticipantsList({
    super.key,
    required this.participants,
    required this.race,
    required this.selectedSegment,
    required this.recordedParticipants,
    required this.onEdit,
    required this.onDelete,
    this.onAdd, // Make the add function nullable
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (onAdd != null) // Show the Add button only if onAdd is provided
                  IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade300,
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
                SizedBox(width: 70), // Edit/Delete button space
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
                        selectedSegment: selectedSegment,
                        recordedParticipants: recordedParticipants,
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
