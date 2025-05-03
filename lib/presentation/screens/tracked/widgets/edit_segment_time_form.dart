import 'package:flutter/material.dart';
import 'package:multi_marathon/data/dtos/segment_time_dto.dart';
import 'package:multi_marathon/data/models/segment_time.dart';

class EditSegmentTimeForm extends StatefulWidget {
  final SegmentTime initialTime;

  const EditSegmentTimeForm({super.key, required this.initialTime});

  @override
  State<EditSegmentTimeForm> createState() => _EditSegmentTimeFormState();
}

class _EditSegmentTimeFormState extends State<EditSegmentTimeForm> {
  late TextEditingController hoursController;
  late TextEditingController minutesController;
  late TextEditingController secondsController;

  @override
  void initState() {
    final time = widget.initialTime.elapsedTimeInSeconds;
    hoursController =
        TextEditingController(text: (time ~/ 3600).toString().padLeft(2, '0'));
    minutesController = TextEditingController(
        text: ((time % 3600) ~/ 60).toString().padLeft(2, '0'));
    secondsController =
        TextEditingController(text: (time % 60).toString().padLeft(2, '0'));
    super.initState();
  }

  @override
  void dispose() {
    hoursController.dispose();
    minutesController.dispose();
    secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _timeField(controller: hoursController, label: 'Hours'),
              const SizedBox(width: 8),
              const Text(':'),
              const SizedBox(width: 8),
              _timeField(controller: minutesController, label: 'Minutes'),
              const SizedBox(width: 8),
              const Text(':'),
              const SizedBox(width: 8),
              _timeField(controller: secondsController, label: 'Seconds'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final hours = int.tryParse(hoursController.text) ?? 0;
            final minutes = int.tryParse(minutesController.text) ?? 0;
            final seconds = int.tryParse(secondsController.text) ?? 0;

            final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

            final updated = SegmentTimeDTO(
              participantId: widget.initialTime.participantId,
              segment: widget.initialTime.segment.name,
              elapsedTimeInSeconds: totalSeconds,
            );

            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _timeField({
    required TextEditingController controller,
    required String label,
  }) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: '00'),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
