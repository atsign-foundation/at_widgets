import 'dart:async';

import 'package:at_enrollment_flutter/at_enrollment_flutter.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 16, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'OTP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                otpView()
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(right: 136),
              child: Text(
                'In case you forgot your PIN you can enter an OTP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget otpView() {
    return InkWell(
      onTap: () {
        EnrollmentServiceWrapper.getInstance().getOTPFromServer(refresh: true);
      },
      child: Container(
          width: 112,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorConstant.appBarColor,
            borderRadius: BorderRadius.circular(55),
          ),
          child: StreamBuilder<String>(
              stream:
                  EnrollmentServiceWrapper.getInstance().otpControllerStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ColorConstant.orange,
                      letterSpacing: 8,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              })),
    );
  }
}
