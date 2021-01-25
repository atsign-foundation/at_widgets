import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CustomToast {
  CustomToast._();
  static CustomToast _instance = CustomToast._();
  factory CustomToast() => _instance;

  show(String text, BuildContext context,
      {Color bgColor, Color textColor, int duration = 3}) {
    Toast.show(
      text,
      context,
      duration: duration,
      gravity: Toast.BOTTOM,
      backgroundColor: bgColor ?? AllColors().ORANGE,
      textColor: textColor ?? Colors.white,
    );
  }
}
