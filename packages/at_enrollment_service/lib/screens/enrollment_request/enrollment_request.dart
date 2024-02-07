import 'dart:async';

import 'package:at_enrollment_app/screens/atkey_authenticator/key_authenticator_home_screen.dart';
import 'package:at_enrollment_app/screens/enrollment_request/widgets/primary_device_requirement.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class EnrollmentRequest extends StatefulWidget {
  const EnrollmentRequest({super.key});

  @override
  State<EnrollmentRequest> createState() => _EnrollmentRequestState();
}

class _EnrollmentRequestState extends State<EnrollmentRequest> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const KeyAuthenticatorHomeScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 20),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 32,
                  width: 32,
                  alignment: Alignment.center,
                  child: Image.asset(
                    Images.back,
                    height: 28,
                    width: 12,
                    package: 'at_enrollment_app',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'What\'s going on?',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 72),
              child: Text(
                'We have sent an enrolment request has been sent to the primary device',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            Center(
              child: Image.asset(
                Images.loading,
                width: 208,
                height: 188,
                fit: BoxFit.cover,
                package: 'at_enrollment_app',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              color: ColorConstant.grey,
              child: const PrimaryDeviceRequirement(),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 112),
              child: Text(
                'Wondering where to find the request?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorConstant.lightGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Image.asset(
                Images.requestInstruction,
                fit: BoxFit.cover,
                package: 'at_enrollment_app',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
