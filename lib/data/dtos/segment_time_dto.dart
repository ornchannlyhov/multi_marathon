class SegmentTimeDTO {
  final String participantId;
  final String segment;
  final int elapsedTimeInSeconds;

  SegmentTimeDTO({
    required this.participantId,
    required this.segment,
    required this.elapsedTimeInSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'segment': segment,
      'elapsedTimeInSeconds': elapsedTimeInSeconds,
    };
  }

  factory SegmentTimeDTO.fromMap(Map<String, dynamic> map) {
    return SegmentTimeDTO(
      participantId: map['participantId'] ?? '',
      segment: map['segment'] ?? '',
      elapsedTimeInSeconds: map['elapsedTimeInSeconds'] ?? 0,
    );
  }
}
