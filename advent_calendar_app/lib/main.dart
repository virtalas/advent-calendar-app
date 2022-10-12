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
            child: CalendarHatchPair(
                text: '${day}. luukku', isOpen: isOpen)),
      ],
    );
  }
}

class CalendarHatchPair extends StatelessWidget {
  final String text;
  final bool isOpen;

  const CalendarHatchPair(
      {super.key,
      required this.text,
      required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isOpen ? 250 : 200,
      height: 400,
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

  FlipWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRect(
            child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 0.5,
          child: child,
        )),
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
