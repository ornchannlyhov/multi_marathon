import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/core/widgets/eror_indicator.dart';
import 'package:multi_marathon/core/widgets/loading_indicator.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatelessWidget {
  final List<Participant> participants;

  const LeaderboardScreen({super.key, required this.participants});

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  TextStyle get _headerStyle => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

  static const Map<Segment, Color> segmentColors = {
    Segment.swimming: Colors.lightBlue,
    Segment.cycling: Colors.orange,
    Segment.running: Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    final trackingProvider = context.watch<SegmentTrackingProvider>();
    final segmentState = trackingProvider.segmentsByParticipantState;

    return segmentState.when(
      loading: () => const LoadingIndicator(),
      error: (e) => ErrorDisplay(message: 'Error loading results: $e'),
      success: (segmentsByParticipant) {
        final leaderboardEntries = participants.map((participant) {
          final segmentTimes = segmentsByParticipant[participant.id] ?? [];

          int getSegmentTime(Segment s) {
            return segmentTimes
                .firstWhere(
                  (st) => st.segment == s,
                  orElse: () => SegmentTime(
                    id: '',
                    segment: s,
                    participantId: participant.id,
                    elapsedTimeInSeconds: 0,
                  ),
                )
                .elapsedTimeInSeconds;
          }

          final swimTime = getSegmentTime(Segment.swimming);
          final cycleTime = getSegmentTime(Segment.cycling);
          final runTime = getSegmentTime(Segment.running);
          final totalTime = swimTime + cycleTime + runTime;

          return {
            'participant': participant,
            'swimTime': swimTime,
            'cycleTime': cycleTime,
            'runTime': runTime,
            'totalTime': totalTime,
          };
        }).where((entry) => (entry['totalTime']! as int) > 0).toList();

        leaderboardEntries.sort(
          (a, b) => (a['totalTime']! as int).compareTo(b['totalTime']! as int),
        );

        if (leaderboardEntries.isEmpty) {
          return const Center(child: Text('No tracked data to show.'));
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Leaderboard Results',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: AppTheme.primaryColor.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text('Rank', style: _headerStyle)),
                    SizedBox(width: 60, child: Text('BIB', style: _headerStyle)),
                    Expanded(flex: 2, child: Text('Name', style: _headerStyle)),
                    SizedBox(width: 100, child: Text('Swim', style: _headerStyle)),
                    SizedBox(width: 100, child: Text('Cycle', style: _headerStyle)),
                    SizedBox(width: 60, child: Text('Run', style: _headerStyle)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboardEntries.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboardEntries[index];
                    final participant = entry['participant'] as Participant;
                    final swimTime = entry['swimTime'] as int;
                    final cycleTime = entry['cycleTime'] as int;
                    final runTime = entry['runTime'] as int;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(width: 60, child: Text('#${index + 1}')),
                            SizedBox(width: 60, child: Text(participant.bibNumber.toString())),
                            Expanded(flex: 2, child: Text(participant.name)),
                            SizedBox(
                              width: 90,
                              child: Text(
                                _formatTime(swimTime),
                                style: TextStyle(color: segmentColors[Segment.swimming]),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                _formatTime(cycleTime),
                                style: TextStyle(color: segmentColors[Segment.cycling]),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                _formatTime(runTime),
                                style: TextStyle(color: segmentColors[Segment.running]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
