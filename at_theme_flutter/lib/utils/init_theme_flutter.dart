import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_theme_flutter/services/theme_service.dart';

void initializeThemeService(AtClientImpl atClientInstance, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  ThemeService()
      .initThemeService(atClientInstance, currentAtSign, rootDomain, rootPort);
}

Future getThemeData() async {
  await ThemeService().getThemeData();
}
