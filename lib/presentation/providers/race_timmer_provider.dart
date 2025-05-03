import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_marathon/data/models/race.dart';

class RaceTimerProvider extends ChangeNotifier {
  Timer? _timer;
  int _elapsedSeconds = 0;  
  int _startTimestamp = 0; 
  RaceStatus? _lastStatus;

  int get elapsedSeconds => _elapsedSeconds;

  void updateRace(Race race) {
    if (_lastStatus != race.raceStatus) {
      _lastStatus = race.raceStatus;

      if (race.raceStatus == RaceStatus.onGoing) {
        _start(race.startTime);
      } else {
        _stop();
      }
    }
  }
  
  void reset() {
    _elapsedSeconds = 0;
    _stop();
    notifyListeners(); // Notify listeners to update the UI.
  }

  void _start(int startTimestamp) {
    _elapsedSeconds = 0; 
    final startTimeInSeconds = startTimestamp ~/ 1000;
    _startTimestamp = startTimeInSeconds;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    _elapsedSeconds = now - _startTimestamp; 

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;  
      notifyListeners();  
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }
}
