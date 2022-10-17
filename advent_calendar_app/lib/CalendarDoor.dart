import 'package:flutter/material.dart';
import 'constants.dart' as constants;

// enum DoorType {
//   single,
//   double
// }

class CalendarDoor extends StatelessWidget {
  final String text;
  final bool isFront;

  const CalendarDoor({super.key, required this.text, required this.isFront});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: constants.doorHeight,
      height: constants.doorHeight,
      decoration: BoxDecoration(
        color: isFront ? constants.doorFrontColor : constants.doorBackColor,
        border: Border.all(
          width: constants.doorBorderWidth,
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

class CalendarSingleDoor extends StatelessWidget {
  String text;
  final bool isOpen;
  final bool animated;
  final Function didAnimate;

  CalendarSingleDoor({
    super.key,
    required this.text,
    required this.isOpen,
    required this.animated,
    required this.didAnimate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: constants.doorHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder(
            duration: Duration(
                milliseconds: animated ? constants.doorAnimationDuration : 0),
            curve: constants.doorAnimationCurve,
            tween: Tween<double>(
              begin: isOpen ? constants.doorEndAngle : constants.doorStartAngle,
              end: isOpen ? constants.doorStartAngle : constants.doorEndAngle,
            ),
            builder: (BuildContext context, double angle, Widget? child) {
              final bool isMoreThanHalfOpen =
                  angle >= constants.doorHalfOpenAngle;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                alignment: Alignment.centerLeft,
                child: CalendarDoor(
                  text: isMoreThanHalfOpen ? '' : text,
                  isFront: !isMoreThanHalfOpen,
                ),
              );
            },
            child: null,
            onEnd: () {
              didAnimate();
            },
          ),
        ],
      ),
    );
  }
}

class CalendarDoubleDoor extends StatelessWidget {
  String text;
  final bool isOpen;
  final bool animated;
  final Function didAnimate;

  CalendarDoubleDoor({
    super.key,
    required this.text,
    required this.isOpen,
    required this.animated,
    required this.didAnimate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarHalfDoor(
          text: text,
          isOpen: isOpen,
          animated: animated,
          didAnimate: didAnimate,
          isOnLeft: true,
        ),
        const SizedBox(
          width: constants.crackLength,
        ),
        CalendarHalfDoor(
          text: text,
          isOpen: isOpen,
          animated: animated,
          didAnimate: null,
          isOnLeft: false,
        ),
      ],
    );
  }
}

class CalendarHalfDoor extends StatelessWidget {
  String text;
  final bool isOpen;
  final bool animated;
  final Function? didAnimate;
  final bool isOnLeft;

  CalendarHalfDoor({
    super.key,
    required this.text,
    required this.isOpen,
    required this.animated,
    required this.didAnimate,
    required this.isOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final double endAngle = constants.doorEndAngle * (isOnLeft ? 1 : -1);

    return TweenAnimationBuilder(
      duration: Duration(
        milliseconds: animated ? constants.doorAnimationDuration : 0,
      ),
      curve: constants.doorAnimationCurve,
      tween: Tween<double>(
        begin: isOpen ? endAngle : constants.doorStartAngle,
        end: isOpen ? constants.doorStartAngle : endAngle,
      ),
      builder: (BuildContext context, double angle, Widget? child) {
        final bool isMoreThanHalfOpen;
        if (isOnLeft) {
          isMoreThanHalfOpen = angle >= constants.doorHalfOpenAngle;
        } else {
          isMoreThanHalfOpen = angle <= constants.doorHalfOpenAngle * -1;
        }

        const double halfDoorWidth =
            (constants.doorHeight / 2) - (constants.crackLength / 2);
        const double widthFactor = halfDoorWidth / constants.doorHeight;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: isOnLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: ClipRect(
            child: Align(
              alignment:
                  isOnLeft ? Alignment.centerLeft : Alignment.centerRight,
              widthFactor: widthFactor,
              child: CalendarDoor(
                text: isMoreThanHalfOpen ? '' : text,
                isFront: !isMoreThanHalfOpen,
              ),
            ),
          ),
        );
      },
      child: null,
      onEnd: () {
        didAnimate?.call();
      },
    );
  }
}
