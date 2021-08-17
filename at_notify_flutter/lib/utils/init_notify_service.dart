import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_notify_flutter/services/notify_service.dart';
// ignore: import_of_legacy_library_into_null_safe

void initializeNotifyService(
    AtClientImpl atClientInstance, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  NotifyService()
      .initNotifyService(atClientInstance, currentAtSign, rootDomain, rootPort);
}

void disposeNotifyControllers() {
  NotifyService().disposeControllers();
}
