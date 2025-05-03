import 'dart:async';
import 'package:flutter/material.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:provider/provider.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/core/utils/async_value.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/race_timer.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/race_controls.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/participants_list.dart';
import 'package:multi_marathon/presentation/screens/race/widgets/edit_participant_dialog.dart';
import 'package:multi_marathon/presentation/widgets/race_status_widget.dart';
class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  Segment selectedSegment = Segment.swimming;
  Map<Segment, Set<String>> _recordedParticipants = {
    Segment.swimming: {},
    Segment.cycling: {},
    Segment.running: {},
  };
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      final raceProvider = context.read<RaceProvider>();
      final segmentProvider = context.read<SegmentTrackingProvider>();
      final raceState = raceProvider.raceState;

      if (raceState.state == AsyncValueState.success && raceState.data != null) {
        final race = raceState.data!;
        if (race.raceStatus == RaceStatus.onGoing) {
          context.read<RaceTimerProvider>().updateRace(race);
        }
      }

      final segmentsByParticipantState = segmentProvider.segmentsByParticipantState;
      if (segmentsByParticipantState.state == AsyncValueState.success &&
          segmentsByParticipantState.data != null) {
        final segmentsByParticipant = segmentsByParticipantState.data!;
        final recordedMap = {
          Segment.swimming: <String>{},
          Segment.cycling: <String>{},
          Segment.running: <String>{},
        };

        segmentsByParticipant.forEach((id, times) {
          for (final segmentTime in times) {
            recordedMap[segmentTime.segment]!.add(id);
          }
        });

        _recordedParticipants = recordedMap;
      }

      _didLoad = true;
    }
  }

  Future<void> _handleStartRace() async {
    await context.read<SegmentTrackingProvider>().clearAllSegments();
    await context.read<RaceProvider>().startRace();
    setState(() {
      _recordedParticipants = {
        Segment.swimming: {},
        Segment.cycling: {},
        Segment.running: {},
      };
    });
  }

  Future<void> _handleFinishRace() async {
    await context.read<RaceProvider>().finishRace();
  }

  Future<void> _handleResetRace() async {
    await context.read<SegmentTrackingProvider>().clearAllSegments();
    await context.read<RaceProvider>().restartRace();
    setState(() {
      _recordedParticipants = {
        Segment.swimming: {},
        Segment.cycling: {},
        Segment.running: {},
      };
    });
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

    if (raceState.state == AsyncValueState.loading ||
        participantState.state == AsyncValueState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (raceState.state == AsyncValueState.error) {
      return Scaffold(
        body: Center(child: Text('Race Error: ${raceState.error}')),
      );
    }

    if (participantState.state == AsyncValueState.error) {
      return Scaffold(
        body: Center(child: Text('Participant Error: ${participantState.error}')),
      );
    }

    final race = raceState.data;
    final participants = participantState.data ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Race Screen'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RaceStatusWidget(
              race: race ?? Race(
                raceStatus: RaceStatus.notStarted,
                startTime: 0,
                endTime: 0,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              RaceTimer(elapsedSeconds: raceTimerProvider.elapsedSeconds),
              const SizedBox(height: 16),
              Expanded(
                child: ParticipantsList(
                  participants: participants,
                  race: race,
                  selectedSegment: selectedSegment.name,
                  onEdit: _onEditParticipant,
                  onDelete: _onDeleteParticipant,
                  recordedParticipants: _recordedParticipants,
                  onAdd: () {
                    showEditParticipantDialog(context: context, participant: null);
                  },
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
  }
}
