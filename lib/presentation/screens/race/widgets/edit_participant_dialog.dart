import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';

Future<void> showEditParticipantDialog({
  required BuildContext context,
  Participant? participant,
}) {
  final isEditing = participant != null;
  final nameController = TextEditingController(text: participant?.name ?? '');
  final bibController =
      TextEditingController(text: participant?.bibNumber.toString() ?? '');

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? 'Edit Participant' : 'Add Participant'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: bibController,
                decoration: const InputDecoration(labelText: 'BIB Number'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  bibController.text.isNotEmpty) {
                final provider =
                    Provider.of<ParticipantProvider>(context, listen: false);
                if (isEditing) {
                  provider.updateParticipant(
                    participant.id, 
                    nameController.text,
                    int.parse(bibController.text)
                  );
                } else {
                  provider.addParticipant(
                    nameController.text,
                    int.parse(bibController.text),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
