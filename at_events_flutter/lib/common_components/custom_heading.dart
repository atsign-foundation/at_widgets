import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  final String heading, action;
  CustomHeading({this.heading, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        heading != null
            ? Text(heading, style: Theme.of(context).textTheme.headline1)
            : SizedBox(),
        action != null
            ? Text(action, style: Theme.of(context).textTheme.headline2)
            : SizedBox()
      ],
    );
  }
}
