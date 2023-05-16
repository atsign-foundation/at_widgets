import 'package:at_client_mobile/at_client_mobile.dart';

class BackUpKeyService {
  static final BackUpKeyService _singleton = BackUpKeyService._internal();

  BackUpKeyService._internal();

  factory BackUpKeyService() {
    return _singleton;
  }

  static Future<String?> _getAESKey(String atsign) async {
    return await KeychainUtil.getAESKey(atsign);
  }

  static Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    Map<String, String> result;
    try {
      result = await KeychainUtil.getEncryptedKeys(atsign);
      result[atsign] = await _getAESKey(atsign) ?? '';
    } catch (e) {
      result = {};
    }
    return result;
  }
}
