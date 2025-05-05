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
    notifyListeners();
  }

  void _start(int startTimestamp) {
    _startTimestamp = startTimestamp;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateElapsed();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _elapsedSeconds = ((now - _startTimestamp) / 1000).floor();
    notifyListeners();
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
