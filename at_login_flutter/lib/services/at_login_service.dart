import 'dart:async';
import 'package:at_login_flutter/domain/at_login_model.dart';
import 'package:at_login_flutter/exceptions/at_login_exceptions.dart';
import 'package:at_login_flutter/utils/app_constants.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../at_login_flutter.dart';

class AtLoginService {
  static final AtLoginService _singleton = AtLoginService._internal();

  AtLoginService._internal();

  factory AtLoginService() {
    return _singleton;
  }

  /// AtClient specific
  AtClientService atClientServiceInstance = AtClientService();
  AtClientPreference _atClientPreference = AtClientPreference();
  AtClient _atClient;

  set setAtClientPreference(AtClientPreference _preference) {
    _atClientPreference = _preference
      ..cramSecret = null
      ..privateKey = null;
  }

  get atClientPreference => _atClientPreference;

  /// Monitor specific
  Map<String, bool> monitorLoginMap = {};

  bool isMonitorStarted = false;

  ///AtLogin specific
  AtSignLogger _logger = AtSignLogger('AtLogin Service');
  String _namespace;
  Widget _applogo;
  set setLogo(Widget logo) => _applogo = logo;
  get logo => _applogo;
  Function loginFunc;
  Widget _nextScreen;
  set setNextScreen(Widget nextScreen) {
    _nextScreen = nextScreen;
  }

  set namespace(String namespace) => _namespace = namespace;
  get appNamespace => _namespace;

  String _atsign;
  set atsign(String atsign) {
    atsign = formatAtSign(atsign);
    _atsign = atsign;
  }
  String get currentAtsign => _atsign;

  Future<bool> setAtsign(atsign) async {
    bool success;
    await AtClientImpl.createClient(atsign, _namespace, _atClientPreference);
    _atClient = await AtClientImpl.getClient(atsign);
    _atsign = atsign;
    return success;
  }

  Future<bool> completeAtLogin(AtLoginObj atLoginObj) async {
    bool success = false;
    await setAtsign(atLoginObj.atsign);
    var atKey = AtKey()
      ..key = DateTime.now().microsecondsSinceEpoch.toString()
      ..namespace = AppConstants.atLoginWidgetNamespace;
    var data = atLoginObj.toJson().toString();
    success = await put(atKey, data).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
    return success;
  }

  Future<bool> putLoginProof(AtLoginObj atLoginObj) async {
    bool success = false;
    //TODO check atsign exists
    await setAtsign(atLoginObj.atsign);
    var metadata = Metadata()
      ..isPublic=true
      ..ttl=30;
    var atKey = AtKey()
      ..key =  atLoginObj.challenge
      ..metadata = metadata;
    var data = atLoginObj.challenge;
    success = await put(atKey, data).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
    return success;
  }

    ///Returns `true` on storing/updating [atKey].
  Future<bool> put(AtKey atKey, String value) async {
    return await _atClient.put(atKey, value).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  ///Returns `true` on deleting [atKey].
  Future<bool> delete(AtKey atKey) async {
    return await _atClient.delete(atKey).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  Future<dynamic> get(key) async {
    return await _atClient.get(key);
  }

  Future<Map<AtKey, AtValue>> getAtLogins() async {
    Map<AtKey, AtValue> logins = new Map();
    List<AtKey> keys = await _atClient.getAtKeys(regex: AppConstants.regex);
    print('keys are $keys');
    print('keys length is ${keys.length}');
    keys.forEach((atKey) async {
      var value = await _atClient.get(atKey);
      print('added $value for $atKey');
      logins[atKey] = value;
    });
    return logins;
  }

  ///Returns `AtSignStatus` for [atsign].
  Future<AtSignStatus> checkAtSignStatus(String atsign) async {
    var atStatusImpl = AtStatusImpl(rootUrl: AppConstants.serverDomain);
    var status = await atStatusImpl.get(atsign);
    return status.status();
  }

  ///Returns null if [atsign] is null else the formatted [atsign].
  ///[atsign] must be non-null.
  String formatAtSign(String atsign) {
    if (atsign == null || atsign == '') {
      return null;
    }
    atsign = atsign.trim().toLowerCase().replaceAll(' ', '');
    atsign = !atsign.startsWith('@') ? '@' + atsign : atsign;
    return atsign;
  }

  ///Returns `true` on starting monitor and passes [callback].
  Future<bool> startMonitor(Function callback) async {
    if (!monitorLoginMap.containsKey(_atsign)) {
      String privateKey = await getPrivateKey(_atsign);
      // ignore: await_only_futures
      await atClientServiceInstance.atClient
          .startMonitor(privateKey, callback);
      monitorLoginMap.putIfAbsent(_atsign, () => true);
      _logger.info('Monitor Started for $_atsign!');
    }
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.atClient
        .getPrivateKey(atsign)
        .timeout(Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
  }

  Future<List<String>> getAtsignList() async {
    var atSignsList = await atClientServiceInstance.getAtsignList();
    if(atSignsList == null) atSignsList = [];
    return atSignsList;
  }

  Future<bool> atsignIsPaired(String atsign) async {
    List<String> atsignList = await getAtsignList().timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => _onTimeOut());
    return atsignList.indexOf(atsign) >=0;
  }

  sync() async {
    if (_atClientPreference.syncStrategy == SyncStrategy.ONDEMAND) {
      await atClientServiceInstance.atClient.getSyncManager().sync();
    }
  }

  ///Throws [ResponseTimeOutException].
  _onTimeOut() {
    _logger.severe('Reponse Timed Out!');
    throw ResponseTimeOutException();
  }
}

class AtLoginNotification {
  String id;
  String requestorUrl;
  String challenge;
  String key;
  String value;
  String operation;
  int dateTime;

  AtLoginNotification({
        this.id,
        this.requestorUrl,
        this.challenge,
        this.key,
        this.value,
        this.dateTime,
        this.operation,
      });

  factory AtLoginNotification.fromJson(Map<String, dynamic> json) {
    return AtLoginNotification(
      id: json['id'],
      requestorUrl: json['from'],
      dateTime: json['epochMillis'],
      challenge: json['to'],
      key: json['key'],
      operation: json['operation'],
      value: json['value'],
    );
  }

  static List<AtLoginNotification> fromJsonList(
      List<Map<String, dynamic>> jsonList) {
    List<AtLoginNotification> notificationList = [];
    for (var json in jsonList) {
      notificationList.add(AtLoginNotification.fromJson(json));
    }
    return notificationList;
  }
}

