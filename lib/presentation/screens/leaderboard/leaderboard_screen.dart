import 'package:flutter/material.dart';
import 'package:multi_marathon/core/widgets/eror_indicator.dart';
import 'package:multi_marathon/core/widgets/loading_indicator.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/presentation/screens/leaderboard/widgets/leaderboard_grid_widget.dart';
import 'package:multi_marathon/presentation/widgets/race_status_widget.dart';
import 'package:multi_marathon/presentation/widgets/segment_info_widget.dart';
import 'package:multi_marathon/presentation/widgets/segment_switcher.dart';
import 'package:multi_marathon/presentation/widgets/timer_display_widget.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Segment _selectedSegment = Segment.swimming;

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    final raceState = context.watch<RaceProvider>().raceState;
    final raceTimer = context.read<RaceTimerProvider>();
    final elapsedSeconds = context.watch<RaceTimerProvider>().elapsedSeconds;
    final participantsState = participantProvider.participantsState;

    // You must replace these with actual values (maybe from Provider)
    final trackingProvider = context.watch<SegmentTrackingProvider>();
    final Map<Segment, Set<String>> recordedParticipants = {
      Segment.swimming: {},
      Segment.cycling: {},
      Segment.running: {},
    };

    return raceState.when(
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error) => Scaffold(
        appBar: AppBar(title: const Text("Ranking")),
        body: ErrorDisplay(message: 'Error $error'),
      ),
      success: (race) {
        if (race == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Ranking")),
            body: const Center(child: Text('No race data')),
          );
        }

        raceTimer.updateRace(race);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Ranking"),
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
                    recordedParticipants: recordedParticipants,
                    participants: participants,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LeaderboardGridWidget(
                      participants: participants,
                      race: race,
                      selectedSegment: _selectedSegment,
                      recordedParticipants: recordedParticipants,
                      trackingProvider: trackingProvider,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Button Pressed!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Test Button',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }
}