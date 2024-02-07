// import 'package:at_auth/at_auth.dart';
// import 'package:at_client_mobile/at_client_mobile.dart';
import 'dart:convert';

import 'package:at_auth/at_auth.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/services/enrollment_service.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
// import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InputPin extends StatefulWidget {
  String atSign;
  InputPin({super.key, required this.atSign});

  @override
  State<InputPin> createState() => _InputPinState();
}

class _InputPinState extends State<InputPin> {
  bool isLoading = false;
  String otpValue = "";

  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  String getValue() {
    return controllers.map((controller) => controller.text).join();
  }

  sendEnrollmentRequest() async {
    if (widget.atSign.isNotEmpty && otpValue.isNotEmpty) {
      AtNewEnrollmentRequestBuilder atEnrollmentRequestBuilder =
          AtNewEnrollmentRequestBuilder();

      AtEnrollmentServiceImpl atEnrollmentServiceImpl =
          EnrollmentService.getInstance().getAtEnrollmentServiceImpl;

      atEnrollmentRequestBuilder
        ..setAppName('wavi')
        ..setDeviceName('iphone')
        ..setOtp(otpValue)
        ..setNamespaces({'wavi': 'rw'});
      AtEnrollmentRequest atEnrollmentRequest =
          atEnrollmentRequestBuilder.build();
      // EnrollResponse enrollResponse =
      //     await OnboardingService.getInstance().enroll(
      //   atEnrollmentServiceImpl,
      //   atEnrollmentRequest,
      // );

      // print('enrollResponse: ${enrollResponse.enrollmentId}');
      // print('enrollResponse: ${enrollResponse.enrollStatus}');
    }
  }

  @override
  void initState() {
    readEnrollmentRequests();
    super.initState();
  }

  readEnrollmentRequests() async {
    final _enrollmentKeychainStore = FlutterSecureStorage();
    String? enrollmentInfoJsonString =
        await _enrollmentKeychainStore.read(key: 'enrollmentInfo');
    var jsonString = (jsonDecode(enrollmentInfoJsonString ?? ''));
    try {
  print(" enrollmentInfoJsonString : ${enrollmentInfoJsonString}");
  print('jsonString: ${jsonString['atSign']}');
} finally {
  // TODO
}
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
              Text(
                widget.atSign,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: ColorConstant.orange),
              ),
              isLoading == false
                  ? Column(
                      children: [
                        const SizedBox(height: 35),
                        const Text(
                            'We have sent an OTP request to the following device and app:'),
                        const SizedBox(height: 35),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enter OTP',
                            style: TextStyle(color: Color(0xFF888888)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              margin: const EdgeInsets.all(4.0),
                              width: 45.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: controllers[index],
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 1 && index < 5) {
                                      FocusScope.of(context).nextFocus();
                                    }
                                    setState(() {
                                      otpValue = getValue();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        AbsorbPointer(
                          absorbing: otpValue.length != 6,
                          child: CustomButton(
                            width: double.infinity,
                            buttonText: 'Onboard atSign',
                            fontColor: Colors.white,
                            buttonColor: otpValue.length == 6
                                ? Colors.red
                                : ColorConstant.lightGrey.withOpacity(0.4),
                            onPressed: () {
                              setState(() {
                                isLoading = !isLoading;
                              });

                              sendEnrollmentRequest();

                              setState(() {
                                isLoading = !isLoading;
                              });
                            },
                          ),
                        )
                      ],
                    )
                  : loader(),
              const SizedBox(height: 20),
              Center(
                  child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Onboard a different atsign",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget loader() {
  return const Column(
    children: [
      Padding(
        padding: EdgeInsets.only(top: 80.0),
        child: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ),
        ),
      ),
      SizedBox(height: 45),
      Text("What's going on?"),
      Text("Verifying OTP...", style: TextStyle(fontSize: 20))
    ],
  );
}
