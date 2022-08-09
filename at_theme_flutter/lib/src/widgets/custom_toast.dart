import 'dart:io';

import 'package:flutter/material.dart';

class CustomToast {
  CustomToast._();
  static final CustomToast _instance = CustomToast._();
  factory CustomToast() => _instance;

  /// pass [isError] true to have a red bg, [isSuccess] true to have a green bg.
  void show(String message, BuildContext? context,
          {Color? bgColor,
          Color? textColor,
          double? toastWidth,
          double fontSize = 12,
          int duration = 3,
          bool isError = false,
          bool isSuccess = false}) =>
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor ?? Colors.white,
            ),
          ),
          duration: const Duration(milliseconds: 3000),
          elevation: 0,
          margin: toastWidth != null
              ? null
              : EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.2),
          backgroundColor: isError
              ? Colors.red
              : (isSuccess
                  ? Colors.green
                  : (bgColor ?? Colors.orange)),
          padding: const EdgeInsets.all(10),
          width: toastWidth,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(Platform.isAndroid ? 50 : 10)),
        ),
      );
}
