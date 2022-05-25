import 'package:flutter/material.dart';

class DudeTimer extends StatelessWidget {
  final int rawTime;
  const DudeTimer({required this.rawTime, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String time = Duration(milliseconds: rawTime)
            .toString()
            .split('.')
            .sublist(0)[0]
            .replaceRange(0, 2, '') +
        's';
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(
          Icons.timer_outlined,
          size: 40,
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ],
    ));
  }
}
