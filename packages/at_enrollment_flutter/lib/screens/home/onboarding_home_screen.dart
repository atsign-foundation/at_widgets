import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_flutter/at_enrollment_flutter.dart';
import 'package:at_enrollment_flutter/screens/home/enrollment_request_screen.dart';
import 'package:at_enrollment_flutter/screens/home/home_screen.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

/// This class contains code related to home screen after the user is successfully
/// onboarded/authenticated
class OnboardingHomeScreen extends StatefulWidget {
  const OnboardingHomeScreen({super.key});

  @override
  State<OnboardingHomeScreen> createState() => _OnboardingHomeScreenState();
}

class _OnboardingHomeScreenState extends State<OnboardingHomeScreen> {
  String currentAtsign = '';

  @override
  void initState() {
    currentAtsign =
        AtClientManager.getInstance().atClient.getCurrentAtSign() ?? '';
    EnrollmentServiceWrapper.getInstance().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: ColorConstant.bgColor,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back),
          ),
          backgroundColor: ColorConstant.orange.withOpacity(0.2),
        ),
        body: DefaultTabController(
          length: 2,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: ColorConstant.orange.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'atKey Authenticator',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currentAtsign,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.orange,
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        HomePageWidget(),
                        EnrollmentRequestScreen(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 70,

                /// 310 is the width of the enrollment requet card
                /// positioned to b ein center
                left: (SizeConfig().screenWidth / 2) - (310 / 2),
                child: tab(),
              ),
            ],
          ),
        ));
  }

  Widget tab() {
    return Container(
      height: 45,
      width: 310,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          25.0,
        ),
      ),
      child: TabBar(
        indicatorColor: Colors.white,
        labelPadding: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        indicatorPadding: const EdgeInsets.all(0),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(
            25.0,
          ),
          color: Colors.black,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        tabs: const [
          SizedBox(
            width: 150,
            child: Tab(
              text: 'Settings',
            ),
          ),
          SizedBox(
            width: 150,
            child: Tab(
              text: 'Requests',
            ),
          ),
        ],
      ),
    );
  }
}
