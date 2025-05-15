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
        // Filter participants who have at least one segment time > 0
        final trackedParticipants = participants.where((participant) {
          final segmentTimes = segmentsByParticipant[participant.id] ?? [];
          return segmentTimes.any((st) => st.elapsedTimeInSeconds > 0);
        }).toList();

        if (trackedParticipants.isEmpty) {
          return const Center(child: Text('No tracked participants to display.'));
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
                      'Leaderboard',
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
                    SizedBox(width: 60, child: Text('BIB', style: _headerStyle)),
                    Expanded(flex: 2, child: Text('Name', style: _headerStyle)),
                    ...Segment.values.map((segment) => Expanded(
                      child: Text(
                        segment.name.toUpperCase(),
                        style: _headerStyle,
                        textAlign: TextAlign.center,
                      ),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: trackedParticipants.length,
                  itemBuilder: (context, index) {
                    final participant = trackedParticipants[index];
                    final segmentTimes = segmentsByParticipant[participant.id] ?? [];

                    Map<Segment, int> timesBySegment = {
                      for (var segment in Segment.values) segment: 0,
                    };

                    for (var time in segmentTimes) {
                      timesBySegment[time.segment] = time.elapsedTimeInSeconds;
                    }

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
                            SizedBox(width: 60, child: Text(participant.bibNumber.toString())),
                            Expanded(flex: 2, child: Text(participant.name)),
                            ...Segment.values.map((segment) {
                              final time = timesBySegment[segment]!;
                              return Expanded(
                                child: Text(
                                  time > 0 ? _formatTime(time) : '-',
                                  style: TextStyle(
                                    color: time > 0
                                        ? segmentColors[segment]
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }),
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
