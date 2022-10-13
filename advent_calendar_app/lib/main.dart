import 'package:flutter/material.dart';
import 'CalendarDoor.dart';
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
  final List<bool> _openStates = <bool>[true, true, true, true];
  final List<bool> _needsAnimating = <bool>[false, false, false, false];

  @override
  Widget build(BuildContext context) {
    final List<int> days = <int>[12, 11, 10, 9];

    // MediaQuery.of(context).size.width

    return MaterialApp(
      home: Scaffold(
        backgroundColor: constants.calendarRed,
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 0),
          itemCount: days.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              onTap: () {
                _toggleIsOpen(index);
              },
              child: CalendarRow(
                day: days[index],
                isOpen: _openStates[index],
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

  void _toggleIsOpen(int index) {
    setState(() {
      _openStates[index] = !_openStates[index];
      _needsAnimating[index] = true;
    });
  }

  void didAnimate(int index) {
    setState(() {
      _needsAnimating[index] = false;
    });
  }
}

class CalendarRow extends StatelessWidget {
  final int day;
  final bool isOpen;
  final bool animated;
  final Function didAnimate;

  const CalendarRow(
      {super.key,
      required this.day,
      required this.isOpen,
      required this.animated,
      required this.didAnimate});

  @override
  Widget build(BuildContext context) {
    final String text = '$day. luukku';
    Widget doorWidget;

    if ((day % 3 == 0 && day % 2 == 0) || day % 5 == 0) {
      doorWidget = CalendarDoubleDoor(
        isFlipped: isOpen,
        text: text,
        animated: animated,
        didAnimate: didAnimate,
      );
    } else {
      doorWidget = CalendarSingleDoor(text: text, isFlipped: isOpen, animated: animated, didAnimate: didAnimate);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CalendarDoorContent(
          child: doorWidget,
        ),
      ],
    );
  }
}

class CalendarDoorContent extends StatelessWidget {
  Widget child;
  CalendarDoorContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: constants.doorHeight + constants.crackLength * 2,
      decoration: const BoxDecoration(
        color: Colors.orange,
      ),
      child: child,
    );
  }
}
