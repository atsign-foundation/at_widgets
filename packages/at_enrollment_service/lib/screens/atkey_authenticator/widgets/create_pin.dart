import 'package:at_enrollment_app/common_widgets/button.dart';
import 'package:at_enrollment_app/common_widgets/input_otp_field.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/manage_pin.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class CreatePin extends StatefulWidget {
  const CreatePin({super.key});

  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  String pin = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create a memorable PIN to use when onboarding your atSign in other apps.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PIN is used to prevent authentication spam',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorConstant.instructionTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 44),
                Center(
                  child: InputOTPField(onChange: (value) {
                    setState(() {
                      pin = value;
                    });
                  }),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Button(
                    width: double.infinity,
                    buttonText: 'Save PIN',
                    buttonColor: pin.length < 4
                        ? ColorConstant.disableColor
                        : ColorConstant.orange,
                    onPressed: () {
                      Navigator.pop(context);
                      showManagePin();
                    },
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 32,
          right: 28,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              Images.close,
              width: 16,
              height: 16,
              fit: BoxFit.cover,
              package: 'at_enrollment_app',
            ),
          ),
        ),
      ],
    );
  }

  void showManagePin() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ManagePin(pin: pin);
      },
    );
  }
}
