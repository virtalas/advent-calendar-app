import 'package:flutter/material.dart';
import 'constants.dart' as constants;
import 'package:snowfall/snowfall/snowflakes.dart';

class CalendarDoorContent extends StatelessWidget {
  Widget child;
  bool isOpen;
  CalendarDoorContent({super.key, required this.isOpen, required this.child});

  @override
  Widget build(BuildContext context) {
    final Widget image = SizedBox(
      height: constants.doorHeight,
      width: constants.doorHeight,
      child: ClipRect(
        child: AnimatedScale(
          scale: isOpen ? 1 : 1.1,
          curve: Curves.easeInOutSine,
          duration:
              const Duration(milliseconds: constants.doorAnimationDuration),
          child: Image.asset(
            'assets/default.jpeg',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );

    final Widget snowfallAndDoors = Center(
      // For some reason this SizedBox is needed to display the Stack.
      child: SizedBox(
        width: constants.doorHeight,
        height: constants.doorHeight,
        child: Stack(
          children: [
            Positioned.fill(child: ClippedSnowfall(isOpen: isOpen)),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );

    return Container(
      height: constants.doorHeight,
      decoration: const BoxDecoration(
        color: Colors.orange,
      ),
      child: Stack(
        children: [
          image,
          snowfallAndDoors,
        ],
      ),
    );
  }
}

class ClippedSnowfall extends StatelessWidget {
  final bool isOpen;
  const ClippedSnowfall({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final bool isOpening = !isOpen;

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: constants.doorAnimationDuration),
      curve: constants.doorAnimationCurve,
      tween: Tween<double>(
        begin: isOpen ? 1 : 0,
        end: isOpen ? 0 : 1,
      ),
      builder: (BuildContext context, double opacity, Widget? child) {
        if (opacity > 0.1) {
          return const ClipRect(
            child: Snowflakes(
              numberOfSnowflakes: 8,
              color: Colors.white,
              alpha: 120,
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
