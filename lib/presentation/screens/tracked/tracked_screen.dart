import 'package:flutter/material.dart';
import 'package:multi_marathon/core/widgets/eror_indicator.dart';
import 'package:multi_marathon/core/widgets/loading_indicator.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:multi_marathon/presentation/screens/tracked/widgets/tracked_participant_list.dart';
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

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
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
            actions: [RaceStatusWidget(race: race)],
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
                  Expanded(
                    child: TrackedParticipantList(
                      selectedSegment: _selectedSegment,
                      participants: participants,
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
