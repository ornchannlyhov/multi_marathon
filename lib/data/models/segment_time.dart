enum Segment { swimming, cycling, running }

class SegmentTime {
  final Segment segment;
  final String participantId;
  final int elapsedTimeInSeconds;

  SegmentTime({
    required this.segment,
    required this.participantId,
    required this.elapsedTimeInSeconds,
  });
}
