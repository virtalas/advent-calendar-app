import 'dart:math';
import 'package:advent_calendar_app/utils.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:simple_animations/simple_animations.dart';
import 'constants.dart' as constants;
import 'package:snowfall/snowfall/snowflakes.dart';

class SnowmanInfo {
  double left;
  double bottom;
  double width;
  bool isMirrored;
  SnowmanInfo({
    required this.left,
    required this.bottom,
    required this.width,
    required this.isMirrored,
  });
}

class TextInfo {
  String firstRow;
  String secondRow;
  int letterDuration;
  TextStyle style;
  TextInfo({
    required this.firstRow,
    required this.secondRow,
    required this.letterDuration,
    required this.style,
  });
}

class CalendarDoorContent extends StatelessWidget {
  final bool isOpen;
  final bool isAnimatingDoor;
  final int doorNumber;
  final int maxDoorCount;
  final TextInfo? textInfo;
  final SnowmanInfo? snowmanInfo;
  final Widget child;
  const CalendarDoorContent({
    super.key,
    required this.isOpen,
    required this.isAnimatingDoor,
    required this.doorNumber,
    required this.maxDoorCount,
    required this.textInfo,
    required this.snowmanInfo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastDoor = doorNumber == maxDoorCount;
    final isDoorFullyClosed = isOpen && !isAnimatingDoor;
    final isDoorFullyOpenedOrClosing = (!isOpen && !isAnimatingDoor) || (isOpen && isAnimatingDoor);
    const alwaysShowDefaultImage = false;

    final imageNameForDoorNumber = 'assets/images/doors/$doorNumber.jpeg';
    final String imageName;
    if (alwaysShowDefaultImage) {
      imageName = 'assets/images/default.jpeg';
    } else {
      imageName = imageNameForDoorNumber;
    }

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
            imageName,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );

    final Widget animatedText;
    final int textAnimationDuration;

    if (textInfo != null && isDoorFullyOpenedOrClosing) {
      animatedText = Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.only(bottom: 30),
          child: AnimatedText(
            isDoorFullyClosed: isDoorFullyClosed,
            textInfo: textInfo!,
          ),
        ),
      );
      textAnimationDuration = (textInfo!.firstRow.length + textInfo!.secondRow.length) * textInfo!.letterDuration;
    } else {
      animatedText = Container();
      textAnimationDuration = 0;
    }

    final Widget santa;
    final santaDuration = textAnimationDuration + 8000;

    if (isLastDoor && !isDoorFullyClosed) {
      santa = Positioned.fill(
        child: Stack(
          children: [
            LoopAnimation(
              builder: (context, child, double value) {
                return Positioned(
                  top: 25,
                  left: value,
                  child: Image.asset(
                    'assets/images/santa.png',
                    scale: 2.4,
                  ),
                );
              },
              tween: Tween<double>(begin: -2600, end: 300),
              duration: Duration(milliseconds: santaDuration),
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
              width: snowmanInfo!.width,
              height: snowmanInfo!.width,
              child: Transform.scale(
                scaleX: snowmanInfo!.isMirrored ? -1 : 1,
                child: const RiveAnimation.asset(
                  'assets/images/snowman_shadow.riv',
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

    final Widget doorAndContent = Center(
      // For some reason this SizedBox is needed to display the Stack.
      child: SizedBox(
        width: constants.doorHeight,
        height: constants.doorHeight,
        child: Stack(
          children: [
            santa,
            snowman,
            Positioned.fill(
              child: ClippedSnowfall(
                isDoorFullyClosed: isDoorFullyClosed,
                doorNumber: doorNumber,
                maxDoorCount: maxDoorCount,
              ),
            ),
            Positioned.fill(child: animatedText),
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
          doorAndContent,
        ],
      ),
    );
  }
}

class ClippedSnowfall extends StatelessWidget {
  final bool isDoorFullyClosed;
  final int doorNumber;
  final int maxDoorCount;
  const ClippedSnowfall({
    super.key,
    required this.isDoorFullyClosed,
    required this.doorNumber,
    required this.maxDoorCount,
  });

  @override
  Widget build(BuildContext context) {
    if (isDoorFullyClosed) {
      return Container();
    } else {
      return ClipRect(
        child: Snowflakes(
          numberOfSnowflakes: numberOfSnowflakes(doorNumber, maxDoorCount),
          color: Colors.white,
          alpha: 120,
        ),
      );
    }
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
  final bool isDoorFullyClosed;
  final TextInfo textInfo;

  const AnimatedText({
    super.key,
    required this.isDoorFullyClosed,
    required this.textInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (isDoorFullyClosed) {
      return Container();
    } else {
      return SizedBox(
        width: 220,
        height: 70,
        child: DefaultTextStyle(
          style: textInfo.style,
          child: IgnorePointer(
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  '${textInfo.firstRow}\n${textInfo.secondRow}',
                  speed: Duration(milliseconds: textInfo.letterDuration),
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
    }
  }
}
