import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class InputPin extends StatefulWidget {
  const InputPin({super.key});

  @override
  State<InputPin> createState() => _InputPinState();
}

class _InputPinState extends State<InputPin> {
  bool isLoading = false;

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
        child: SingleChildScrollView(
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
                          children: [
                            Expanded(
                              child: Container(
                                height: 58,
                                width: 51,
                                color: Colors.white,
                                padding: const EdgeInsets.only(left: 20),
                                child: const TextField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 58,
                                width: 51,
                                color: Colors.white,
                                padding: const EdgeInsets.only(left: 20),
                                child: const TextField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 58,
                                width: 51,
                                color: Colors.white,
                                padding: const EdgeInsets.only(left: 20),
                                child: const TextField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 58,
                                width: 51,
                                color: Colors.white,
                                padding: const EdgeInsets.only(left: 20),
                                child: const TextField(
                                  decoration:
                                      InputDecoration(border: InputBorder.none),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        CustomButton(
                          width: double.infinity,
                          buttonText: 'Onboard atSign',
                          fontColor: Colors.white,
                          buttonColor: ColorConstant.lightGrey.withOpacity(0.4),
                          onPressed: () {
                            setState(() {
                              isLoading = !isLoading;
                            });
                          },
                        )
                      ],
                    )
                  : loader(),
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
