import 'package:flutter/material.dart';

// Colors
const Color calendarRed = Color(0xFFED240C);
const Color doorFrontColor = calendarRed;
const Color doorBackColor = Color(0xFFd01f0b);

// Size
const double doorHeight = 300;
const double crackLength = 1.5;
const double doorBorderWidth = 1.5;

// Animation
const double doorStartAngle = 0;
const double doorEndAngle = 2;
const double doorHalfOpenAngle = 1.5708; // 90 degrees in radians
const int doorAnimationDuration = 1000;
const Curve doorAnimationCurve = Curves.easeInOutQuad;
