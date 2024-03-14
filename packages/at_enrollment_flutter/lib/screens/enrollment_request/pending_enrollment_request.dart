import 'dart:async';
import 'package:at_enrollment_flutter/at_enrollment_flutter.dart';
import 'package:at_enrollment_flutter/screens/enrollment_request/widgets/primary_device_requirement.dart';
import 'package:at_enrollment_flutter/screens/key_authenticator_home_screen.dart';
import 'package:at_enrollment_flutter/utils/assets.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class PendingEnrollmentRequestScreens extends StatefulWidget {
  final EnrollmentInfo enrollmentInfo;

  const PendingEnrollmentRequestScreens({
    super.key,
    required this.enrollmentInfo,
  });

  @override
  State<PendingEnrollmentRequestScreens> createState() =>
      _PendingEnrollmentRequestScreensState();
}

class _PendingEnrollmentRequestScreensState
    extends State<PendingEnrollmentRequestScreens> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // checkForEnrollmentData() {
  //   var enrolmentController =
  //       EnrollmentApp.getInstance().enrollmentStatusController;
  //   enrolmentController.stream.listen((event) {
  //     if (event.isNotEmpty) {}
  //   });
  // }

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
                    package: 'at_enrollment_flutter',
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
                package: 'at_enrollment_flutter',
              ),
            ),
            const SizedBox(height: 20),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                color: ColorConstant.grey,
                child: Text('${widget.enrollmentInfo.namespace}')
                // const PrimaryDeviceRequirement(),
                ),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                color: ColorConstant.grey,
                child: Text('${widget.enrollmentInfo.enrollmentId}')),
            Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                color: ColorConstant.grey,
                child: Text('status')),
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
                package: 'at_enrollment_flutter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
