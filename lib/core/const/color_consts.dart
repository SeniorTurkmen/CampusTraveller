import 'package:flutter/material.dart';

class ColorConst {
  static const mainColor = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF9DD0FA),
      300: Color(0xFF83C0F1),
      400: Color(0xFF167BBE),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF0466A7),
      700: Color(0xFF02538A),
      800: Color(0xFF024D80),
      900: Color(0xFF00385E),
    },
  );

  static const int _bluePrimaryValue = 0xff0B76BD;
}
