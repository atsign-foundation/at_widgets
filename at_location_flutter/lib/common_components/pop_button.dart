import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String label;
  final TextStyle? textStyle;
  PopButton({required this.label, this.textStyle});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Navigator.pop(context),
        child: Text(label, style: textStyle ?? CustomTextStyles().orange16));
  }
}
