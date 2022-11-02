import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:advent_calendar_app/utils.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'CalendarDoor.dart';
import 'CalendarDoorContent.dart';
import 'constants.dart' as constants;
import 'package:flutter/services.dart';
import 'content.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const AdventCalendarApp());
}

class AdventCalendarApp extends StatefulWidget {
  const AdventCalendarApp({super.key});

  @override
  State<AdventCalendarApp> createState() => _AdventCalendarAppState();
}

class _AdventCalendarAppState extends State<AdventCalendarApp>
    with WidgetsBindingObserver {
  static final DateTime finalDate = DateTime(2022, DateTime.december, 24);
  static final DateTime firstDate =
      DateTime(finalDate.year, finalDate.month, 1);

  static final AudioPlayer musicPlayer = AudioPlayer();

  int _currentDoorNumber = 0;
  List<int> _doorNumbers = [];
  final List<bool> _openStates = [
    for (var i = 0; i < doorCount; i++) true
  ]; // TODO: revert
  final List<bool> _needsAnimating = [
    for (var i = 0; i < doorCount; i++) false
  ];
  final Map<int, AudioPlayer> _doorAudioPlayers = HashMap();
  Timer? _doorAudioFadingTimer;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    musicPlayer.setLoopMode(LoopMode.one);
    _updateCurrentDoor();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _updateCurrentDoor();
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery.of(context).size.width

    final ListView listView = ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 0),
      itemCount: _doorNumbers.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          final DateTime now = DateTime.now();
          // final DateTime now = DateTime(2022, DateTime.november, 30); // Use for testing
          final int daysLeft = daysBetween(now, firstDate);
          const Widget title = Text(
            'Joulukalenteri 2022',
            style: TextStyle(
                color: Colors.white, fontSize: 40, fontFamily: 'caveatBrush'),
          );

          final List<Widget> columnChildren;
          if (_currentDoorNumber == 0) {
            columnChildren = [
              title,
              const SizedBox(height: 50),
              const Text(
                'Ensimmäiseen luukkuun vielä',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'caveatBrush'),
              ),
              const SizedBox(height: 8),
              Text(
                '$daysLeft päivää...',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontFamily: 'caveatBrush'),
              ),
            ];
          } else {
            columnChildren = [title];
          }

          return Column(children: columnChildren);
        } else {
          final int listDoorIndex = index - 1;
          final int doorNumber = _currentDoorNumber - listDoorIndex;
          final int doorNumberIndex = doorNumber - 1;
          // Use InkWell without splash or highlight instead of GestureRecognizer
          // to recognize taps when CalendarRow door is open.
          return InkWell(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            onTap: () {
              _toggleIsOpen(doorNumberIndex);
            },
            child: CalendarRow(
              day: _doorNumbers[doorNumberIndex],
              isOpen: _openStates[doorNumberIndex],
              doorNumber: doorNumber,
              maxDoorCount: doorCount,
              textInfo: textInfo[doorNumber],
              snowmanInfo: snowmanInfo[doorNumber],
              animated: _needsAnimating[doorNumberIndex],
              didAnimate: () {
                didAnimate(doorNumberIndex);
              },
            ),
          );
        }
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 64),
    );

    const double wreathTop = -180;
    const double wreathSide = -130;

    final Widget wreath = SizedBox(
      width: 270,
      child: Image.asset(
        'assets/images/wreath.png',
        fit: BoxFit.fill,
      ),
    );

    return MaterialApp(
      home: Scaffold(
        backgroundColor: constants.calendarRed,
        body: Stack(
          children: [
            listView,
            Positioned(
              top: wreathTop,
              left: wreathSide,
              child: wreath,
            ),
            Positioned(
              top: wreathTop,
              right: wreathSide,
              child: wreath,
            ),
          ],
        ),
      ),
    );
  }

  void _updateCurrentDoor() {
    // final DateTime now = DateTime.now();
    final DateTime now =
        DateTime(2022, DateTime.december, 24); // Use for testing
    final int currentDoorNumber =
        _calculateCurrentDoorNumber(now, finalDate, doorCount);
    final List<int> doorNumbers = [
      for (var i = 1; i <= currentDoorNumber; i++) i
    ];

    setState(() {
      _currentDoorNumber = currentDoorNumber;
      _doorNumbers = doorNumbers;
    });
  }

  int _calculateCurrentDoorNumber(
      DateTime now, DateTime finalDate, int doorCount) {
    final int difference = daysBetween(now, finalDate);
    final int daysLeft = difference.clamp(0, doorCount);
    return doorCount - daysLeft;
  }

  void _toggleIsOpen(int index) {
    _doorAudioPlayers[index]?.stop();
    _doorAudioPlayers[index]?.dispose();
    final newOpenState = !_openStates[index];

    final player = AudioPlayer();
    player.setAsset('assets/audio/door1_short.m4a');
    player.play();

    HapticFeedback.lightImpact();

    if (newOpenState) {
      _stopMusicWithFadeOutIfNeeded();
    } else {
      _playMusicIfNeeded(index);
    }

    setState(() {
      _doorAudioPlayers[index] = player;
      _openStates[index] = newOpenState;
      _needsAnimating[index] = true;
    });
  }

  // Hack used together with _needsAnimating to only animate doors on user tap.
  // Otherwise they animate also when scrolling back into view and ListView rebuilds them.
  // Maybe a value listener could also work?
  void didAnimate(int index) {
    setState(() {
      _needsAnimating[index] = false;
    });
  }

  void _playMusicIfNeeded(int doorIndex) {
    final int distanceToFinalDoor = doorCount - 1 - doorIndex;
    if (distanceToFinalDoor < 5) {
      _cancelDoorAudioFadingTimer(_doorAudioFadingTimer);
      musicPlayer.setAsset('assets/audio/we_wish_you_a_merry_christmas.m4a');
      musicPlayer.play();
    } else if (distanceToFinalDoor < 11) {
      _cancelDoorAudioFadingTimer(_doorAudioFadingTimer);
      musicPlayer.setAsset('assets/audio/silent_night.m4a');
      musicPlayer.play();
    } else if (distanceToFinalDoor < 17) {
      _cancelDoorAudioFadingTimer(_doorAudioFadingTimer);
      musicPlayer.setAsset('assets/audio/jingle_bells.m4a');
      musicPlayer.play();
    }
  }

  void _stopMusicWithFadeOutIfNeeded() {
    if (!musicPlayer.playing || _doorAudioFadingTimer?.isActive == true) {
      return;
    }

    const double from = 1;
    const double to = 0;
    const int len = 1000;

    double vol = from;
    double diff = to - from;
    double steps = (diff / 0.01).abs();
    int stepLen = max(4, (steps > 0) ? len ~/ steps : len);
    int lastTick = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _doorAudioFadingTimer = Timer.periodic(Duration(milliseconds: stepLen), (Timer t) {
        var now = DateTime.now().millisecondsSinceEpoch;
        var tick = (now - lastTick) / len;
        lastTick = now;
        vol += diff * tick;

        vol = max(0, vol);
        vol = min(1, vol);
        vol = (vol * 100).round() / 100;

        musicPlayer.setVolume(vol);

        if ((to < from && vol <= to) || (to > from && vol >= to)) {
          _cancelDoorAudioFadingTimer(t);
        }
      });
    });
  }

  void _cancelDoorAudioFadingTimer(Timer? timer) {
    timer?.cancel();
    musicPlayer.stop();
    musicPlayer.setVolume(1);
  }
}

