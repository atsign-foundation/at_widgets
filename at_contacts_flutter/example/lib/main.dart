import 'dart:async';

import 'package:eg/screens/onboard.screen.dart';
import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;

import 'services/client.sdk.services.dart';

Future<void> main() async {
  await AtEnv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  @override
  void initState() {
    Future.microtask(() async {
      await clientSdkService.onboard();
    });
    super.initState();
  }

  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // * The onboarding screen (first screen)
      home: LoginScreen(clientSdkService: clientSdkService, logger: _logger),
    );
  }
}
