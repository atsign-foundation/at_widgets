import 'package:at_enrollment_app/common_widgets/input_field.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class EnterPinWidget extends StatelessWidget {
  final Function(String) onChange;
  final Function() onSubmit;

  const EnterPinWidget({
    super.key,
    required this.onChange,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return InputField(
      hintText: 'Enter your Pin',
      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: ColorConstant.lightGrey,
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        color: ColorConstant.black,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      isNumpad: true,
      maxLength: 6,
      isCenter: true,
      prefix: Image.asset(
        Images.pin,
        width: 68,
        height: 20,
        package: 'at_enrollment_app',
      ),
      suffix: InkWell(
        onTap: () {
          onSubmit.call();
        },
        child: Image.asset(
          Images.enter,
          width: 28,
          height: 20,
          fit: BoxFit.cover,
          package: 'at_enrollment_app',
        ),
      ),
      onChange: onChange,
    );
  }
}
