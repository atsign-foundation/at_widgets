import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_follows_flutter/exceptions/at_follows_exceptions.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:at_follows_flutter/utils/app_constants.dart';
import 'package:at_utils/at_logger.dart';

class SDKService {
  static final SDKService _singleton = SDKService._internal();

  static final _logger = AtSignLogger('SDK Service');

  SDKService._internal();

  factory SDKService() {
    return _singleton;
  }

  AtClientService _atClientServiceInstance;
  String _atsign;

  set setClientService(AtClientService service) {
    this._atClientServiceInstance = service;
    this._atsign = _atClientServiceInstance.atClient.currentAtSign;
  }

  get atsign => this._atsign;

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await _atClientServiceInstance.atClient
        .getPrivateKey(atsign)
        .timeout(Duration(seconds: AppConstants.responseTimeLimit),
            onTimeout: () => _onTimeOut());
  }

  Future<bool> delete(AtKey atKey) async {
    return await _atClientServiceInstance.atClient.delete(atKey).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  Future<bool> put(AtKey atKey, String value) async {
    return await _atClientServiceInstance.atClient.put(atKey, value).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  Future<AtFollowsValue> get(AtKey atkey) async {
    var response = await _atClientServiceInstance.atClient.get(atkey).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
    AtFollowsValue val = AtFollowsValue();
    val
      ..metadata = response.metadata
      ..value = response.value
      ..atKey = atkey;
    return val;
  }

  Future<bool> notify(AtKey key, String value, OperationEnum operation) async {
    return await _atClientServiceInstance.atClient
        .notify(key, value, operation, notifier: 'persona')
        .timeout(Duration(seconds: AppConstants.responseTimeLimit),
            onTimeout: () => _onTimeOut());
  }

  Future<AtFollowsValue> scanAndGet(String regex) async {
    var scanKey = await _atClientServiceInstance.atClient
        .getAtKeys(regex: regex)
        .timeout(Duration(seconds: AppConstants.responseTimeLimit),
            onTimeout: () => _onTimeOut());
    AtFollowsValue value =
        scanKey.isNotEmpty ? await this.get(scanKey[0]) : AtFollowsValue();
    value.atKey = scanKey.isNotEmpty ? scanKey[0] : null;
    return value;
  }

  Future<bool> startMonitor(Function callback) async {
    String privateKey = await getPrivateKey(_atsign);
    _atClientServiceInstance.atClient.startMonitor(privateKey, callback);
    _logger.info('Monitor Started!');
    return true;
  }

  sync() async {
    if (_atClientServiceInstance.atClient.preference.syncStrategy ==
        SyncStrategy.ONDEMAND)
      await _atClientServiceInstance.atClient.getSyncManager().sync();
  }

  _onTimeOut() {
    _logger.severe('Reponse Timed Out!');
    throw ResponseTimeOutException();
  }
}
