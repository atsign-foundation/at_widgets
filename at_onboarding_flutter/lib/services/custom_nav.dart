import 'package:flutter/material.dart';

class CustomNav {
  static final CustomNav _singleton = CustomNav._internal();

  CustomNav._internal();
  factory CustomNav() {
    return _singleton;
  }

  void push(Widget? widget, BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute<Widget>(
              builder: (BuildContext context) => widget!));
    });
  }

  void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
