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
  var atClientPrefernce;
  var _logger = AtSignLogger('Plugin example app');
  @override
  void initState() {
    AtService.getInstance()
        .getAtClientPreference()
        .then((value) => atClientPrefernce = value);
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
          builder: (context) => Center(
            child: Column(
              children:<Widget>[
                TextButton(
                    onPressed: () async {
                      Onboarding(
                          context: context,
                          atClientPreference: atClientPrefernce,
                          domain: AppConstants.rootDomain,
                          appColor: Color.fromARGB(255, 240, 94, 62),
                          onboard: (value, atsign) {
                            AtService.getInstance().atClientServiceMap = value;
                            _logger.finer('Successfully onboarded $atsign');
                          },
                          onError: (error) {
                            _logger.severe('Onboarding throws $error error');
                          },
                          nextScreen: DashBoard(),
                          appAPIKey: AppConstants.devAPIKey);
                    },
                    child: Text(AppStrings.scan_qr)),

                  CustomResetButton(
                    loading: false,
                    buttonText: "Reset",
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
