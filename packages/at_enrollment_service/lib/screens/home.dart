import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/common_widgets/input_field.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: ColorConstant.bgColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: SingleChildScrollView(
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
              // prefix: Image.asset(Images.atImage),
              hintText: 'Enter your atSign',
              prefix: Text('@'),
              suffix: Text('?'),
              onChange: (String val) {
                //
              },
            ),
            const SizedBox(height: 15),
            const CustomButton(
              buttonColor: ColorConstant.orange,
              fontColor: Colors.white,
              buttonText: 'Create an Account for Free',
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
