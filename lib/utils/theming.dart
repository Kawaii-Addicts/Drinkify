import 'package:flutter/material.dart';

class Theming {
  Theming._();

  static const Color primaryColor = Color(0xFF0EB1D2);
  static const Color bgColor = Color.fromARGB(255, 1, 25, 54);
  static const Color whiteTone = Color.fromARGB(255, 247, 244, 243);
}

class Styles {
  Styles._();
  
  static const navBarText = TextStyle(
    color: Theming.whiteTone,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const categoryText = TextStyle(
    color: Theming.whiteTone,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final smallTextButton = TextStyle(
    color: Theming.whiteTone.withOpacity(0.7),
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const dateBoxText = TextStyle(
    color: Theming.whiteTone,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static final emptyListText = TextStyle(
    color: Theming.whiteTone.withOpacity(0.7),
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const hintTextSearchBar = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const dateTextSelected = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 24,
    color: Theming.primaryColor,
  );

  static const dateTextUnselected = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Theming.whiteTone,
  );

}