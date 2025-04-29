import 'package:firebase_database/firebase_database.dart';
import 'package:multi_marathon/data/dtos/participant_dto.dart';
import 'package:multi_marathon/data/models/participant.dart';

class ParticipantRepository {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('participant');

  Stream<List<Participant>> getParticipantsStream() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        final participantDTO = ParticipantDTO.fromMap(Map<String, dynamic>.from(e.value));
        return Participant(id: e.key, name: participantDTO.name, bibNumber: participantDTO.bibNumber);
      }).toList();
    });
  }

  Future<void> addParticipant(ParticipantDTO participantDTO) async {
    final newRef = _ref.push();
    await newRef.set(participantDTO.toMap());
  }

  Future<void> deleteParticipant(String id) async {
    await _ref.child(id).remove();
  }

  Future<void> updateParticipant(String id, ParticipantDTO participantDTO) async {
    await _ref.child(id).update(participantDTO.toMap());
  }
}
