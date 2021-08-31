// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';

void initializeGroupService(
    AtClientManager atClientManager, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  GroupService().resetData();
  GroupService().init(atClientManager, currentAtSign, rootDomain, rootPort);
}
