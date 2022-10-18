import 'package:advent_calendar_app/utils.dart';
import 'package:flutter/material.dart';
import 'CalendarDoor.dart';
import 'CalendarDoorContent.dart';
import 'constants.dart' as constants;

void main() {
  runApp(const AdventCalendarApp());
}

class AdventCalendarApp extends StatefulWidget {
  const AdventCalendarApp({super.key});

  @override
  State<AdventCalendarApp> createState() => _AdventCalendarAppState();
}

class _AdventCalendarAppState extends State<AdventCalendarApp> {
  static final DateTime finalDate = DateTime(2022, 10, 24); // December = 11
  static const int doorCount = 24;

  static final DateTime now = DateTime.now();
  // static final DateTime now = DateTime(2022, 10, 25);
  static final int currentDoorNumber = _currentDoorNumber(now, finalDate, doorCount);
  static final List<int> days = [for (var i = currentDoorNumber; i >= 1; i--) i];
  static final bool isLastDay = currentDoorNumber == doorCount;

  final List<bool> _openStates = [for (var i = currentDoorNumber; i >= 1; i--) true]; // TODO: revert
  final List<bool> _needsAnimating = [for (var i = currentDoorNumber; i >= 1; i--) false];

  @override
  Widget build(BuildContext context) {
    // MediaQuery.of(context).size.width

    return MaterialApp(
      home: Scaffold(
        backgroundColor: constants.calendarRed,
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 0),
          itemCount: days.length,
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
                day: days[index],
                isOpen: _openStates[index],
                isLastDoor: index == 0 && isLastDay,
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

  static int _currentDoorNumber(DateTime now, DateTime finalDate, int doorCount) {
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
  final bool isLastDoor;
  final bool animated;
  final Function didAnimate;

  const CalendarRow({
    super.key,
    required this.day,
    required this.isOpen,
    required this.isLastDoor,
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
          isLastDoor: isLastDoor,
          child: doorWidget,
        ),
      ],
    );
  }
}
