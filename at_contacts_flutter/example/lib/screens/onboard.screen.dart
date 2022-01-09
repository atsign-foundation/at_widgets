import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:eg/services/client.sdk.services.dart';
import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart' show AtSignLogger;

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;

import 'home.screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    Key? key,
    required this.clientSdkService,
    required AtSignLogger logger,
  })  : _logger = logger,
        super(key: key);

  final ClientSdkService clientSdkService;
  final AtSignLogger _logger;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyApp'),
      ),
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () async {
              Onboarding(
                context: context,
                atClientPreference: clientSdkService.atClientPreference,
                domain: AtEnv.rootDomain,
                rootEnvironment: AtEnv.rootEnvironment,
                onboard: (value, atsign) {
                  _logger.finer('Successfully onboarded $atsign');
                },
                onError: (error) async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: const Text('Something went wrong'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('ok'),
                            ),
                          ],
                        );
                      });
                  _logger.severe('Onboarding throws $error error');
                },
                nextScreen: const HomePage(),
              );
            },
            child: const Text('Onboard an @sign'),
          ),
        ),
      ),
    );
  }
}
