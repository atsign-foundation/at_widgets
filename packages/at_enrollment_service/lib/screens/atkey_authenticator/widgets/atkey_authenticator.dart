import 'dart:async';
import 'dart:convert';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/common_widgets/button.dart';
import 'package:at_enrollment_app/models/enrollment.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/create_pin_card.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/otp_card.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/create_pin.dart';
import 'package:at_enrollment_app/screens/enrollment_request_card.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class AtKeyAuthenticator extends StatefulWidget {
  const AtKeyAuthenticator({super.key});

  @override
  State<AtKeyAuthenticator> createState() => _AtKeyAuthenticatorState();
}

class _AtKeyAuthenticatorState extends State<AtKeyAuthenticator> {
  String currentAtsign = '';
  String otp = '';
  Timer? timer;

  @override
  void initState() {
    // currentAtsign =
    //     AtClientManager.getInstance().atClient.getCurrentAtSign() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 52),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Button(
                width: double.infinity,
                height: 48,
                buttonText: 'Primary Device',
                titleStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                buttonColor: ColorConstant.gray,
                prefix: Container(
                  height: 36,
                  width: 36,
                  margin: const EdgeInsets.only(right: 4),
                  alignment: Alignment.center,
                  child: Image.asset(
                    Images.device,
                    width: 16,
                    height: 24,
                    fit: BoxFit.cover,
                    package: 'at_enrollment_app',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'The app on this device will be used as an authenticator for all future apps & devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorConstant.instructionTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Button(
              width: double.infinity,
              buttonText: 'Backup your atsign',
              buttonColor: ColorConstant.orange,
              onPressed: () {},
              titleStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 15,
              ),
              prefix: Container(
                height: 28,
                width: 24,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 20),
                child: Image.asset(
                  Images.backup,
                  width: 16,
                  height: 24,
                  package: 'at_enrollment_app',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'If you lose access to the primary device, you will need the key to recover data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorConstant.instructionTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CreatePinCard(),
            const SizedBox(height: 24),
            const OtpCard(),
            const SizedBox(height: 24),
            InkWell(
              child: Container(
                padding: const EdgeInsets.fromLTRB(36, 12, 16, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(41),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'View all active authentications ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      child: Image.asset(
                        Images.forward,
                        width: 8,
                        height: 16,
                        package: 'at_enrollment_app',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 72),
            // StreamBuilder<AtNotification>(
            //   stream: fetchEnrollmentNotifications(),
            //   builder: (BuildContext context,
            //       AsyncSnapshot<AtNotification> snapshot) {
            //     if (snapshot.hasData) {
            //       EnrollmentData enrollmentData = EnrollmentData(
            //           snapshot.data!.from,
            //           '${snapshot.data!.key}${snapshot.data!.from}',
            //           jsonDecode(snapshot.data!.value!)[
            //               'encryptedApkamSymmetricKey']);
            //
            //       print('enrollmentData : ${snapshot.data!}');
            //
            //       return EnrollmentRequestCard(
            //         enrollmentData: enrollmentData,
            //       );
            //     } else if (snapshot.hasError) {
            //       // Handle error case
            //       return Text('Error: ${snapshot.error}');
            //     } else {
            //       // Handle loading or initial state
            //       return const Center(
            //         child: Column(
            //           children: [
            //             Text('No request'),
            //             Text('At the moment'),
            //           ],
            //         ),
            //       );
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }

// Stream<AtNotification> fetchEnrollmentNotifications() {
//   Stream<AtNotification> notificationStream = AtClientManager.getInstance()
//       .atClient
//       .notificationService
//       .subscribe(regex: '__manage');
//   return notificationStream;
// }
}
