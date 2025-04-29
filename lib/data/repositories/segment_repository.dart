import 'package:firebase_database/firebase_database.dart';
import 'package:multi_marathon/data/dtos/segment_time_dto.dart';
import 'package:multi_marathon/data/models/segment_time.dart';

class SegmentTrackingRepository {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('segments');

  Stream<List<SegmentTime>> getSegmentTimesStream() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        final segmentTimeDTO = SegmentTimeDTO.fromMap(Map<String, dynamic>.from(e.value));
        return SegmentTime(
          segment: _statusFromString(segmentTimeDTO.segment),
          participantId: segmentTimeDTO.participantId,
          elapsedTimeInSeconds: segmentTimeDTO.elapsedTimeInSeconds,
        );
      }).toList();
    });
  }

  Future<void> recordSegmentTime(SegmentTimeDTO segmentTimeDTO) async {
    final segmentRef = _ref.push();
    await segmentRef.set(segmentTimeDTO.toMap());
  }

  Future<void> clearAllSegments() async {
    await _ref.remove();
  }

  Segment _statusFromString(String segment) {
    switch (segment) {
      case 'Swimming':
        return Segment.swimming;
      case 'Cycling':
        return Segment.cycling;
      case 'Running':
        return Segment.running;
      default:
        throw ArgumentError('Invalid segment: $segment');
    }
  }
}
