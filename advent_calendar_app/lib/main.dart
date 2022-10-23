import 'package:advent_calendar_app/utils.dart';
import 'package:flutter/material.dart';
import 'CalendarDoor.dart';
import 'CalendarDoorContent.dart';
import 'constants.dart' as constants;
import 'package:flutter/services.dart';

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
  static final DateTime firstDate = DateTime(finalDate.year, finalDate.month, 1);
  static const int doorCount = 24;

  int _currentDoorNumber = 0;
  List<int> _doorNumbers = [];
  final List<bool> _openStates = [for (var i = 0; i < doorCount; i++) true]; // TODO: revert
  final List<bool> _needsAnimating = [for (var i = 0; i < doorCount; i++) false];

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    return MaterialApp(
      home: Scaffold(
        backgroundColor: constants.calendarRed,
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 0),
          itemCount: _doorNumbers.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              final DateTime now = DateTime.now();
              // final DateTime now = DateTime(2022, DateTime.november, 30); // Use for testing
              final int daysLeft = daysBetween(now, firstDate);
              const Widget title = Text(
                'Joulukalenteri 2022',
                style: TextStyle(color: Colors.white, fontSize: 40, fontFamily: 'caveatBrush'),
              );

              final List<Widget> columnChildren;
              if (_currentDoorNumber == 0) {
                columnChildren = [
                  title,
                  const SizedBox(height: 50),
                  const Text(
                    'Ensimmäiseen luukkuun vielä',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'caveatBrush'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$daysLeft päivää...',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'caveatBrush'),
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
        ),
      ),
    );
  }

  void _updateCurrentDoor() {
    // final DateTime now = DateTime.now();
    final DateTime now = DateTime(2022, DateTime.december, 11); // Use for testing
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
    setState(() {
      _openStates[index] = !_openStates[index];
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
}

class CalendarRow extends StatelessWidget {
  final int day;
  final bool isOpen;
  final int doorNumber;
  final int maxDoorCount;
  final bool animated;
  final Function didAnimate;

  const CalendarRow({
    super.key,
    required this.day,
    required this.isOpen,
    required this.doorNumber,
    required this.maxDoorCount,
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
          doorNumber: doorNumber,
          maxDoorCount: maxDoorCount,
          child: doorWidget,
        ),
      ],
    );
  }
}
