import 'dart:async';
import 'dart:convert';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/models/enrollment.dart';
import 'package:at_enrollment_app/screens/components/create_pin_card.dart';
import 'package:at_enrollment_app/screens/components/otp_card.dart';
import 'package:at_enrollment_app/screens/create_pin.dart';
import 'package:at_enrollment_app/screens/enrollment_request_card.dart';
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
    currentAtsign =
        AtClientManager.getInstance().atClient.getCurrentAtSign() ?? '';
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: ColorConstant.lightGrey.withOpacity(0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Center(
                  child: Text(
                    'Primary Device',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'The app on this device will be used as an authenticator for all future apps & devices.',
                  style:
                      TextStyle(fontSize: 13, color: ColorConstant.lightGrey),
                ),
              ),
              const SizedBox(height: 45),
              CustomButton(
                width: double.infinity,
                buttonText: 'Backup your primary atKey',
                fontColor: Colors.white,
                buttonColor: ColorConstant.orange,
                onPressed: () {
                  setState(() {});
                },
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Recommend to store a local backup of your primary atKey as if you lose access to the primary device, you will need the key to recover data.',
                  style:
                      TextStyle(fontSize: 13, color: ColorConstant.lightGrey),
                ),
              ),
              const SizedBox(height: 30),
              const CreatePinCard(),
              const SizedBox(height: 20),
              const OtpCard(),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              StreamBuilder<AtNotification>(
                stream: fetchEnrollmentNotifications(),
                builder: (BuildContext context,
                    AsyncSnapshot<AtNotification> snapshot) {
                  if (snapshot.hasData) {
                    EnrollmentData enrollmentData = EnrollmentData(
                        snapshot.data!.from,
                        '${snapshot.data!.key}${snapshot.data!.from}',
                        jsonDecode(snapshot.data!.value!)[
                            'encryptedApkamSymmetricKey']);

                    print('enrollmentData : ${snapshot.data!}');

                    return EnrollmentRequestCard(
                      enrollmentData: enrollmentData,
                    );
                  } else if (snapshot.hasError) {
                    // Handle error case
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Handle loading or initial state
                    return const Center(
                      child: Column(
                        children: [
                          Text('No request'),
                          Text('At the moment'),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<AtNotification> fetchEnrollmentNotifications() {
    Stream<AtNotification> notificationStream = AtClientManager.getInstance()
        .atClient
        .notificationService
        .subscribe(regex: '__manage');
    return notificationStream;
  }
}
