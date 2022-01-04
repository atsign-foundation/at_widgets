import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  final String? heading, action;
  // ignore: use_key_in_widget_constructors
  const CustomHeading({this.heading, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        heading != null
            ? Text(heading!,
                style: Theme.of(context).brightness == Brightness.light
                    ? CustomTextStyles().black18
                    : CustomTextStyles().white18)
            : const SizedBox(),
        action != null
            ? Text(action!, style: CustomTextStyles().orange18)
            : const SizedBox()
      ],
    );
  }
}
