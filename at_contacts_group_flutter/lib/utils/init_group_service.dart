import 'package:at_contacts_group_flutter/services/group_service.dart';

void initializeGroupService({rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  GroupService().resetData();
  GroupService().init(rootDomain, rootPort);
}
