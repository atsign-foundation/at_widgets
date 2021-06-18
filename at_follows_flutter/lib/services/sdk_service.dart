import 'dart:convert';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_follows_flutter/exceptions/at_follows_exceptions.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:at_follows_flutter/utils/app_constants.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:at_utils/at_logger.dart';

class SDKService {
  static final SDKService _singleton = SDKService._internal();

  static final _logger = AtSignLogger('SDK Service');

  SDKService._internal();

  factory SDKService() {
    return _singleton;
  }

  Map<String?, bool> monitorConnectionMap = {};

  late AtClientService _atClientServiceInstance;
  String? _atsign;

  set setClientService(AtClientService service) {
    this._atClientServiceInstance = service;
    this._atsign = _atClientServiceInstance.atClient!.getCurrentAtSign();
    Strings.rootdomain =
        _atClientServiceInstance.atClient!.getPreference().rootDomain;
  }

  get atsign => this._atsign;

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return await _atClientServiceInstance.getPkamPrivateKey(atsign).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  ///Returns `true` on deleting [atKey].
  Future<bool> delete(AtKey atKey) async {
    return await _atClientServiceInstance.atClient!.delete(atKey).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  ///Returns `true` on storing/updating [atKey].
  Future<bool> put(AtKey atKey, String? value) async {
    return await _atClientServiceInstance.atClient!.put(atKey, value).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  ///Returns list of latest notifications of followers with `update` operation.
  ///Returns null if such notifications are not present.
  Future<List<AtNotification>> notifyList({String? fromDate}) async {
    int fromDateTime = 0;

    if (fromDate != null) {
      fromDateTime = DateTime.parse(fromDate).millisecondsSinceEpoch;
      fromDate = fromDate.split(' ')[0];
    }
    var response = await _atClientServiceInstance.atClient!.notifyList(
        regex: ('${AppConstants.following}|${AppConstants.followers}'),
        fromDate: fromDate);
    response = response.toString().replaceAll('data:', '');
    if (response == 'null') {
      return [];
    }
    List<AtNotification> notificationList = AtNotification.fromJsonList(
        List<Map<String, dynamic>>.from(jsonDecode(response)));

    notificationList
        .retainWhere((notification) => notification.dateTime! > fromDateTime);
    notificationList.sort((notification1, notification2) =>
        notification2.dateTime!.compareTo(notification1.dateTime!));
    Set<AtNotification> uniqueNotifications = {};
    Set<String> uniqueKeys = {};
    for (var notification in notificationList) {
      bool isUnique =
          uniqueKeys.add(notification.fromAtSign! + notification.key!);
      if (isUnique) {
        uniqueNotifications.add(notification);
      }
    }
    return uniqueNotifications.toList();
  }

  ///Returns `AtFollowsValue` for [atKey].
  Future<AtFollowsValue> get(AtKey atkey) async {
    var response = await _atClientServiceInstance.atClient!.get(atkey).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
    AtFollowsValue val = AtFollowsValue();
    val
      ..metadata = response.metadata
      ..value = response.value
      ..atKey = atkey;
    return val;
  }

  ///Returns `true` on notifying [key] with [value], [operation].
  Future<void> notify(AtKey key, String value, OperationEnum operation,
      Function onDone, Function onError) async {
    return await _atClientServiceInstance.atClient!
        .notify(key, value, operation, onDone, onError,
            notifier:
                _atClientServiceInstance.atClient!.getPreference().namespace)
        .timeout(Duration(seconds: AppConstants.responseTimeLimit),
            onTimeout: () => _onTimeOut());
  }

  ///Returns `AtFollowsValue` after scan with [regex], fetching data for that key.
  Future<AtFollowsValue> scanAndGet(String regex) async {
    var scanKey = await _atClientServiceInstance.atClient!
        .getAtKeys(regex: regex)
        .timeout(Duration(seconds: AppConstants.responseTimeLimit),
            onTimeout: () => _onTimeOut());
    AtFollowsValue value =
        scanKey.isNotEmpty ? await this.get(scanKey[0]) : AtFollowsValue();
    return value;
  }

  ///Returns `true` on starting monitor and passes [callback].
  Future<bool> startMonitor(Function callback) async {
    if (!monitorConnectionMap.containsKey(_atsign)) {
      // ignore: await_only_futures
      var monitorPreference = MonitorPreference();
      await _atClientServiceInstance.atClient!
          .startMonitor(callback, _onMonitorError, monitorPreference);
      monitorConnectionMap.putIfAbsent(_atsign, () => true);
      _logger.info('Monitor Started for $_atsign!');
    }
    return true;
  }

  void _onMonitorError(var error) {
    _logger.severe('Error on monitor call: ${error.toString()}');
  }

  ///Returns `AtSignStatus` for [atsign].
  Future<AtSignStatus?> checkAtSignStatus(String atsign) async {
    var atStatusImpl = AtStatusImpl(rootUrl: Strings.rootdomain);
    var status = await atStatusImpl.get(atsign);
    return status.status();
  }

  ///Performs sync for current @sign if syncStrategy is [SyncStrategy.ONDEMAND].
  sync() async {
    if (_atClientServiceInstance.atClient!.getPreference().syncStrategy ==
        SyncStrategy.ONDEMAND)
      await _atClientServiceInstance.atClient!
          .getSyncManager()!
          .sync(_onSyncDone);
  }

  void _onSyncDone(var syncManager) {
    _logger.finer('sync done');
  }

  ///Throws [ResponseTimeOutException].
  _onTimeOut() {
    _logger.severe('Reponse Timed Out!');
    throw ResponseTimeOutException();
  }

  ///Converts `String` [response] into `AtNotification` type.
  AtNotification toAtNotification(String response) {
    response = response.toString().replaceAll(RegExp('[|]'), '');
    response = response.replaceAll('notification:', '').trim();
    return AtNotification.fromJson(jsonDecode(response));
  }
}
