class SegmentTimeDTO {
  final String? id; 
  final String participantId;
  final String segment;
  final int elapsedTimeInSeconds;

  SegmentTimeDTO({
    this.id,
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

  factory SegmentTimeDTO.fromMap(Map<String, dynamic> map, {String? id}) {
    return SegmentTimeDTO(
      id: id,
      participantId: map['participantId'] ?? '',
      segment: map['segment'] ?? '',
      elapsedTimeInSeconds: map['elapsedTimeInSeconds'] ?? 0,
    );
  }
}
