import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'constants.dart' as constants;
import 'package:snowfall/snowfall/snowflakes.dart';

class CalendarDoorContent extends StatelessWidget {
  final bool isOpen;
  final bool isLastDoor;
  final Widget child;
  const CalendarDoorContent({super.key, required this.isOpen, required this.isLastDoor, required this.child});

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
            'assets/images/default.jpeg',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );

    final Widget animatedText = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(bottom: 30),
        child: isLastDoor ? AnimatedText(isOpen: isOpen) : Container(),
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
            Positioned.fill(child: animatedText),
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

class AnimatedText extends StatelessWidget {
  final bool isOpen;
  const AnimatedText({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    const Duration duration = Duration(milliseconds: 170);

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: constants.doorAnimationDuration),
      curve: constants.doorAnimationCurve,
      tween: Tween<double>(
        begin: isOpen ? 1 : 0,
        end: isOpen ? 0 : 1,
      ),
      builder: (BuildContext context, double opacity, Widget? child) {
        if (opacity > 0.1) {
          return SizedBox(
            width: 220,
            height: 70,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 30,
                fontFamily: 'greatVibes',
              ),
              child: IgnorePointer(
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Hyvää joulua ja\n onnellista uutta vuotta!',
                      speed: duration,
                      cursor: '',
                    ),
                  ],
                  pause: const Duration(milliseconds: 0),
                  displayFullTextOnTap: false,
                  repeatForever: false,
                  totalRepeatCount: 1,
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
