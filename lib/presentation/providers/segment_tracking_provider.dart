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

  AsyncValue<Map<String, List<SegmentTime>>> _segmentsByParticipantState =
      const AsyncValue.loading();
  AsyncValue<Map<String, List<SegmentTime>>> get segmentsByParticipantState =>
      _segmentsByParticipantState;

  AsyncValue<Map<String, int>> _totalTimeByParticipantState =
      const AsyncValue.loading();
  AsyncValue<Map<String, int>> get totalTimeByParticipantState =>
      _totalTimeByParticipantState;

  StreamSubscription<List<SegmentTime>>? _segmentSubscription;

  SegmentTrackingProvider() {
    listenToSegments();
  }

  void listenToSegments() {
    _segmentSubscription = segmentStream.listen(
      (data) {
        _segmentsState = AsyncValue.success(data);
        notifyListeners();
        _fetchDerivedData();
      },
      onError: (error) {
        _segmentsState = AsyncValue.error(error);
        notifyListeners();
      },
    );
  }

  Future<void> _fetchDerivedData() async {
    await Future.wait([
      fetchSegmentTimesByParticipant(),
      fetchTotalTimeByParticipant(),
    ]);
  }

  Future<void> fetchSegmentTimesByParticipant() async {
    _segmentsByParticipantState = const AsyncValue.loading();
    notifyListeners();

    try {
      final data =
          await _segmentTrackingRepository.getSegmentTimesByParticipant();
      _segmentsByParticipantState = AsyncValue.success(data);
    } catch (e) {
      _segmentsByParticipantState = AsyncValue.error(e);
    }

    notifyListeners();
  }

  Future<void> fetchTotalTimeByParticipant() async {
    _totalTimeByParticipantState = const AsyncValue.loading();
    notifyListeners();

    try {
      final data = await _segmentTrackingRepository.getTotalTimeByParticipant();
      _totalTimeByParticipantState = AsyncValue.success(data);
    } catch (e) {
      _totalTimeByParticipantState = AsyncValue.error(e);
    }

    notifyListeners();
  }

  Future<void> recordSegmentTime(
      String participantId, Segment segment, int raceStartTime) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedTimeInSeconds = ((now - raceStartTime) / 1000).floor();
      final segmentTimeDTO = SegmentTimeDTO(
        participantId: participantId,
        segment: segment.name,
        elapsedTimeInSeconds: elapsedTimeInSeconds,
      );
      await _segmentTrackingRepository.recordSegmentTime(segmentTimeDTO);
      await _fetchDerivedData();
    } catch (e) {
      throw Exception("Error recording segment time: $e");
    }
  }

  Future<void> updateSegmentTime(
      String id, SegmentTimeDTO updatedSegmentTimeDTO) async {
    try {
      await _segmentTrackingRepository.updateSegmentTime(
          id, updatedSegmentTimeDTO);
      await _fetchDerivedData();
    } catch (e) {
      throw Exception("Error updating segment time: $e");
    }
  }

  Future<void> deleteSegmentTime(String id) async {
    try {
      await _segmentTrackingRepository.deleteSegmentTime(id);
      await _fetchDerivedData();
    } catch (e) {
      throw Exception("Error deleting segment time: $e");
    }
  }

  Future<void> deleteSegmentTimeForParticipant(
    String participantId,
    Segment segment,
  ) async {
    try {
      final segmentTimes =
          await _segmentTrackingRepository.getSegmentTimesByParticipant();
      final participantSegments = segmentTimes[participantId] ?? [];

      SegmentTime? segmentTime;
      for (final st in participantSegments) {
        if (st.segment == segment) {
          segmentTime = st;
          break;
        }
      }

      if (segmentTime != null) {
        await _segmentTrackingRepository.deleteSegmentTime(segmentTime.id);
        await _fetchDerivedData();
      }
    } catch (e) {
      throw Exception("Error deleting segment time: $e");
    }
  }

  Future<void> clearAllSegments() async {
    try {
      await _segmentTrackingRepository.clearAllSegments();
      _segmentsState = const AsyncValue.success([]);
      _segmentsByParticipantState = const AsyncValue.success({});
      _totalTimeByParticipantState = const AsyncValue.success({});
      notifyListeners();
    } catch (e) {
      throw Exception("Error clearing all segments: $e");
    }
  }

  @override
  void dispose() {
    _segmentSubscription?.cancel();
    super.dispose();
  }
}
