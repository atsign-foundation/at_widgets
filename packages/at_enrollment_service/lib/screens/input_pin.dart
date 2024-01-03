// import 'package:at_auth/at_auth.dart';
// import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/utils/colors.dart';
// import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:flutter/material.dart';

class InputPin extends StatefulWidget {
  const InputPin({super.key});

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

  // Future<void> _sendEnrollmentRequest(String atSign, String appName,
  //     String deviceName, String otp, Map<String, String> namespaceMap) async {
  //   AtNewEnrollmentRequestBuilder atEnrollmentRequestBuilder = AtNewEnrollmentRequestBuilder();
  //       atEnrollmentRequestBuilder
  //         ..setAppName(appName)
  //         ..setDeviceName(deviceName)
  //         ..setOtp(otp)
  //         ..setNamespaces(namespaceMap);
  //   AtEnrollmentRequest atEnrollmentRequest =
  //       atEnrollmentRequestBuilder.build();
  //   EnrollResponse enrollResponse = await OnboardingService.getInstance()
  //       .enroll(atSign, atEnrollmentRequest);

  //   print(enrollResponse);

  //   // setState(() {
  //   //   if (enrollResponse.enrollmentId.isEmpty) {
  //   //     showErrorWidget = true;
  //   //   } else {
  //   //     showSuccessWidget = true;
  //   //     enrollmentId = enrollResponse.enrollmentId;
  //   //     enrollmentStatus = enrollResponse.enrollStatus.toString();
  //   //   }
  //   // });
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.bgColor,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
              const Text(
                '@snowfirm0',
                style: TextStyle(
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
                            buttonColor:
                                otpValue.length == 6 ? Colors.red : ColorConstant.lightGrey.withOpacity(0.4),
                            onPressed: () {
                              setState(() {
                                isLoading = !isLoading;
                              });
                            },
                          ),
                        )
                      ],
                    )
                  : loader(),
              const Spacer(),
              const Center(
                  child: Text(
                "Onboard a different atsign",
                style: TextStyle(decoration: TextDecoration.underline),
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
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 80.0),
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
