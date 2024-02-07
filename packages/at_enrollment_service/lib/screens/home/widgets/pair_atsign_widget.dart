import 'package:at_enrollment_app/common_widgets/button.dart';
import 'package:at_enrollment_app/common_widgets/input_otp_field.dart';
import 'package:at_enrollment_app/screens/generating_atkey/generating_atkey.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class PairAtSignWidget extends StatefulWidget {
  final String atSign;

  const PairAtSignWidget({
    super.key,
    required this.atSign,
  });

  @override
  State<PairAtSignWidget> createState() => _PairAtSignWidgetState();
}

class _PairAtSignWidgetState extends State<PairAtSignWidget> {
  String otp = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(40),
            ),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pair atSign',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'It seems you have not yet activated this atSign',
                        style: TextStyle(
                          color: ColorConstant.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ve sent a one-time passcode via the registered email associated with @${widget.atSign}.',
                        style: const TextStyle(
                          color: ColorConstant.lightGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: InputOTPField(
                          onChange: (value) {
                            setState(() {
                              otp = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Button(
                          onPressed: () {
                            if (otp.length == 4) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const GeneratingYourAtKey(),
                                ),
                              );
                            }
                          },
                          buttonText: 'Verify & Onboard',
                          buttonColor: otp.length < 4
                              ? ColorConstant.disableButtonColor
                              : ColorConstant.orange,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.fromLTRB(48, 12, 48, 40),
                  decoration: const BoxDecoration(
                    color: ColorConstant.pinFillColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Please check both your inbox and spam. If it has been longer than 5 minutes, please contact support.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorConstant.lightGrey,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Button(
                          buttonText: 'Resend Code',
                          buttonColor: Colors.transparent,
                          width: double.infinity,
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.black,
                            fontSize: 12,
                          ),
                          borderRadius: 50,
                          height: 44,
                          border: Border.all(
                            color: ColorConstant.black,
                            width: 2,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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
}
