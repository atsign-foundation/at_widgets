import 'dart:async';
import 'dart:io';

import 'package:at_chat_flutter_example/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_keychain/flutter_keychain.dart';

class ClientSdkService {
  static final ClientSdkService _singleton = ClientSdkService._internal();
  ClientSdkService._internal();

  factory ClientSdkService.getInstance() {
    return _singleton;
  }
  AtClientService? atClientServiceInstance;

  late AtClientPreference atClientPreference;
  String? _atsign;
  String? get currentAtsign => _atsign;
  set setAtsign(String atSign) {
    _atsign = atSign;
  }

  Future<void> onboard(BuildContext context, {String? atsign}) async {
    atClientServiceInstance = AtClientService();
    Directory? downloadDirectory;
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }

    final appSupportDirectory =
        await path_provider.getApplicationSupportDirectory();
    var path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();

    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.rootDomain = MixedConstants.ROOT_DOMAIN;
    atClientPreference.hiveStoragePath = path;
    atClientPreference.downloadPath = downloadDirectory!.path;
    atClientPreference.namespace = 'chatexample';
    Onboarding(
      atsign: null,
      context: context,
      atClientPreference: atClientPreference,
      domain: MixedConstants.ROOT_DOMAIN,
      appAPIKey: MixedConstants.devAPIKey,
      rootEnvironment: RootEnvironment.Production,
      onboard: (atClientServiceMap, onboardedAtsign) async {},
      onError: (error) {
        print('Onboarding throws $error error');
      },
    );
  }

  ///Fetches atsign from device keychain.
  Future<String?> getAtSign() async {
    return await KeychainUtil.getAtSign();
  }

  deleteKey() async {
    FlutterKeychain.remove(key: '@atsign');
    print('after delete');
  }
}
