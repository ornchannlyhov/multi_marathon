class RaceDTO {
  final String raceStatus;
  final int startTime;
  final int endTime;

  RaceDTO({
    required this.raceStatus,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'raceStatus': raceStatus,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory RaceDTO.fromMap(Map<String, dynamic> map) {
    return RaceDTO(
      raceStatus: map['raceStatus'] ?? 'notStarted',
      startTime: map['startTime'] ?? 0,
      endTime: map['endTime'] ?? 0,
    );
  }
}
