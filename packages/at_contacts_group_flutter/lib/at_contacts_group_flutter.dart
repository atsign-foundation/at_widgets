// import 'dart:async';

// import 'package:flutter/services.dart';

// class AtContactsGroupFlutter {
//   static const MethodChannel _channel =
//       const MethodChannel('at_contacts_group_flutter');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }

library at_contacts_group_flutter;

export './screens/list/group_list.dart';
export './screens/empty_group/empty_group.dart';
export './models/group_contacts_model.dart';
export './utils/init_group_service.dart';

export './screens/new_group/create_group.dart';
export './screens/group_contact/group_list_contact.dart';
