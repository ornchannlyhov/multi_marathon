import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_marathon/core/utils/async_value.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/data/repositories/race_repository.dart';

class RaceProvider extends ChangeNotifier {
  final RaceRepository _raceRepository = RaceRepository();

  Stream<Race?> get raceStream => _raceRepository.getRaceStream();

  AsyncValue<Race?> _raceState = const AsyncValue.loading();
  AsyncValue<Race?> get raceState => _raceState;

  RaceProvider() {
    _listenToRace();
  }

  void _listenToRace() {
    raceStream.listen(
      (data) {
        _raceState = AsyncValue.success(data);
        notifyListeners();
      },
      onError: (error) {
        _raceState = AsyncValue.error(error);
        notifyListeners();
        throw Exception("Error fetching race data: $error");
      },
    );
  }

  // --- Race Control Methods ---
  Future<void> startRace() async {
    try {
      await _raceRepository.startRace();
    } catch (e) {
      throw Exception("Error starting race: $e");
    }
  }

  Future<void> finishRace() async {
    try {
      await _raceRepository.finishRace();
    } catch (e) {
      throw Exception("Error finishing race: $e");
    }
  }

  Future<void> restartRace() async {
    try {
      await _raceRepository.restartRace();
    } catch (e) {
      throw Exception("Error restarting race: $e");
    }
  }

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}
