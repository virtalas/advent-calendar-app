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
    height: 70,
  ),
};

Map<int, SnowInfo> snowflakeInfo = {
  24: SnowInfo(numberOfSnowflakes: 4),
  23: SnowInfo(numberOfSnowflakes: 3),
  22: SnowInfo(numberOfSnowflakes: 3),
  21: SnowInfo(numberOfSnowflakes: 2),
  20: SnowInfo(numberOfSnowflakes: 0),
  19: SnowInfo(numberOfSnowflakes: 3),
  18: SnowInfo(numberOfSnowflakes: 0),
  17: SnowInfo(numberOfSnowflakes: 0),
  16: SnowInfo(numberOfSnowflakes: 0),
  15: SnowInfo(numberOfSnowflakes: 0),
  14: SnowInfo(numberOfSnowflakes: 0),
  13: SnowInfo(numberOfSnowflakes: 0),
  12: SnowInfo(numberOfSnowflakes: 0),
  11: SnowInfo(numberOfSnowflakes: 0),
  10: SnowInfo(numberOfSnowflakes: 0),
  9: SnowInfo(numberOfSnowflakes: 3),
  8: SnowInfo(numberOfSnowflakes: 2),
  7: SnowInfo(numberOfSnowflakes: 2),
  6: SnowInfo(numberOfSnowflakes: 0),
  5: SnowInfo(numberOfSnowflakes: 2),
  4: SnowInfo(numberOfSnowflakes: 3),
  3: SnowInfo(numberOfSnowflakes: 1),
  2: SnowInfo(numberOfSnowflakes: 1),
  1: SnowInfo(numberOfSnowflakes: 0),
};

Map<int, SnowmanInfo> snowmanInfo = {
  24: SnowmanInfo(left: 160, bottom: 30, width: 165, isMirrored: true),
  17: SnowmanInfo(left: -30, bottom: 0, width: 250, isMirrored: false),
  16: SnowmanInfo(left: 50, bottom: 0, width: 250, isMirrored: true),
};
