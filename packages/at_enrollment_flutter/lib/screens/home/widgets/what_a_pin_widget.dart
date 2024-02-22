import 'package:at_enrollment_flutter/common_widgets/button.dart';
import 'package:at_enrollment_flutter/screens/home/widgets/pair_atsign_widget.dart';
import 'package:at_enrollment_flutter/utils/assets.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class WhatAPinWidget extends StatelessWidget {
  const WhatAPinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(40),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What\'s a PIN?',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Check your ',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: ColorConstant.black,
                      ),
                    ),
                    TextSpan(
                      text: 'primary device,',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: ColorConstant.black,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' the first app successfully onboarded using your atSign',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: ColorConstant.black,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Find the initial PIN under Settings → atSign Authenticator -> PIN',
                style: TextStyle(
                  color: ColorConstant.lightGrey,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  Images.instructor,
                  width: 308,
                  height: 72,
                  fit: BoxFit.cover,
                  package: 'at_enrollment_flutter',
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Button(
                  borderRadius: 46,
                  buttonColor: ColorConstant.orange,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  buttonText: 'Okay, I got it!',
                  width: double.infinity,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Haven’t set up a PIN or',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(40),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return const PairAtSignWidget(atSign: '');
                          },
                        );
                      },
                      child: const Text(
                        'Forgot Pin?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
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
              package: 'at_enrollment_flutter',
            ),
          ),
        ),
      ],
    );
  }
}
