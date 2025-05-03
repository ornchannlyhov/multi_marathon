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
import 'package:multi_marathon/presentation/screens/race/widgets/race_header.dart';
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

  // Adding segment tracking state
  Map<Segment, Set<String>> _recordedParticipants = {
    Segment.swimming: {},
    Segment.cycling: {},
    Segment.running: {},
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final raceProvider = Provider.of<RaceProvider>(context, listen: false);
      final raceState = raceProvider.raceState;

      if (raceState.state == AsyncValueState.success &&
          raceState.data != null) {
        final race = raceState.data!;
        if (race.raceStatus == RaceStatus.onGoing) {
          // Start timer through RaceTimerProvider
          Provider.of<RaceTimerProvider>(context, listen: false)
              .updateRace(race);
        }
      }

      _loadRecordedParticipants();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Loading recorded participants based on segments
  Future<void> _loadRecordedParticipants() async {
    final segmentProvider =
        Provider.of<SegmentTrackingProvider>(context, listen: false);
    final segmentsByParticipantState =
        segmentProvider.segmentsByParticipantState;

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

      if (mounted) {
        setState(() {
          _recordedParticipants = recordedMap;
        });
      }
    }
  }

  Future<void> _handleStartRace() async {
    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    final segmentProvider =
        Provider.of<SegmentTrackingProvider>(context, listen: false);

    await segmentProvider.clearAllSegments();
    await raceProvider.startRace();

    setState(() {
      _recordedParticipants = {
        Segment.swimming: {},
        Segment.cycling: {},
        Segment.running: {},
      };
    });
  }

  Future<void> _handleFinishRace() async {
    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    await raceProvider.finishRace();
  }

  Future<void> _handleResetRace() async {
    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    final segmentProvider =
        Provider.of<SegmentTrackingProvider>(context, listen: false);

    await segmentProvider.clearAllSegments();
    await raceProvider.restartRace();

    setState(() {
      _recordedParticipants = {
        Segment.swimming: {},
        Segment.cycling: {},
        Segment.running: {},
      };
    });
  }

  Future<void> _onEditParticipant(Participant participant) async {
    await showEditParticipantDialog(
      context: context,
      participant: participant,
    );
  }

  Future<void> _onDeleteParticipant(String id) async {
    final provider = Provider.of<ParticipantProvider>(context, listen: false);
    await provider.deleteParticipant(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Race Screen', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<RaceProvider>(
            builder: (context, raceProvider, _) {
              final raceState = raceProvider.raceState;
              final race = raceState.data;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RaceStatusWidget(
                    race: race ??
                        Race(
                            raceStatus: RaceStatus.notStarted,
                            startTime: 0,
                            endTime: 0)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer2<RaceProvider, ParticipantProvider>(
            builder: (context, raceProvider, participantProvider, _) {
              final raceState = raceProvider.raceState;
              final participantState = participantProvider.participantsState;
              final raceTimerProvider =
                  Provider.of<RaceTimerProvider>(context);

              if (raceState.state == AsyncValueState.loading ||
                  participantState.state == AsyncValueState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (raceState.state == AsyncValueState.error) {
                return Center(child: Text('Race Error: ${raceState.error}'));
              }

              if (participantState.state == AsyncValueState.error) {
                return Center(
                    child:
                        Text('Participant Error: ${participantState.error}'));
              }

              final race = raceState.data;
              final participants = participantState.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  RaceHeader(race: race),
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
                        showEditParticipantDialog(
                          context: context,
                          participant: null,
                        );
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
              );
            },
          ),
        ),
      ),
    );
  }
}
