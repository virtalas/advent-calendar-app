import 'package:advent_calendar_app/utils.dart';
import 'package:flutter/material.dart';
import 'CalendarDoor.dart';
import 'CalendarDoorContent.dart';
import 'constants.dart' as constants;
import 'package:flutter/services.dart';

void main() {
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

class _AdventCalendarAppState extends State<AdventCalendarApp> with WidgetsBindingObserver {
  static final DateTime finalDate = DateTime(2022, 10, 24); // December = 11
  static const int doorCount = 24;

  int _currentDoorNumber = 0;
  List<int> _doorNumbers = [];
  List<bool> _openStates = [];
  List<bool> _needsAnimating = [];

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
          itemCount: _doorNumbers.length,
          itemBuilder: (BuildContext context, int index) {
            // Use InkWell (without splash or highlight) instead of GestureRecognizer
            // to recognize taps when CalendarRow door is open.
            return InkWell(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              onTap: () {
                _toggleIsOpen(index);
              },
              child: CalendarRow(
                day: _doorNumbers[index],
                isOpen: _openStates[index],
                doorNumber: _currentDoorNumber - index,
                maxDoorCount: doorCount,
                animated: _needsAnimating[index],
                didAnimate: () {
                  didAnimate(index);
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 64),
        ),
      ),
    );
  }

  void _updateCurrentDoor() {
    final DateTime now = DateTime.now();
    // final DateTime now = DateTime(2022, 10, 25); // Change for testing
    final int currentDoorNumber = _calculateCurrentDoorNumber(now, finalDate, doorCount);
    final List<int> doorNumbers = [for (var i = currentDoorNumber; i >= 1; i--) i];
    final bool isLastDay = currentDoorNumber == doorCount;

    setState(() {
      if (_currentDoorNumber != currentDoorNumber) {
        _currentDoorNumber = currentDoorNumber;
      }

      if (_doorNumbers != doorNumbers) {
        _doorNumbers = doorNumbers;
      }

      if (_openStates.length < doorNumbers.length) {
        for (var i = _openStates.length; i < doorNumbers.length; i++) {
          _openStates.add(true); // TODO: revert
        }
      } else if (_openStates.length > doorNumbers.length) {
        // Should never happen
        _openStates = [for (var i = currentDoorNumber; i >= 1; i--) true]; // TODO: revert
      }

      if (_needsAnimating.length < doorNumbers.length) {
        for (var i = _needsAnimating.length; i < doorNumbers.length; i++) {
          _needsAnimating.add(false);
        }
      } else if (_needsAnimating.length > doorNumbers.length) {
        // Should never happen
        _needsAnimating = [for (var i = currentDoorNumber; i >= 1; i--) false];
      }
    });
  }

  int _calculateCurrentDoorNumber(DateTime now, DateTime finalDate, int doorCount) {
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
  // Otherwise they animate also when scrolling back into view, and ListView rebuilds them.
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
    final String text = '$day. luukku';
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
