import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
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
    _getOTPFromServer();

    timer = Timer.periodic(const Duration(minutes: 1), (t) {
      _getOTPFromServer();
    });
    super.initState();
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
            Text(
              otp,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.orange,
                  letterSpacing: 7),
            ),
          ],
        ));
  }
}
