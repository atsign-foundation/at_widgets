import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:at_theme_flutter/utils/constants.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService _instance = ThemeService._();
  factory ThemeService() => _instance;

  String? rootDomain;
  int? rootPort;
  String? currentAtsign;

  initThemeService(String rootDomainFromApp, int rootPortFromApp) {
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    currentAtsign = AtClientManager.getInstance().atClient.getCurrentAtSign();
  }

  Future<bool> updateThemeData(AppTheme themeData) async {
    AtKey atKey = getAtkey();
    try {
      var result = await AtClientManager.getInstance()
          .atClient
          .put(atKey, themeData.encoded());
      return result;
    } catch (e) {
      print('error in updating theme data: ${e.toString()}');
      return false;
    }
  }

  Future<AppTheme?> getThemeData() async {
    try {
      AtKey atKey = getAtkey();
      var atValue = await AtClientManager.getInstance().atClient.get(atKey);

      if (atValue.value == null && atValue.value == 'null') {
        return null;
      }

      AppTheme? themeData = AppTheme.decode(jsonDecode(atValue.value));
      return themeData;
    } catch (e) {
      print('error in getThemeData : ${e.toString()}');
    }
    return null;
  }

  AtKey getAtkey() {
    Metadata metaData = Metadata();
    AtKey atKey = AtKey()
      ..key = MixedConstants.theme_key
      ..metadata = metaData
      ..metadata!.ttr = -1
      ..metadata!.ccd = true;

    return atKey;
  }
}
