import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
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
    // _getOTPFromServer();

    // timer = Timer.periodic(const Duration(minutes: 1), (t) {
    //   _getOTPFromServer();
    // });
    super.initState();
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

  Future<String?> _getOTPFromServer() async {
    String? tempOtp = await AtClientManager.getInstance()
        .atClient
        .getRemoteSecondary()
        ?.executeCommand('otp:get\n', auth: true);
    tempOtp = tempOtp?.replaceAll('data:', '');
    print('otp: $tempOtp');
    if (mounted) {
      setState(() {
        otp = tempOtp ?? '';
      });
    }
    return otp;
  }

  Widget otpView() {
    return Container(
        width: 112,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorConstant.appBarColor,
          borderRadius: BorderRadius.circular(55),
        ),
        child: Text(
          otp,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w500,
            color: ColorConstant.orange,
            letterSpacing: 8,
          ),
        ));
  }
}
