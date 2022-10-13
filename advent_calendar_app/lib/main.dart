import 'package:flutter/material.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CalendarDoorContent(
          child: CalendarDoubleDoor(
            isFlipped: isOpen,
            text: '$day. luukku',
            animated: animated,
            didAnimate: didAnimate,
          ),
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

// TODO: CalendarSingleDoor

class CalendarDoubleDoor extends StatelessWidget {
  String text;
  final bool isFlipped;
  final bool animated;
  final Function didAnimate;

  CalendarDoubleDoor(
      {super.key,
      required this.text,
      required this.isFlipped,
      required this.animated,
      required this.didAnimate});

  @override
  Widget build(BuildContext context) {
    const double startAngle = 0;
    const double endAngle = 2;
    const double halfOpenAngle = 1.5708; // 90 degrees in radians
    const int duration = 1000;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder(
          duration: Duration(milliseconds: animated ? duration : 0),
          curve: Curves.easeInOutSine,
          tween: Tween<double>(
              begin: isFlipped ? endAngle : startAngle,
              end: isFlipped ? startAngle : endAngle),
          builder: (BuildContext context, double angle, Widget? child) {
            final bool isMoreThanHalfOpen = angle >= halfOpenAngle;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              alignment: Alignment.centerLeft,
              child: ClipRect(
                  child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5,
                child: CalendarDoor(text: isMoreThanHalfOpen ? '' : text, isFront: !isMoreThanHalfOpen,),
              )),
            );
          },
          child: null,
          onEnd: () {
            didAnimate();
          },
        ),
        const SizedBox(
          width: constants.crackLength,
        ),
        ClipRect(
            child: Align(
          alignment: Alignment.centerRight,
          widthFactor: 0.5,
          child: CalendarDoor(
            text: text,
            isFront: true,
          ),
        )),
      ],
    );
  }
}

class CalendarDoor extends StatelessWidget {
  final String text;
  final bool isFront;

  const CalendarDoor({super.key, required this.text, required this.isFront});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: constants.doorHeight,
      decoration: BoxDecoration(
        color: isFront ? constants.doorFrontColor : constants.doorBackColor,
        border: Border.all(
          width: 0.5,
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }
}
