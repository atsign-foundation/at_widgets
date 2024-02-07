import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class PrimaryDeviceRequirement extends StatelessWidget {
  const PrimaryDeviceRequirement({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 128,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Images.deviceIcon,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                package: 'at_enrollment_app',
              ),
              const SizedBox(height: 4),
              const Text(
                'Device',
                style: TextStyle(
                  color: ColorConstant.lightGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const Text(
                'iOS Device',
                style: TextStyle(
                  color: ColorConstant.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 128,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Images.appIcon,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                package: 'at_enrollment_app',
              ),
              const SizedBox(height: 4),
              const Text(
                'App',
                style: TextStyle(
                  color: ColorConstant.lightGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const Text(
                'SSHNP App',
                style: TextStyle(
                  color: ColorConstant.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
