import 'package:at_dude_flutter/dude_theme.dart';
import 'package:flutter/material.dart';

class SnackBars extends StatelessWidget {
  const SnackBars({Key? key}) : super(key: key);
  static void errorSnackBar(
      {required String content, required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  static void notificationSnackBar(
      {required String content, required BuildContext context}) {
    Duration duration = const Duration(seconds: 3);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      duration: duration,
      backgroundColor: kAlternativeColor,

    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
