import 'package:at_enrollment_flutter/common_widgets/button.dart';
import 'package:at_enrollment_flutter/screens/home/widgets/what_a_pin_widget.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final bool isAtSignEmpty;

  const ActionButtonWidget({
    super.key,
    required this.isAtSignEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return isAtSignEmpty
        ? Button(
            borderRadius: 40,
            buttonColor: ColorConstant.orange,
            titleStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            buttonText: 'Create an Account for Free',
            width: double.infinity,
            onPressed: () {},
          )
        : InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                builder: (BuildContext context) {
                  return const WhatAPinWidget();
                },
              );
            },
            child: const Center(
              child: Text(
                "What's a PIN?",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: ColorConstant.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          );
  }
}
