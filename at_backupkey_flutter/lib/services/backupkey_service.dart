import 'package:at_client_mobile/at_client_mobile.dart';

class BackUpKeyService {
  static final BackUpKeyService _singleton = BackUpKeyService._internal();

  BackUpKeyService._internal();

  factory BackUpKeyService() {
    return _singleton;
  }

  late AtClientService atClientService;

  Future<String?> _getAESKey(String atsign) async {
    return await atClientService.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    var result;
    try {
      result = await atClientService.getEncryptedKeys(atsign);
      result[atsign] = await this._getAESKey(atsign);
    } catch (e) {
      result = {};
    }
    return result;
  }
}
