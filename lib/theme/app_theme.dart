import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.indigo,
    accentColor: Colors.indigoAccent,
    backgroundColor: Colors.white,
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.black87),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    accentColor: Colors.lightBlueAccent,
    backgroundColor: Colors.black,
    textTheme: TextTheme(
      headline6: TextStyle(color: Colors.white70),
    ),
  );
}