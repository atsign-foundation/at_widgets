// import 'dart:async';

// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
// import 'package:atsign_authentication_helper/screens/home.dart';

// class AtsignAuthenticationHelper {
//   static const MethodChannel _channel =
//       const MethodChannel('atsign_authentication_helper');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }

//   static Widget startAuth({nextRoute = 'home'}) {
//     return Home(
//       nextRoute: nextRoute,
//     );
//   }
// }

library atsign_auth_helper;

export './screens/start_button.dart';
export './services/client_sdk_service.dart';
