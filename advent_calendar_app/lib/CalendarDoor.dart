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
      width: constants.doorHeight - constants.crackLength,
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
  final bool isFlipped;
  final bool animated;
  final Function didAnimate;

  CalendarSingleDoor(
      {super.key,
        required this.text,
        required this.isFlipped,
        required this.animated,
        required this.didAnimate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: constants.doorHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder(
            duration: Duration(milliseconds: animated ? constants.doorAnimationDuration : 0),
            curve: Curves.easeInOutSine,
            tween: Tween<double>(
                begin: isFlipped ? constants.doorEndAngle : constants.doorStartAngle,
                end: isFlipped ? constants.doorStartAngle : constants.doorEndAngle),
            builder: (BuildContext context, double angle, Widget? child) {
              final bool isMoreThanHalfOpen = angle >= constants.doorHalfOpenAngle;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                alignment: Alignment.centerLeft,
                child: CalendarDoor(text: isMoreThanHalfOpen ? '' : text, isFront: !isMoreThanHalfOpen,),
              );
            },
            child: null,
            onEnd: () {
              didAnimate();
            },
          )
        ],
      ),
    );
  }
}

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder(
          duration: Duration(milliseconds: animated ? constants.doorAnimationDuration : 0),
          curve: Curves.easeInOutSine,
          tween: Tween<double>(
              begin: isFlipped ? constants.doorEndAngle : constants.doorStartAngle,
              end: isFlipped ? constants.doorStartAngle : constants.doorEndAngle),
          builder: (BuildContext context, double angle, Widget? child) {
            final bool isMoreThanHalfOpen = angle >= constants.doorHalfOpenAngle;
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
