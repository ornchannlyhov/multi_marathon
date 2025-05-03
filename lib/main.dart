import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:multi_marathon/core/theme.dart';
import 'package:multi_marathon/firebase_options.dart';
import 'package:multi_marathon/data/models/race.dart';
import 'package:multi_marathon/data/models/segment_time.dart';
import 'package:multi_marathon/data/models/participant.dart';
import 'package:multi_marathon/presentation/providers/participant_provider.dart';
import 'package:multi_marathon/presentation/providers/race_provider.dart';
import 'package:multi_marathon/presentation/providers/race_timmer_provider.dart';
import 'package:multi_marathon/presentation/providers/segment_tracking_provider.dart';
import 'package:multi_marathon/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:multi_marathon/presentation/screens/race/race_screen.dart';
import 'package:multi_marathon/presentation/screens/tracked/tracked_screen.dart';
import 'package:multi_marathon/presentation/screens/tracker/tracker_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const RaceScreen(),
    const TrackerScreen(),
    const TrackedScreen(),
    const LeaderboardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            final participantProvider = Provider.of<ParticipantProvider>(
              context,
              listen: false,
            );
            return participantProvider.participantsStream;
          },
          initialData: const [],
          catchError: (_, __) => [],
        ),

        ChangeNotifierProvider<SegmentTrackingProvider>(
          create: (_) => SegmentTrackingProvider(),
        ),
        StreamProvider<List<SegmentTime>>(
          create: (ctx) => ctx.read<SegmentTrackingProvider>().segmentStream,
          initialData: const [],
        ),
        ChangeNotifierProvider(create: (_) => RaceTimerProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.run_circle_outlined, size: 30),
                label: 'Race',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                label: 'Tracker',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                label: 'Tracked',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard_outlined),
                label: 'Ranks',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
