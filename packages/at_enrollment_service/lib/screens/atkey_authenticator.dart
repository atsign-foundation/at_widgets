import 'dart:async';
import 'dart:convert';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/models/enrollment.dart';
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
    _getOTPFromServer();

    timer = Timer.periodic(const Duration(minutes: 1), (t) {
      _getOTPFromServer();
    });

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
      appBar: AppBar(
        backgroundColor: ColorConstant.bgColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'atKey Authenticator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                currentAtsign,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ColorConstant.orange,
                ),
              ),
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
              Container(
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
                      onTap: createPinBottomsheet,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: ColorConstant.lightGrey.withOpacity(0.4),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '*',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // const Text(
                    //   'Create a PIN',
                    //   style:
                    //       TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    // ),
                    Text(
                      'PIN : $otp',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You can create a PIN to speed up your onboarding experience across apps.',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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

  createPinBottomsheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: const BoxConstraints(
        minHeight: 450,
        maxHeight: double.maxFinite,
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CreatePin();
      },
    );
  }

  Stream<AtNotification> fetchEnrollmentNotifications() {
    Stream<AtNotification> notificationStream = AtClientManager.getInstance()
        .atClient
        .notificationService
        .subscribe(regex: '__manage');
    return notificationStream;
  }

  Future<String?> _getOTPFromServer() async {
    String? tempOtp = await AtClientManager.getInstance()
        .atClient
        .getRemoteSecondary()
        ?.executeCommand('otp:get\n', auth: true);
    tempOtp = tempOtp?.replaceAll('data:', '');
    print('otp: ${tempOtp}');
    if (mounted) {
      setState(() {
        otp = tempOtp ?? '';
      });
    }
    return otp;
  }
}
