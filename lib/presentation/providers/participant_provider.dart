import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_marathon/core/utils/async_value.dart';
import 'package:multi_marathon/data/dtos/participant_dto.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/repositories/participant_repository.dart';

class ParticipantProvider extends ChangeNotifier {
  final ParticipantRepository _participantRepository = ParticipantRepository();

  Stream<List<Participant>> get participantsStream =>
      _participantRepository.getParticipantsStream();

  AsyncValue<List<Participant>> _participantsState = const AsyncValue.loading();
  AsyncValue<List<Participant>> get participantsState => _participantsState;

  ParticipantProvider() {
    _listenToParticipants();
  }

  void _listenToParticipants() {
    participantsStream.listen(
      (data) {
        _participantsState = AsyncValue.success(data);
        notifyListeners();
      },
      onError: (error) {
        _participantsState = AsyncValue.error(error);
        notifyListeners();
        throw Exception("Error fetching participants: $error");
      },
    );
  }

  // --- CRUD Operations ---
  Future<void> addParticipant(String name, int bibNumber) async {
    try {
      final participantDTO = ParticipantDTO(name: name, bibNumber: bibNumber);
      await _participantRepository.addParticipant(participantDTO);
    } catch (e) {
      throw Exception("Error adding participant: $e");
    }
  }

  Future<void> deleteParticipant(String id) async {
    try {
      await _participantRepository.deleteParticipant(id);
    } catch (e) {
      throw Exception("Error deleting participant: $e");
    }
  }

  Future<void> updateParticipant(String id, String name, int bibNumber) async {
    try {
      final participantDTO = ParticipantDTO(name: name, bibNumber: bibNumber);
      await _participantRepository.updateParticipant(id, participantDTO);
    } catch (e) {
      throw Exception("Error updating participant: $e");
    }
  }

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}
