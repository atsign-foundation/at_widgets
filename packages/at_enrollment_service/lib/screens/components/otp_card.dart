import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_enrollment_app/services/enrollment_service.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class OtpCard extends StatefulWidget {
  const OtpCard({super.key});

  @override
  State<OtpCard> createState() => _OtpCardState();
}

class _OtpCardState extends State<OtpCard> {
  String otp = '';
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  // fetchOtp() async {
  // EnrollmentService.getInstance().getOTPFromServer();

  // timer = Timer.periodic(const Duration(minutes: 1), (t) async {
  //   var tempOtp = await EnrollmentService.getInstance().getOTPFromServer();
  //   otp = tempOtp ?? '';
  // });
  // }

  @override
  void didChangeDependencies() {
    EnrollmentService.getInstance().getOTPFromServer();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'OTP',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                otpView()
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'In case you forgot your PIN, you can enter an OTP',
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget otpView() {
    return Container(
        width: 140,
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: ColorConstant.orange.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<String>(
                stream: EnrollmentService.getInstance().otpControllerStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      snapshot.data as String,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorConstant.orange,
                          letterSpacing: 7),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                })
          ],
        ));
  }
}
