import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class HomeTitleWidget extends StatelessWidget {
  const HomeTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            Images.icon,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            package: 'at_enrollment_app',
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome to',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.black,
                  ),
                ),
                TextSpan(
                  text: '\nSSHNP Desktop App',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Make your devices reachable while eliminating network attack surfaces & reducing administrative overhead.',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: ColorConstant.black,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