class CalendarRow extends StatelessWidget {
  final int day;
  final bool isOpen;
  final int doorNumber;
  final int maxDoorCount;
  final TextInfo? textInfo;
  final SnowmanInfo? snowmanInfo;
  final bool animated;
  final Function didAnimate;

  const CalendarRow({
    super.key,
    required this.day,
    required this.isOpen,
    required this.doorNumber,
    required this.maxDoorCount,
    required this.textInfo,
    required this.snowmanInfo,
    required this.animated,
    required this.didAnimate,
  });

  @override
  Widget build(BuildContext context) {
    final String text = '$day';
    Widget doorWidget;

    if ((day % 3 == 0 && day % 2 == 0) || day % 5 == 0) {
      doorWidget = CalendarDoubleDoor(
        isOpen: isOpen,
        text: text,
        animated: animated,
        didAnimate: didAnimate,
      );
    } else {
      doorWidget = CalendarSingleDoor(
        text: text,
        isOpen: isOpen,
        animated: animated,
        didAnimate: didAnimate,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CalendarDoorContent(
          isOpen: isOpen,
          isAnimatingDoor: animated,
          doorNumber: doorNumber,
          maxDoorCount: maxDoorCount,
          textInfo: textInfo,
          snowmanInfo: snowmanInfo,
          child: doorWidget,
        ),
      ],
    );
  }
}
