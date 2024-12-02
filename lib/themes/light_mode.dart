import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'KhmerFont',
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFf6f6ff),
    // primary: Color(0xFF7a6bbc),
    primary: Color.fromRGBO(18, 63, 140, 1),
    // secondary: Colors.orange.shade400,
    // tertiary: Colors.grey.shade100,
    inversePrimary: Color.fromARGB(255, 188, 173, 255),
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    // background: Colors.grey.shade800,
    // primary: Colors.blue.shade400,
    // secondary: Color(0xFFFFA726),
    // tertiary: Colors.grey.shade100,
    // inversePrimary: Colors.grey.shade700,
  )
);