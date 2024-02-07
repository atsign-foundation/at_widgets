import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/atkey_authenticator.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator/widgets/enrollment_request_screen.dart';
import 'package:at_enrollment_app/utils/assets.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class KeyAuthenticatorHomeScreen extends StatefulWidget {
  const KeyAuthenticatorHomeScreen({super.key});

  @override
  State<KeyAuthenticatorHomeScreen> createState() =>
      _KeyAuthenticatorHomeScreenState();
}

class _KeyAuthenticatorHomeScreenState
    extends State<KeyAuthenticatorHomeScreen> {
  String currentAtsign = '';
  int requestCount = 0;

  @override
  void initState() {
    // currentAtsign =
    //     AtClientManager.getInstance().atClient.getCurrentAtSign() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: ColorConstant.bgColor,
        body: DefaultTabController(
          length: 2,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: ColorConstant.appBarColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 52, left: 28),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    Images.back,
                                    height: 16,
                                    width: 8,
                                    color: ColorConstant.lightGray,
                                    package: 'at_enrollment_app',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: ColorConstant.lightGray,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Image.asset(
                            Images.key,
                            fit: BoxFit.cover,
                            package: 'at_enrollment_app',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'atKey Authenticator',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            currentAtsign,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: ColorConstant.orange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        AtKeyAuthenticator(),
                        EnrollmentRequestScreen(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 184,
                left: 0,
                right: 0,
                child: Center(child: tab()),
              ),
            ],
          ),
        ));
  }

  Widget tab() {
    return Container(
      height: 48,
      width: 340,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(31),
      ),
      child: TabBar(
        indicatorColor: Colors.white,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        indicatorPadding: const EdgeInsets.all(0),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(31),
          color: Colors.black,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        tabs: [
          const SizedBox(
            width: 172,
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 172,
            child: Tab(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Requests',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (requestCount != 0)
                      TextSpan(
                        text: ' $requestCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.orange,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
