import 'package:flutter/cupertino.dart';
import 'constants.dart' as constants;

// https://stackoverflow.com/a/67679455
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

class DoorOpeningProgressAnimationBuilder extends StatelessWidget {
  final bool isOpen;
  final Function builder;
  const DoorOpeningProgressAnimationBuilder({super.key, required this.isOpen, required this.builder});

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
      builder: (BuildContext context, double progress, Widget? child) {
        return builder(context, progress, child);
      },
    );
  }
}
