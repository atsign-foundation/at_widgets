import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_follows_flutter_example/services/notification_service.dart';
import 'package:at_follows_flutter_example/utils/app_constants.dart';
import 'package:at_utils/at_logger.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:at_commons/at_commons.dart' as at_commons;

class AtService {
  static final AtService _singleton = AtService._internal();

  AtService._internal();
  final AtSignLogger _logger = AtSignLogger('AtService');

  factory AtService.getInstance() {
    return _singleton;
  }

  String _atsign;

  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  Function monitorCallBack;

  Future<AtClientPreference> getAtClientPreference({String cramSecret}) async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..cramSecret = cramSecret
      ..namespace = AppConstants.appNamespace
      ..syncStrategy = SyncStrategy.ONDEMAND
      ..rootDomain = 'root.atsign.wtf'
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  Future<bool> put({String key, var value}) async {
    var atKey = at_commons.AtKey()..key = key;
    // ..metadata = metaData;
    return await atClientInstance.put(atKey, value);
  }

  Future<bool> delete({String key}) async {
    var atKey = at_commons.AtKey()..key = key;
    return await atClientInstance.delete(atKey);
  }

  Future<List<String>> get() async {
    return await atClientInstance.getKeys(regex: AppConstants.regex);
  }

  _sync() async {
    await atClientInstance.getSyncManager().sync();
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await atClientServiceInstance.getPublicKey(atsign);
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await atClientServiceInstance.getAtSign();
  }

  ///Fetches atsign list from device keychain.
  Future<List<String>> getAtSignList() async {
    return await atClientServiceInstance.getAtsignList();
  }

  Future<void> deleteAtsign(String atsign) async {
    return await atClientServiceInstance.deleteAtSignFromKeychain(atsign);
  }

  // startMonitor needs to be called at the beginning of session
  Future<bool> startMonitor() async {
    _atsign = await getAtSign();
    String privateKey = await getPrivateKey(_atsign);
    await atClientInstance.startMonitor(privateKey, (response) {
      acceptStream(response);
    });
    print("Monitor started");
    return true;
  }

  acceptStream(response) async {
    response = response.toString().replaceAll('notification:', '').trim();
    var notification = AtNotification.fromJson(jsonDecode(response));
    await NotificationService().showNotification(notification);
  }
}

class AtNotification {
  String id;
  String from;
  String to;
  String key;
  String value;
  String operation;
  int dateTime;

  AtNotification(
      {this.id,
      this.from,
      this.to,
      this.key,
      this.value,
      this.dateTime,
      this.operation});

  // AtNotification();

  factory AtNotification.fromJson(Map<String, dynamic> json) {
    return AtNotification(
      id: json['id'],
      from: json['from'],
      dateTime: json['epochMillis'],
      to: json['to'],
      key: json['key'],
      operation: json['operation'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'epochMillis': dateTime,
      'key': key,
      'operation': operation,
      'value': value
    };
  }
}
