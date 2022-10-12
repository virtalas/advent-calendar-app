import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<int> days = <int>[12, 11, 10, 9];

    // MediaQuery.of(context).size.width

    return MaterialApp(
      home: Scaffold(
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 0),
          itemCount: days.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _toggleIsOpen(index);
              },
              child: CalendarDoor(day: days[index], isOpen: _openStates[index]),
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
    });
  }
}

class CalendarDoor extends StatelessWidget {
  final int day;
  final bool isOpen;

  const CalendarDoor({super.key, required this.day, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlipWidget(
          isFlipped: isOpen,
          child: CalendarHatchPair(text: '$day. luukku', isOpen: isOpen),
        ),
      ],
    );
  }
}

class CalendarHatchPair extends StatelessWidget {
  final String text;
  final bool isOpen;

  const CalendarHatchPair(
      {super.key, required this.text, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        border: Border.all(
          width: 1,
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class FlipWidget extends StatelessWidget {
  Widget child;
  final bool isFlipped;

  FlipWidget({super.key, required this.child, required this.isFlipped});

  @override
  Widget build(BuildContext context) {
    const double startAngle = 0;
    const double endAngle = 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutSine,
          tween: Tween<double>(
              begin: isFlipped ? endAngle : startAngle,
              end: isFlipped ? startAngle : endAngle),
          builder: (BuildContext context, double size, Widget? child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(size),
              alignment: Alignment.centerLeft,
              child: child,
            );
          },
          child: ClipRect(
              child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 0.5,
            child: child,
          )),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 1),
        ),
        ClipRect(
            child: Align(
          alignment: Alignment.centerRight,
          widthFactor: 0.5,
          child: child,
        )),
      ],
    );
  }
}
