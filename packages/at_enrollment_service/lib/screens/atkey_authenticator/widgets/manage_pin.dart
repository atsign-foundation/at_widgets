import 'package:at_enrollment_app/common_widgets/button.dart';
import 'package:at_enrollment_app/common_widgets/input_otp_field.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class ManagePin extends StatefulWidget {
  final String pin;

  const ManagePin({
    super.key,
    required this.pin,
  });

  @override
  State<ManagePin> createState() => _ManagePinState();
}

class _ManagePinState extends State<ManagePin> {
  late String pin = widget.pin;
  bool isEditing = false;

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
                  'Manage PIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Use this PIN to speed up your onboarding experience across apps.',
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
                buildManagePinWidget(),
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

  Widget buildManagePinWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: isEditing
          ? [
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
                  borderRadius: 80,
                  width: double.infinity,
                  buttonText: 'Save PIN',
                  buttonColor: pin.length < 4
                      ? ColorConstant.disableColor
                      : ColorConstant.orange,
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Button(
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                      pin = widget.pin;
                    });
                  },
                  borderRadius: 80,
                  width: double.infinity,
                  buttonText: ''
                      'Cancel',
                  buttonColor: Colors.transparent,
                  titleStyle: const TextStyle(
                    color: ColorConstant.denyColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  border: Border.all(
                    color: ColorConstant.denyColor,
                    width: 2,
                  ),
                ),
              ),
            ]
          : [
              const SizedBox(height: 32),
              Center(
                child: Text(
                  pin,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Button(
                  width: double.infinity,
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                      pin = '';
                    });
                  },
                  buttonText: 'Change PIN',
                  buttonColor: ColorConstant.timerColor,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                  borderRadius: 34,
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Image.asset(
                      Images.edit,
                      height: 20,
                      width: 20,
                      fit: BoxFit.cover,
                      package: 'at_enrollment_app',
                    ),
                  ),
                ),
              )
            ],
    );
  }
}
