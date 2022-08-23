
import 'dart:io';

import 'package:flutter/material.dart';

class CustomToast {
  /// pass [isError] true to have a red bg, [isSuccess] true to have a green bg.
  static void show(String message, BuildContext context,
          {Color? bgColor,
          Color? textColor,
          double? toastWidth,
          double fontSize = 12,
          int duration = 3,
          double gravity = 10.0,
          bool isError = false,
          bool isSuccess = false}) {
            assert(!(isError && isSuccess), 'Both isError and isSuccess cannot be true');
            assert(gravity >= 0, 'gravity cannot be less than 0');            
              ScaffoldMessenger.of(context).showSnackBar(
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
                  horizontal: MediaQuery.of(context).size.width * 0.2, vertical: gravity),
          backgroundColor: isError
              ? Colors.red
              : (isSuccess
                  ? Colors.green
                  : (bgColor ?? const Color(0xA9FFFFFF))),
          padding: const EdgeInsets.all(10),
          width: toastWidth,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(Platform.isAndroid ? 50 : 10)),
                  ),
                );
            }
}
