import 'dart:convert';

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

  Map<String, bool> monitorConnectionMap = {};

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

  ///Returns list of latest notifications of followers with `update` operation.
  ///Returns null if such notifications are not present.
  Future<List<AtNotification>> notifyList() async {
    var response = await _atClientServiceInstance.atClient
        .notifyList(regex: AppConstants.following);
    response = response.toString().replaceAll('data:', '');
    if (response == 'null') {
      return [];
    }
    List<AtNotification> notificationList = AtNotification.fromJsonList(
        List<Map<String, dynamic>>.from(jsonDecode(response)));
    notificationList.sort((notification1, notification2) =>
        notification2.dateTime.compareTo(notification1.dateTime));
    Set<AtNotification> uniqueNotifications = {};
    Set<String> uniqueKeys = {};
    for (var notification in notificationList) {
      // if (notification.operation == Operation.update) {
      bool isUnique = uniqueKeys.add(notification.fromAtSign);
      if (isUnique) {
        uniqueNotifications.add(notification);
      }
      // }
    }
    return uniqueNotifications.toList();
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
    if (!monitorConnectionMap.containsKey(_atsign)) {
      String privateKey = await getPrivateKey(_atsign);
      _atClientServiceInstance.atClient.startMonitor(privateKey, callback);
      monitorConnectionMap.putIfAbsent(_atsign, () => true);
      _logger.info('Monitor Started for $_atsign!');
    }
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

  toAtNotification(String response) {
    response = response.toString().replaceAll(RegExp('[|]'), '');
    response = response.replaceAll('notification:', '').trim();
    return AtNotification.fromJson(jsonDecode(response));
  }
}
