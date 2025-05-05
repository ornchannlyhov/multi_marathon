import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/core/widgets/eror_indicator.dart';
import 'package:multi_marathon/core/widgets/loading_indicator.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/data/dtos/segment_time_dto.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/presentation/screens/tracked/widgets/edit_segment_time_form.dart';
import 'package:provider/provider.dart';

class TrackedParticipantList extends StatelessWidget {
  final Segment selectedSegment;
  final List<Participant> participants;

  const TrackedParticipantList({
    super.key,
    required this.selectedSegment,
    required this.participants,
  });

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

  @override
  Widget build(BuildContext context) {
    final trackingProvider = context.watch<SegmentTrackingProvider>();
    final segmentsByParticipant = trackingProvider.segmentsByParticipantState;

    return segmentsByParticipant.when(
      loading: () => const LoadingIndicator(),
      error: (e) => ErrorDisplay(message: "Error loading segment times: $e"),
      success: (segmentData) {
        final filtered = segmentData.entries.where((entry) {
          return entry.value.any((seg) => seg.segment == selectedSegment);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
              child: Text('No tracked participants for this segment.'));
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tracked Participants',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // ignore: deprecated_member_use
                color: AppTheme.primaryColor.withOpacity(0.2),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                        width: 40, child: Text('BIB', style: _headerStyle)),
                    Expanded(flex: 2, child: Text('Name', style: _headerStyle)),
                    SizedBox(
                        width: 80, child: Text('Time', style: _headerStyle)),
                    SizedBox(
                        width: 60, child: Text('Action', style: _headerStyle)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    final participantId = entry.key;
                    final participant = participants.firstWhere(
                      (p) => p.id == participantId,
                      orElse: () =>
                          Participant(id: '', name: 'Unknown', bibNumber: 0),
                    );
                    final segmentTime = entry.value.firstWhere(
                      (seg) => seg.segment == selectedSegment,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(participant.bibNumber.toString()),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(participant.name),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(_formatTime(
                                  segmentTime.elapsedTimeInSeconds)),
                            ),
                            SizedBox(
                              width: 80,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 20, color: AppTheme.warningColor),
                                    onPressed: () async {
                                      final updated =
                                          await showDialog<SegmentTimeDTO>(
                                        context: context,
                                        builder: (_) => EditSegmentTimeForm(
                                            initialTime: segmentTime),
                                      );
                                      if (updated != null) {
                                        await trackingProvider
                                            .updateSegmentTime(
                                                segmentTime.id, updated);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: AppTheme.dangerColor),
                                    onPressed: () async {
                                      await trackingProvider
                                          .deleteSegmentTime(segmentTime.id);
                                    },
                                  ),
                                ],
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
