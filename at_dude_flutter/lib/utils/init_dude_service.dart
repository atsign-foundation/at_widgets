import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_dude_flutter/services/dude_service.dart';


void initializeDudeService(String currentAtSign,{rootDomain = 'root.atsign.org', rootPort = 64}) {
  DudeService().initDudeService(currentAtSign,rootDomain,rootPort);

}
