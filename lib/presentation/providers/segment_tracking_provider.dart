import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_marathon/core/utils/async_value.dart';
import 'package:multi_marathon/data/dtos/segment_time_dto.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/data/repositories/segment_repository.dart';

class SegmentTrackingProvider extends ChangeNotifier {
  final SegmentTrackingRepository _segmentTrackingRepository =
      SegmentTrackingRepository();

  Stream<List<SegmentTime>> get segmentStream =>
      _segmentTrackingRepository.getSegmentTimesStream();

  AsyncValue<List<SegmentTime>> _segmentsState = const AsyncValue.loading();
  AsyncValue<List<SegmentTime>> get segmentsState => _segmentsState;

  SegmentTrackingProvider() {
    _listenToSegments();
  }

  void _listenToSegments() {
    segmentStream.listen(
      (data) {
        _segmentsState = AsyncValue.success(data);
        notifyListeners();
      },
      onError: (error) {
        _segmentsState = AsyncValue.error(error);
        notifyListeners();
        throw Exception("Error fetching segment times: $error");
      },
    );
  }

  Future<void> recordSegmentTime(
      String participantId, Segment segment, int raceStartTime) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedTimeInSeconds = now - raceStartTime;
      final segmentTimeDTO = SegmentTimeDTO(
        participantId: participantId,
        segment: segment.name,
        elapsedTimeInSeconds: elapsedTimeInSeconds,
      );
      await _segmentTrackingRepository.recordSegmentTime(segmentTimeDTO);
    } catch (e) {
      throw Exception("Error recording segment time: $e");
    }
  }

  Future<void> clearAllSegments() async {
    try {
      await _segmentTrackingRepository.clearAllSegments();
    } catch (e) {
      throw Exception("Error clearing all segments: $e");
    }
  }

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}
