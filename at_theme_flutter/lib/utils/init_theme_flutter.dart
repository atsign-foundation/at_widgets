import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:at_theme_flutter/services/theme_service.dart';

void initializeThemeService({rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  ThemeService().initThemeService(rootDomain, rootPort);
}

Future<AppTheme?> getThemeData() async {
  return await ThemeService().getThemeData();
}

Future<bool> setAppTheme(AppTheme appTheme) async {
  return await ThemeService().updateThemeData(appTheme);
}
