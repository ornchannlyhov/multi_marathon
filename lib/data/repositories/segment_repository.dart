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
        final key = e.key as String;
        final segmentTimeDTO =
            SegmentTimeDTO.fromMap(Map<String, dynamic>.from(e.value), id: key);

        return SegmentTime(
          segment: _statusFromString(segmentTimeDTO.segment),
          participantId: segmentTimeDTO.participantId,
          elapsedTimeInSeconds: segmentTimeDTO.elapsedTimeInSeconds,
          id: key,
        );
      }).toList();
    });
  }

  Future<void> recordSegmentTime(SegmentTimeDTO segmentTimeDTO) async {
    final segmentRef = _ref.push();
    await segmentRef.set(segmentTimeDTO.toMap());
  }

  Future<Map<String, List<SegmentTime>>> getSegmentTimesByParticipant() async {
    final dataSnapshot = await _ref.get();
    final data = dataSnapshot.value as Map<dynamic, dynamic>?;

    final Map<String, List<SegmentTime>> participantSegments = {};

    if (data != null) {
      for (var entry in data.entries) {
        final dto =
            SegmentTimeDTO.fromMap(Map<String, dynamic>.from(entry.value));
        final segmentTime = SegmentTime(
          segment: _statusFromString(dto.segment),
          participantId: dto.participantId,
          elapsedTimeInSeconds: dto.elapsedTimeInSeconds,
          id: entry.key,
        );

        participantSegments
            .putIfAbsent(dto.participantId, () => [])
            .add(segmentTime);
      }
    }

    return participantSegments;
  }

  Future<Map<String, int>> getTotalTimeByParticipant() async {
    final segmentsByParticipant = await getSegmentTimesByParticipant();

    return segmentsByParticipant.map((participantId, segmentList) {
      final total = segmentList.fold<int>(
          0, (sum, seg) => sum + seg.elapsedTimeInSeconds);
      return MapEntry(participantId, total);
    });
  }

  Future<void> clearAllSegments() async {
    await _ref.remove();
  }

  Future<void> updateSegmentTime(
      String id, SegmentTimeDTO updatedSegmentTimeDTO) async {
    final segmentRef = _ref.child(id);
    await segmentRef.set(updatedSegmentTimeDTO.toMap());
  }

  Future<void> deleteSegmentTime(String id) async {
    final segmentRef = _ref.child(id);
    await segmentRef.remove();
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
