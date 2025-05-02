enum Segment { swimming, cycling, running }

extension SegmentExtension on Segment {
  String get name {
    switch (this) {
      case Segment.swimming:
        return 'Swimming';
      case Segment.cycling:
        return 'Cycling';
      case Segment.running:
        return 'Running';
    }
  }

  String get progressText {
    switch (this) {
      case Segment.swimming:
        return '500m';
      case Segment.cycling:
        return '20km';
      case Segment.running:
        return '10km';
    }
  }

  String segmentToString(Segment segment) =>
      segment.name; 

  Segment stringToSegment(String segment) {
    switch (segment) {
      case 'Swimming':
        return Segment.swimming;
      case 'Cycling':
        return Segment.cycling;
      case 'Running':
        return Segment.running;
      default:
        throw Exception('Invalid segment name');
    }
  }
}

class SegmentTime {
  final String id;
  final Segment segment;
  final String participantId;
  final int elapsedTimeInSeconds;
    

  SegmentTime({
    required this.id,
    required this.segment,
    required this.participantId,
    required this.elapsedTimeInSeconds,
  });
}
