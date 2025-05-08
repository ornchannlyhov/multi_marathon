import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';

class ParticipantForm extends StatefulWidget {
  final Participant? participant;
  final VoidCallback onFormClosed;

  const ParticipantForm({
    super.key,
    this.participant,
    required this.onFormClosed,
  });

  @override
  State<ParticipantForm> createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  late final TextEditingController nameController;
  late final TextEditingController bibController;
  final formKey = GlobalKey<FormState>();
  bool get isEditing => widget.participant != null;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.participant?.name ?? '');
    bibController = TextEditingController(
        text: widget.participant?.bibNumber.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    bibController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (formKey.currentState!.validate()) {
      final provider = Provider.of<ParticipantProvider>(context, listen: false);
      final bibNumber = int.parse(bibController.text.trim());

      if (isEditing) {
        provider.updateParticipant(
          widget.participant!.id,
          nameController.text.trim(),
          bibNumber,
        );
        _showSuccessAlert('Participant updated successfully!');
      } else {
        provider.addParticipant(
          nameController.text.trim(),
          bibNumber,
        );
        _showSuccessAlert('Participant added successfully!');
      }

      widget.onFormClosed();
    }
  }

  void _showSuccessAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isEditing ? Icons.edit : Icons.person_add,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isEditing ? 'Edit Participant' : 'Add Participant',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onFormClosed,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: 'Enter participant name',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Name cannot contain numbers';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // BIB
                TextFormField(
                  controller: bibController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'BIB Number',
                    labelStyle: const TextStyle(color: Colors.black),
                    hintText: 'Enter BIB number',
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.tag, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a BIB number';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: widget.onFormClosed,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color.fromARGB(255, 248, 248, 248),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isEditing ? Icons.save : Icons.add),
                    const SizedBox(width: 8),
                    Text(isEditing ? 'Save' : 'Add'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
