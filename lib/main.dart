import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:multi_marathon/firebase_options.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:provider/provider.dart';

import 'my_app.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppProviders());
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RaceProvider>(
          create: (_) => RaceProvider(),
        ),
        StreamProvider<Race?>(
          create: (context) => context.read<RaceProvider>().raceStream,
          initialData: Race(
            raceStatus: RaceStatus.notStarted,
            startTime: 0,
            endTime: 0,
          ),
          catchError: (_, __) => null,
        ),

        ChangeNotifierProvider<ParticipantProvider>(
          create: (_) => ParticipantProvider(),
        ),
        StreamProvider<List<Participant>>(
          create: (context) {
            final participantProvider = context.read<ParticipantProvider>();
            return participantProvider.participantsStream;
          },
          initialData: const [],
          catchError: (_, __) => [],
        ),

        ChangeNotifierProxyProvider2<RaceProvider, ParticipantProvider,
            SegmentTrackingProvider>(
          create: (_) => SegmentTrackingProvider(),
          update: (context, raceProvider, participantProvider, trackingProvider) {
            return trackingProvider!..listenToSegments();
          },
        ),
        StreamProvider<List<SegmentTime>>(
          create: (context) =>
              context.read<SegmentTrackingProvider>().segmentStream,
          initialData: const [],
          catchError: (_, __) => [],
        ),

        ChangeNotifierProvider(create: (_) => RaceTimerProvider()),
      ],
      child: const MyApp(),
    );
  }
}
