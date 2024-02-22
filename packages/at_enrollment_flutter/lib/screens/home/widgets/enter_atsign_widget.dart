import 'package:at_enrollment_flutter/common_widgets/input_field.dart';
import 'package:at_enrollment_flutter/utils/assets.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class EnterAtSignWidget extends StatelessWidget {
  final Function(String) onChange;
  final bool isTooltipEnabled;
  final bool isAtSignEmpty;
  final Function() onShowTooltip;

  const EnterAtSignWidget({
    super.key,
    required this.onChange,
    required this.isTooltipEnabled,
    required this.isAtSignEmpty,
    required this.onShowTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return InputField(
      hintText: 'Enter your atSign',
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      borderRadius: BorderRadius.circular(40),
      prefix: Image.asset(
        Images.atImage,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        package: 'at_enrollment_flutter',
      ),
      hintStyle: const TextStyle(
        color: ColorConstant.lightGrey,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        color: ColorConstant.black,
      ),
      suffix: isAtSignEmpty
          ? InkWell(
              onTap: () {
                onShowTooltip.call();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isTooltipEnabled
                      ? const Color(0xFFFFEFEC)
                      : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.question_mark,
                  size: 10,
                  color: isTooltipEnabled ? Colors.red : Colors.grey,
                ),
              ),
            )
          : null,
      onChange: onChange,
    );
  }
}
