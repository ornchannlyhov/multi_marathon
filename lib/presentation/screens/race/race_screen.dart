import 'package:flutter/material.dart';
import 'package:multi_marathon/core/widgets/eror_indicator.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:multi_marathon/presentation/widgets/timer_display_widget.dart';
import 'package:provider/provider.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/core/utils/async_value.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/race_controls.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/participants_list.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/edit_participant_dialog.dart';
import 'package:multi_marathon/presentation/widgets/race_status_widget.dart';
import 'package:multi_marathon/core/widgets/loading_indicator.dart';

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      final raceState = context.read<RaceProvider>().raceState;
      if (raceState.state == AsyncValueState.success &&
          raceState.data != null) {
        final race = raceState.data!;
        if (race.raceStatus == RaceStatus.onGoing) {
          context.read<RaceTimerProvider>().updateRace(race);
        }
      }
      _didLoad = true;
    }
  }

  Future<void> _handleStartRace() async {
    await context.read<SegmentTrackingProvider>().clearAllSegments();
    // ignore: use_build_context_synchronously
    await context.read<RaceProvider>().startRace();
  }

  Future<void> _handleFinishRace() async {
    await context.read<RaceProvider>().finishRace();
  }

  Future<void> _handleResetRace() async {
    await context.read<SegmentTrackingProvider>().clearAllSegments();
    // ignore: use_build_context_synchronously
    await context.read<RaceProvider>().restartRace();
  }

  Future<void> _onEditParticipant(Participant participant) async {
    await showEditParticipantDialog(context: context, participant: participant);
  }

  Future<void> _onDeleteParticipant(String id) async {
    await context.read<ParticipantProvider>().deleteParticipant(id);
  }

  @override
  Widget build(BuildContext context) {
    final raceProvider = context.watch<RaceProvider>();
    final participantProvider = context.watch<ParticipantProvider>();
    final raceTimerProvider = context.watch<RaceTimerProvider>();

    final raceState = raceProvider.raceState;
    final participantState = participantProvider.participantsState;

    return raceState.when(
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error) => Scaffold(
        appBar: AppBar(title: const Text("Race Screen")),
        body: ErrorDisplay(message: 'Race Error: $error'),
      ),
      success: (race) {
        return participantState.when(
          loading: () => const Scaffold(
            body: Center(child: LoadingIndicator()),
          ),
          error: (error) => Scaffold(
            appBar: AppBar(title: const Text("Race Screen")),
            body: ErrorDisplay(message: 'Participant Error: $error'),
          ),
          success: (participants) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Race Screen'),
                actions: [
                  RaceStatusWidget(
                    race: race ??
                        Race(
                          raceStatus: RaceStatus.notStarted,
                          startTime: 0,
                          endTime: 0,
                        ),
                  )
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TimerDisplayWidget(
                          elapsedSeconds: raceTimerProvider.elapsedSeconds),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ParticipantsList(
                          participants: participants,
                          race: race,
                          onEdit: _onEditParticipant,
                          onDelete: _onDeleteParticipant,
                          onAdd: () => showEditParticipantDialog(
                              context: context, participant: null),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RaceControls(
                        race: race,
                        onStart: _handleStartRace,
                        onFinish: _handleFinishRace,
                        onReset: _handleResetRace,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
