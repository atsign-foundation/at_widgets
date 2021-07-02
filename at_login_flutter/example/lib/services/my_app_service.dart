import 'dart:convert';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_login_flutter_example/services/notification_service.dart';
import 'package:at_login_flutter_example/utils/app_constants.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class MyAppService {
  static final MyAppService _singleton = MyAppService._internal();

  MyAppService._internal();

  factory MyAppService.getInstance() {
    return _singleton;
  }

  String _atsign;

  AtClientService atClientServiceInstance = AtClientService();
  AtClientImpl atClientInstance;
  Function monitorCallBack;
  Map<String, AtClientService> atClientServiceMap = {};
  AtClientPreference _atClientPreference;

  Future<AtClientPreference> getAtClientPreference({String cramSecret}) async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..cramSecret = cramSecret
      ..namespace = AppConstants.appNamespace
      ..syncStrategy = SyncStrategy.ONDEMAND
      ..rootDomain = AppConstants.rootDomain
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  AtClientImpl getAtClientForAtsign({String atsign}) {
    atsign ??= _atsign;
    return AtClientImpl(atsign, AppConstants.appNamespace, _atClientPreference);
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
    // ignore: await_only_futures
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
