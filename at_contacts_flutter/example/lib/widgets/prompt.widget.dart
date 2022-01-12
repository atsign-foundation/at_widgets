import 'package:flutter/material.dart';

class Dialogs {
  static Future<dynamic> customDialog(
      BuildContext context, String title, String body, VoidCallback? onPressed,
      {required String? buttonText, Widget? childContent}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (childContent != null) const SizedBox(height: 10),
            if (childContent != null) childContent,
            if (childContent != null) const SizedBox(height: 10),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: Text(
              buttonText!,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.blue[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
