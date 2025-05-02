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
  final void Function(Participant participant) onRecord;
  final void Function(Participant participant) onEdit;
  final void Function(String participantId) onDelete;
  final void Function() onAdd; // New function to add a participant

  const ParticipantsList({
    super.key,
    required this.participants,
    required this.race,
    required this.selectedSegment,
    required this.recordedParticipants,
    required this.onRecord,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd, // Add the new function
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participants',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Add button
                // ElevatedButton.icon(
                //   onPressed: onAdd,
                //   icon: const Icon(Icons.add, size: 18),
                //   label: const Text('Add'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Theme.of(context).primaryColor,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //   ),
                // ),
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
                SizedBox(
                    width: 40,
                    child: Text('Age',
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
                        onRecord: () => onRecord(participant),
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