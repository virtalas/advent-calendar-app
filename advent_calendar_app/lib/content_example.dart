import 'package:flutter/material.dart';
import 'CalendarDoorContent.dart';

const int doorCount = 24;

const double shadowWidth = 0.5;
Map<int, TextInfo> textInfo = {
  24: TextInfo(
    firstRow: 'Hyvää joulua ja',
    secondRow: 'onnellista uutta vuotta!',
    letterDuration: 240,
    style: const TextStyle(
      fontSize: 30,
      fontFamily: 'greatVibes',
      color: Colors.red,
      shadows: [
        Shadow(
          // bottomLeft
          offset: Offset(-shadowWidth, -shadowWidth),
          color: Colors.white,
        ),
        Shadow(
          // bottomRight
          offset: Offset(shadowWidth, -shadowWidth),
          color: Colors.white,
        ),
        Shadow(
          // topRight
          offset: Offset(shadowWidth, shadowWidth),
          color: Colors.white,
        ),
        Shadow(
          // topLeft
          offset: Offset(-shadowWidth, shadowWidth),
          color: Colors.white,
        ),
      ],
    ),
  ),
};

Map<int, SnowmanInfo> snowmanInfo = {
  24: SnowmanInfo(left: 160, bottom: 30, width: 165, isMirrored: true),
  17: SnowmanInfo(left: -30, bottom: 0, width: 250, isMirrored: false),
  16: SnowmanInfo(left: 50, bottom: 0, width: 250, isMirrored: true),
};
