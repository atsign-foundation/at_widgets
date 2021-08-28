import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  PopButton({required this.label, this.textStyle, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        child: Text(label, style: textStyle ?? CustomTextStyles().orange16));
  }
}
