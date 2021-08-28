// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';

void initializeGroupService(AtClientImpl atClientInstance, String currentAtSign,
    {String rootDomain = 'root.atsign.wtf', int rootPort = 64}) {
  GroupService().resetData();
  GroupService().init(atClientInstance, currentAtSign, rootDomain, rootPort);
}
