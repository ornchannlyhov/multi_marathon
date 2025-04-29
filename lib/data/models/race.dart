enum RaceStatus { notStarted, onGoing, finished }

class Race {
  RaceStatus raceStatus;
  final int startTime;
  final int endTime;

  Race({
    required this.raceStatus,
    required this.startTime,
    required this.endTime,
  });
}
