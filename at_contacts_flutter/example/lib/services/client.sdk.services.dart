import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ClientSdkService {
  static final ClientSdkService _singleton = ClientSdkService._internal();
  ClientSdkService._internal();

  factory ClientSdkService.getInstance() {
    return _singleton;
  }
  AtClientService? atClientServiceInstance;
  AtClientManager atClientManager = AtClientManager.getInstance();

  late AtClientPreference atClientPreference;

  Future<String?> getAtSignAndInitializeContacts() async {
    var currentAtSign = await getAtSign();
    initializeContactsService(rootDomain: AtEnv.rootDomain);
    return currentAtSign;
  }

  Future<bool> onboard({String? atsign}) async {
    atClientServiceInstance = AtClientService();

    final appSupportDirectory =
        await path_provider.getApplicationSupportDirectory();
    var path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();
    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.namespace = AtEnv.appNamespace;
    atClientPreference.rootDomain = AtEnv.rootDomain;
    atClientPreference.hiveStoragePath = path;
    var result = await atClientServiceInstance!
        .onboard(atClientPreference: atClientPreference, atsign: atsign)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
      }
      return false;
    });
    return result;
  }

  ///Fetches atsign from device keychain.
  Future<String?> getAtSign() async {
    return atClientManager.atClient.getCurrentAtSign();
  }
}
