import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class OTPWidget extends StatefulWidget {
  const OTPWidget({super.key});

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> with TickerProviderStateMixin {
  late AnimationController controller;
  String otp = '';

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        statusListener(status);
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          "OTP: ",
          style: const TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
        Text(
          otp,
          style: const TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
        SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(
            value: controller.value,
            strokeWidth: 7.0,
          ),
        ),
      ],
    );
  }

  void statusListener(status) {
    _getOTPFromServer().then((value) {
      setState(() {
        otp = value!;
      });
    });
  }

  Future<void> displayOTP() async {
    String? otp = await _getOTPFromServer();
    setState(() {
      this.otp = otp!;
    });
  }

  Future<String?> _getOTPFromServer() async {
    String? otp = await AtClientManager.getInstance()
        .atClient
        .getRemoteSecondary()
        ?.executeCommand('otp:get\n', auth: true);
    otp = otp?.replaceAll('data:', '');
    return otp;
  }
}
