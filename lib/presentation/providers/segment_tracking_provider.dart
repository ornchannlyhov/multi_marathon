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

  SegmentTrackingProvider() {
    _listenToSegments();
  }

  void _listenToSegments() {
    segmentStream.listen(
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
    try {
      final data =
          await _segmentTrackingRepository.getSegmentTimesByParticipant();
      _segmentsByParticipantState = AsyncValue.success(data);
      notifyListeners();
    } catch (e) {
      _segmentsByParticipantState = AsyncValue.error(e);
      notifyListeners();
    }
  }

  Future<void> fetchTotalTimeByParticipant() async {
    try {
      final data = await _segmentTrackingRepository.getTotalTimeByParticipant();
      _totalTimeByParticipantState = AsyncValue.success(data);
      notifyListeners();
    } catch (e) {
      _totalTimeByParticipantState = AsyncValue.error(e);
      notifyListeners();
    }
  }

  Future<void> recordSegmentTime(
      String participantId, Segment segment, int raceStartTime) async {
    try {
      final now = DateTime.now().second;
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

  Future<void> updateSegmentTime(
      String id, SegmentTimeDTO updatedSegmentTimeDTO) async {
    try {
      await _segmentTrackingRepository.updateSegmentTime(
          id, updatedSegmentTimeDTO);
      fetchSegmentTimesByParticipant();
    } catch (e) {
      throw Exception("Error updating segment time: $e");
    }
  }

  Future<void> deleteSegmentTime(String id) async {
    try {
      await _segmentTrackingRepository.deleteSegmentTime(id);
      fetchSegmentTimesByParticipant(); 
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
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}
