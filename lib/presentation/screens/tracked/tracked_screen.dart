import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_marathon/core/widgets/eror_indicator.dart';
import 'package:multi_marathon/core/widgets/loading_indicator.dart';
import 'package:multi_marathon/data/dtos/segment_time_dto.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/presentation/widgets/race_status_widget.dart';
import 'package:multi_marathon/presentation/widgets/segment_info_widget.dart';
import 'package:multi_marathon/presentation/widgets/segment_switcher.dart';
import 'package:multi_marathon/presentation/widgets/timer_display_widget.dart';
import 'package:provider/provider.dart';

class TrackedScreen extends StatefulWidget {
  const TrackedScreen({super.key});

  @override
  State<TrackedScreen> createState() => _TrackedScreenState();
}

class _TrackedScreenState extends State<TrackedScreen> {
  Segment _selectedSegment = Segment.swimming;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).round();
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    final trackingProvider = context.watch<SegmentTrackingProvider>();
    final raceState = context.watch<RaceProvider>().raceState;
    final raceTimer = context.read<RaceTimerProvider>();
    final elapsedSeconds = context.watch<RaceTimerProvider>().elapsedSeconds;
    final participantsState = participantProvider.participantsState;

    return raceState.when(
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error) => Scaffold(
        appBar: AppBar(title: const Text("Tracker")),
        body: ErrorDisplay(message: 'Error $error'),
      ),
      success: (race) {
        if (race == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Tracker")),
            body: const Center(child: Text('No race data')),
          );
        }

        raceTimer.updateRace(race);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Tracker"),
            actions: [
              RaceStatusWidget(race: race),
            ],
          ),
          body: participantsState.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error) => ErrorDisplay(message: 'Error $error'),
            success: (participants) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  SegmentSwitcher(
                    selectedSegment: _selectedSegment,
                    onSegmentChanged: (segment) {
                      setState(() {
                        _selectedSegment = segment;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TimerDisplayWidget(elapsedSeconds: elapsedSeconds),
                  const SizedBox(height: 16),
                  SegmentInfoWidget(
                    selectedSegment: _selectedSegment,
                    recordedParticipants: null,
                    participants: participants,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final segmentsByParticipant =
                            trackingProvider.segmentsByParticipantState;

                        return segmentsByParticipant.when(
                          loading: () => const LoadingIndicator(),
                          error: (e) => ErrorDisplay(
                              message: "Error loading segment times: $e"),
                          success: (segmentData) {
                            final filtered = segmentData.entries.where((entry) {
                              return entry.value.any(
                                (seg) => seg.segment == _selectedSegment,
                              );
                            });

                            if (filtered.isEmpty) {
                              return const Center(
                                  child: Text(
                                      'No tracked participants for this segment.'));
                            }

                            return ListView(
                              children: filtered.map((entry) {
                                final participantId = entry.key;
                                final participant = participants.firstWhere(
                                  (p) => p.id == participantId,
                                  orElse: () => Participant(
                                      id: '', name: 'Unknown', bibNumber: 0),
                                );
                                final segmentTime = entry.value.firstWhere(
                                  (seg) => seg.segment == _selectedSegment,
                                );

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                        '${participant.bibNumber} - ${participant.name}'),
                                    subtitle: Text(
                                        'Time: ${_formatTime(segmentTime.elapsedTimeInSeconds)}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () async {
                                            final updated =
                                                await _showEditTimeDialog(
                                                    context, segmentTime);
                                            if (updated != null) {
                                              await trackingProvider
                                                  .updateSegmentTime(
                                                      segmentTime.id, updated);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            await trackingProvider
                                                .deleteSegmentTime(
                                                    segmentTime.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<SegmentTimeDTO?> _showEditTimeDialog(
      BuildContext context, SegmentTime time) async {
    final hoursController = TextEditingController(
        text: (time.elapsedTimeInSeconds ~/ 3600).toString().padLeft(2, '0'));
    final minutesController = TextEditingController(
        text: ((time.elapsedTimeInSeconds % 3600) ~/ 60)
            .toString()
            .padLeft(2, '0'));
    final secondsController = TextEditingController(
        text: (time.elapsedTimeInSeconds % 60).toString().padLeft(2, '0'));

    return showDialog<SegmentTimeDTO>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hoursController,
                      decoration: const InputDecoration(
                          labelText: 'Hours', hintText: '00'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(':'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: minutesController,
                      decoration: const InputDecoration(
                          labelText: 'Minutes', hintText: '00'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(':'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: secondsController,
                      decoration: const InputDecoration(
                          labelText: 'Seconds', hintText: '00'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final hours = int.tryParse(hoursController.text) ?? 0;
                final minutes = int.tryParse(minutesController.text) ?? 0;
                final seconds = int.tryParse(secondsController.text) ?? 0;

                final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

                final updatedTime = SegmentTimeDTO(
                  participantId: time.participantId,
                  segment: time.segment.name,
                  elapsedTimeInSeconds: totalSeconds,
                );
                Navigator.pop(context, updatedTime);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
