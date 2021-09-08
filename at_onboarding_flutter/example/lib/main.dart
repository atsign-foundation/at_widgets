import 'package:at_client/src/preference/at_client_preference.dart';
import 'package:at_client_mobile/src/at_client_service.dart';
import 'package:at_onboarding_flutter_example/dashboard.dart';
import 'package:at_onboarding_flutter_example/services/at_service.dart';
import 'package:at_onboarding_flutter_example/utils/app_constants.dart';
import 'package:at_onboarding_flutter_example/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:at_onboarding_flutter/widgets/custom_reset_button.dart';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_utils/at_logger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AtClientPreference atClientPrefernce;
  AtSignLogger _logger = AtSignLogger('Plugin example app');
  @override
  void initState() {
    AtService.getInstance().getAtClientPreference().then((AtClientPreference value) => atClientPrefernce = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder: (BuildContext context) => Center(
            child: Column(
              children: <Widget>[
                TextButton(
                    onPressed: () async {
                      Onboarding(
                        context: context,
                        atClientPreference: atClientPrefernce,
                        appColor: const Color.fromARGB(255, 240, 94, 62),
                        onboard: (Map<String?, AtClientService> value, String? atsign) {
                          AtService.getInstance().atClientServiceMap = value;
                          _logger.finer('Successfully onboarded $atsign');
                        },
                        onError: (Object? error) {
                          _logger.severe('Onboarding throws $error error');
                        },
                        rootEnvironment: 'staging',
                        nextScreen: DashBoard(),
                      );
                    },
                    child: const Text(AppStrings.scan_qr)),
                CustomResetButton(
                  loading: false,
                  buttonText: 'Reset',
                  width: 90,
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
