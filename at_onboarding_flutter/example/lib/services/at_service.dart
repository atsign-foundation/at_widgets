import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter_example/utils/app_constants.dart';
import 'package:at_commons/at_commons.dart' as at_commons;
import 'package:path_provider/path_provider.dart' as path_provider;

class AtService {
  static final AtService _singleton = AtService._internal();

  AtService._internal();
  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();

  factory AtService.getInstance() {
    return _singleton;
  }

  Future<AtClientPreference> getAtClientPreference() async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..namespace = AppConstants.appNamespace
      ..syncStrategy = SyncStrategy.ONDEMAND
      ..rootDomain = AppConstants.rootDomain
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  Map<String, AtClientService> atClientServiceMap = {};
  String _atsign;

  AtClientImpl _getAtClientForAtsign({String atsign}) {
    atsign ??= _atsign;
    if (atClientServiceMap.containsKey(atsign)) {
      return atClientServiceMap[atsign].atClient;
    }
    return null;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await _keyChainManager.getAtSign();
  }

  Future<bool> put({String key, var value}) async {
    var atKey = at_commons.AtKey()..key = key;
    // ..metadata = metaData;
    return await _getAtClientForAtsign().put(atKey, value);
  }

  Future<bool> delete({String key}) async {
    var atKey = at_commons.AtKey()..key = key;
    return await _getAtClientForAtsign().delete(atKey);
  }

  Future<List<String>> get() async {
    return await _getAtClientForAtsign().getKeys(regex: AppConstants.regex);
  }

  ///Returns null if [atsign] is null else the formatted [atsign].
  ///[atsign] must be non-null.
  String formatAtSign(String atsign) {
    if (atsign == null) {
      return null;
    }
    atsign = atsign.trim().toLowerCase().replaceAll(' ', '');
    atsign = !atsign.startsWith('@') ? '@' + atsign : atsign;
    return atsign;
  }
}
