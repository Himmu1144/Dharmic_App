import 'package:dharmic/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // initially the theme is light
  ThemeData _themeData = darkMode;

  // get method to get theme from anywhere in the code
  ThemeData get themeData => _themeData;

  // get  method to check whether our theme is darkMode or not
  bool get isDarkMode => _themeData == darkMode;

  // setter method to set the new theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // helps to toggle between the light and dark
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
