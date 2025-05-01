import 'package:firebase_database/firebase_database.dart';
import 'package:multi_marathon/data/dtos/race_dto.dart';
import 'package:multi_marathon/data/models/race.dart';

class RaceRepository {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('race');

  Stream<Race?> getRaceStream() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return null;
      final raceDTO = RaceDTO.fromMap(Map<String, dynamic>.from(data));
      return Race(
        raceStatus: _statusFromString(raceDTO.raceStatus),
        startTime: raceDTO.startTime,
        endTime: raceDTO.endTime,
      );
    });
  }

  Future<void> startRace() async {
    await _ref.update({
      'raceStatus': 'onGoing',
      'startTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> finishRace() async {
    await _ref.update({
      'raceStatus': 'finished',
      'endTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> restartRace() async {
    await _ref.update({'raceStatus': 'notStarted', 'startTime': 0});
  }

  RaceStatus _statusFromString(String status) {
    switch (status) {
      case 'notStarted':
        return RaceStatus.notStarted;
      case 'onGoing':
        return RaceStatus.onGoing;
      case 'finished':
        return RaceStatus.finished;
      default:
        return RaceStatus.notStarted;
    }
  }
}
