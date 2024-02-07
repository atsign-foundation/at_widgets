import 'package:at_auth/at_auth.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/common_widgets/input_field.dart';
import 'package:at_enrollment_app/screens/input_pin.dart';
import 'package:at_enrollment_app/services/enrollment_service.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String atSignValue = "";
  String pinValue = "";
  bool tooltipEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        color: ColorConstant.bgColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'SSHNP App',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: ColorConstant.orange),
                  ),
                  SizedBox(height: 15),
                  Text(
                      'Make your devices reachable while eliminating network attack surfaces & reducing administrative overhead.'),
                  SizedBox(height: 15),
                ],
              ),
            ),
            InputField(
              hintText: 'Enter your atSign',
              // prefix: Image.asset(
              //   Images.icon,
              //   width: 21.toWidth,
              //   height: 18.toHeight,
              // ),
              prefix: const Text(
                '@',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              suffix: InkWell(
                onTap: () {
                  setState(() {
                    tooltipEnabled = !tooltipEnabled;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: tooltipEnabled
                        ? const Color(0xFFFFEFEC)
                        : Colors.grey.shade300,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    Icons.question_mark,
                    size: 10,
                    color: tooltipEnabled ? Colors.red : Colors.grey,
                  ),
                ),
              ),
              onChange: (String val) {
                setState(() {
                  atSignValue = val;
                });
              },
            ),
            const SizedBox(height: 15),
            atSignValue.isNotEmpty
                ? InputField(
                    hintText: 'Enter your PIN',
                    isNumpad: true,
                    maxLength: 6,
                    prefix: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 5,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.circle,
                            size: 5,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.circle,
                            size: 5,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                        ],
                      ),
                    ),
                    suffix: InkWell(
                      onTap: () {},
                      child: const Icon(
                        Icons.arrow_right_alt,
                        color: Colors.orange,
                      ),
                    ),
                    onChange: (String val) {
                      setState(() {
                        pinValue = val;
                        print('pin : $pinValue');
                      });
                    },
                  )
                : const SizedBox(),
            const SizedBox(height: 10),
            tooltipEnabled
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFFFFEFEC),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      "An atSign will generate an atKey which gives you access to all our apps. Your atSign name should represent you as it is what you share with the community! ",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 15),
            atSignValue.isEmpty
                ? CustomButton(
                    buttonColor: ColorConstant.orange,
                    fontColor: Colors.white,
                    buttonText: 'Create an Account for Free',
                    width: double.infinity,
                    onPressed: () {
                      _sendEnrollmentRequest(
                          '@sonowboard89', 'wavi', 'pixel', '', {});
                    },
                  )
                : InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InputPin(
                            atSign: atSignValue,
                          ),
                        ),
                      );
                    },
                    child: const Center(
                        child: Text(
                      "Forgot your PIN?",
                      style: TextStyle(decoration: TextDecoration.underline),
                    )),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendEnrollmentRequest(String atSign, String appName,
      String deviceName, String otp, Map<String, String> namespaceMap) async {
    AtNewEnrollmentRequestBuilder atEnrollmentRequestBuilder =
        AtNewEnrollmentRequestBuilder();
    atEnrollmentRequestBuilder
      ..setAppName(appName)
      ..setDeviceName(deviceName)
      ..setOtp(otp)
      ..setNamespaces(namespaceMap);
    AtEnrollmentRequest atEnrollmentRequest =
        atEnrollmentRequestBuilder.build();
    // EnrollResponse enrollResponse = await OnboardingService.getInstance()
    //     .enroll(atSign, atEnrollmentRequest);

    setState(() {});
  }
}
