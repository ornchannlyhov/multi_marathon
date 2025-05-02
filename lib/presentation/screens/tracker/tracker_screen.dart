import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_marathon/core/widgets/eror_indicator.dart';
import 'package:multi_marathon/core/widgets/loading_indicator.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/screens/tracker/widgets/participants_grid_widget.dart';
import 'package:multi_marathon/presentation/widgets/race_status_widget.dart';
import 'package:multi_marathon/presentation/widgets/segment_info_widget.dart';
import 'package:multi_marathon/presentation/widgets/timer_display_widget.dart';
import 'package:provider/provider.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/widgets/segment_switcher.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  Segment _selectedSegment = Segment.swimming;
  final Map<Segment, Set<String>> _recordedParticipants = {
    Segment.swimming: {},
    Segment.cycling: {},
    Segment.running: {},
  };
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    final trackingProvider = context.watch<SegmentTrackingProvider>();
    final raceState = context.watch<RaceProvider>().raceState;

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
                  TimerDisplayWidget(elapsedSeconds: _elapsedSeconds),
                  const SizedBox(height: 16),
                  SegmentInfoWidget(
                    selectedSegment: _selectedSegment,
                    recordedParticipants: _recordedParticipants,
                    participants: participants,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ParticipantsGridWidget(
                      participants: participants,
                      race: race,
                      selectedSegment: _selectedSegment,
                      recordedParticipants: _recordedParticipants,
                      trackingProvider: trackingProvider,
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
}
