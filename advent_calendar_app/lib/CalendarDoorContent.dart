import 'dart:math';

import 'package:advent_calendar_app/utils.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'constants.dart' as constants;
import 'package:snowfall/snowfall/snowflakes.dart';

class SnowmanInfo {
  double left;
  double bottom;
  bool isMirrored;
  SnowmanInfo(this.left, this.bottom, this.isMirrored);
}

class CalendarDoorContent extends StatelessWidget {
  final bool isOpen;
  final bool isAnimatingDoor;
  final int doorNumber;
  final int maxDoorCount;
  final SnowmanInfo? snowmanInfo;
  final Widget child;
  const CalendarDoorContent({
    super.key,
    required this.isOpen,
    required this.isAnimatingDoor,
    required this.doorNumber,
    required this.maxDoorCount,
    required this.snowmanInfo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastDoor = doorNumber == maxDoorCount;
    final isDoorFullyClosed = isOpen && !isAnimatingDoor;

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

    const firstRow = 'Hyvää joulua ja';
    const secondRow = ' onnellista uutta vuotta!';
    const letterDuration = 210;
    const textAnimationDuration =
        (firstRow.length + secondRow.length) * letterDuration;

    final Widget animatedText = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(bottom: 30),
        child: isLastDoor
            ? AnimatedText(
                isOpen: isOpen,
                firstRow: firstRow,
                secondRow: secondRow,
                letterDuration: const Duration(milliseconds: letterDuration),
              )
            : Container(),
      ),
    );

    const santaDuration = textAnimationDuration + 7000;

    final Widget santa;
    if (isLastDoor) {
      santa = Positioned.fill(
        child: Stack(
          children: [
            AnimatedPositioned(
              top: 25,
              left: isDoorFullyClosed ? -1500 : 300,
              duration: Duration(milliseconds: isDoorFullyClosed ? 0 : santaDuration),
              child: Image.asset(
                'assets/images/santa.png',
                scale: 2.4,
              ),
            ),
          ],
        ),
      );
    } else {
      santa = Container();
    }

    final Widget snowman;
    if (snowmanInfo != null && !isDoorFullyClosed) {
      // For some reason need to embed in another Stack, otherwise door gets clipped.
      snowman = Stack(
        children: [
          Positioned(
            bottom: snowmanInfo!.bottom,
            left: snowmanInfo!.left,
            child: SizedBox(
              width: 250,
              height: 250,
              child: Transform.scale(
                scaleX: snowmanInfo!.isMirrored ? -1 : 1,
                child: const RiveAnimation.asset(
                  'assets/images/snowman_rive.riv',
                  animations: ['Timeline 1'],
                ),
              ),
            ),
          )
        ],
      );
    } else {
      snowman = Container();
    }

    final Widget snowfallAndDoors = Center(
      // For some reason this SizedBox is needed to display the Stack.
      child: SizedBox(
        width: constants.doorHeight,
        height: constants.doorHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClippedSnowfall(
                isOpen: isOpen,
                doorNumber: doorNumber,
                maxDoorCount: maxDoorCount,
              ),
            ),
            Positioned.fill(child: animatedText),
            santa,
            snowman,
            Positioned.fill(child: child),
          ],
        ),
      ),
    );

    return SizedBox(
      height: constants.doorHeight,
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
  final int doorNumber;
  final int maxDoorCount;
  const ClippedSnowfall({
    super.key,
    required this.isOpen,
    required this.doorNumber,
    required this.maxDoorCount,
  });

  @override
  Widget build(BuildContext context) {
    return DoorOpeningProgressAnimationBuilder(
      isOpen: isOpen,
      builder: (BuildContext context, double progress, Widget? child) {
        if (progress > 0.1) {
          return ClipRect(
            child: Snowflakes(
              numberOfSnowflakes: numberOfSnowflakes(doorNumber, maxDoorCount),
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

  // Public for testing
  int numberOfSnowflakes(int doorNumber, int maxDoorCount) {
    if (maxDoorCount == 0) {
      return 0;
    }

    final int numberOfDoorsWithSnowflakes = (maxDoorCount * 0.85).round();
    const int maxNumberOfSnowflakes = 8;
    final int borderNumber = maxDoorCount - numberOfDoorsWithSnowflakes;

    if (doorNumber < borderNumber) {
      return 0;
    } else {
      final int aboveBorder = doorNumber - borderNumber;
      final int finalNumber = maxDoorCount - borderNumber;
      final double percentage = aboveBorder / finalNumber;
      return (maxNumberOfSnowflakes * _easeOutSine(percentage)).round();
    }
  }

  double _easeOutSine(double x) {
    return sin((x * 3.141) / 2);
  }
}

class AnimatedText extends StatelessWidget {
  final bool isOpen;
  final String firstRow;
  final String secondRow;
  final Duration letterDuration;
  const AnimatedText({
    super.key,
    required this.isOpen,
    required this.firstRow,
    required this.secondRow,
    required this.letterDuration,
  });

  @override
  Widget build(BuildContext context) {
    return DoorOpeningProgressAnimationBuilder(
      isOpen: isOpen,
      builder: (BuildContext context, double progress, Widget? child) {
        if (progress > 0.1) {
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
                      '$firstRow\n$secondRow',
                      speed: letterDuration,
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
