import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:at_theme_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

class ThemeService {
  ThemeService._();
  static final ThemeService _instance = ThemeService._();
  factory ThemeService() => _instance;

  AtClientImpl? atClientInstance;
  String? rootDomain;
  int? rootPort;
  String? currentAtsign;

  initThemeService(AtClientImpl atClientInstanceFromApp, String atsign,
      String rootDomainFromApp, int rootPortFromApp) {
    atClientInstance = atClientInstanceFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    currentAtsign = atsign;
  }

  Future<bool> updateThemeData(AppTheme themeData) async {
    var color = Color(0xffffffff);
    print('Color(0xffffffff) : ${color.hashCode}');
    print('Color value : ${color.value}');
    Color color2 = Color(color.value);
    // TODO: incomplete
    return true;

    AtKey atKey = getAtkey();
    print('themeData : ${themeData}');
    var json = jsonDecode(themeData.encoded());
    // Color color = json['backgroundColor'] as Color;
    print('color : ${json['backgroundColor']}');
    print('color: ${json['backgroundColor'].runtimeType}');
    print('json data : ${themeData.encoded()}');
    return true;
    return await atClientInstance!.put(atKey, jsonEncode(themeData));
  }

  Future getThemeData() async {
    AtKey atKey = getAtkey();
    var atValue = await atClientInstance!.get(atKey);

    if (atValue.value == null) {
      return false;
    }

    // ThemeData themeData = jsonDecode(atValue.value);
    // if (themeData == null) {
    //   return false;
    // }

    print('atValue : ${atValue}');
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
