// import 'dart:async';

// import 'package:flutter/services.dart';

// class AtBackupkeyFlutter {
//   static const MethodChannel _channel =
//       const MethodChannel('at_backupkey_flutter');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }
library at_backupkey_flutter;

export './widgets/backup_key_widget.dart';
