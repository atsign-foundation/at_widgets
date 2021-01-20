import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class OnboardingService {
  static final OnboardingService _singleton = OnboardingService._internal();

  OnboardingService._internal();
  factory OnboardingService.getInstance() {
    return _singleton;
  }

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();

  // AtClientService atClientServiceInstance;

  Map<String, AtClientService> atClientServiceMap = {};
  String _atsign;
  String _namespace;
  Widget _applogo;
  bool _isPkam;
  Function onboardFunc;

  ServerStatus serverStatus;

  set setLogo(Widget logo) => _applogo = logo;
  get logo => _applogo;

  get isPkam => _isPkam;

  set namespace(String namespace) => _namespace = namespace;
  get appNamespace => _namespace;
  String get currentAtsign => _atsign;

  // next route set from using app
  Widget _nextScreen;
  set setNextScreen(Widget nextScreen) {
    _nextScreen = nextScreen;
  }

  Widget get nextScreen => _nextScreen;
  // final String authSuccess = "Authentication successful";

  AtClientService _getClientServiceForAtsign(String atsign) {
    if (atsign == null) {}
    if (atClientServiceMap.containsKey(atsign)) {
      return atClientServiceMap[atsign];
    }
    var service = AtClientService();
    return service;
  }

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

  Future<AtClientPreference> _getAtClientPreference({String cramSecret}) async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..cramSecret = cramSecret
      ..namespace = _namespace
      ..syncStrategy = SyncStrategy.ONDEMAND
      ..rootDomain = AppConstants.serverDomain
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  ///Returns `true` if authentication is successful for the existing atsign in device.
  Future<bool> onboard({String atsign}) async {
    var atClientServiceInstance = _getClientServiceForAtsign(atsign);
    var _atClientPreference = await _getAtClientPreference();
    var result = await atClientServiceInstance.onboard(
        atClientPreference: _atClientPreference, atsign: atsign);
    _atsign = atsign == null ? await this.getAtSign() : atsign;
    atClientServiceMap.putIfAbsent(_atsign, () => atClientServiceInstance);
    onboardFunc(this.atClientServiceMap);
    _sync();
    return result;
  }

  ///Returns `false` if fails in authenticating [atsign] with [cramSecret]/[privateKey].
  ///Throws Excpetion if atsign is null.
  Future authenticate(String atsign,
      {String cramSecret,
      String jsonData,
      String decryptKey,
      OnboardingStatus status}) async {
    _isPkam = false;
    atsign = formatAtSign(atsign);
    if (atsign == null) {
      throw '@sign cannot be null';
    }
    Completer c = Completer();
    try {
      serverStatus = await _checkAtSignServerStatus(atsign);
      if (serverStatus != ServerStatus.teapot &&
          serverStatus != ServerStatus.activated) {
        c.complete(ResponseStatus.SERVER_NOT_REACHED);
        if (cramSecret == null) {
          _isPkam = true;
        }
        return c.future;
      }
      var atClientService = _getClientServiceForAtsign(atsign);
      var _atClientPreference =
          await _getAtClientPreference(cramSecret: cramSecret);
      await atClientService.authenticate(atsign, _atClientPreference,
          jsonData: jsonData, decryptKey: decryptKey, status: status);
      _atsign = atsign;
      atClientServiceMap.putIfAbsent(_atsign, () => atClientService);
      onboardFunc(this.atClientServiceMap);
      c.complete(ResponseStatus.AUTH_SUCCESS);
      await _sync();
      // return result;
    } catch (e) {
      print("error in authenticating =>  ${e.toString()}");
      c.complete(ResponseStatus.AUTH_FAILED);
      print(e);
    }
    return c.future;
  }

  // // QR code scan
  // Future authenticate(String qrCodeString, BuildContext context) async {
  //   Completer c = Completer();
  //   if (qrCodeString.contains('@')) {
  //     try {
  //       List<String> params = qrCodeString.split(':');
  //       if (params?.length == 2) {
  //         await authenticateWithCram(params[0], cramSecret: params[1]);
  //         _atsign = params[0];
  //         c.complete(authSuccess);
  //         await Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => PrivateKeyQRCodeGenScreen()));
  //       }
  //     } catch (e) {
  //       print("error in authenticating =>  ${e.toString()}");
  //       c.complete('Failed to Authenticate');
  //       print(e);
  //     }
  //   } else {
  //     // wrong Qr code
  //     c.complete("incorrect QR code");
  //     print("incorrect QR code");
  //   }
  //   return c.future;
  // }

  // // first time setup with cram authentication
  // Future<bool> authenticateWithCram(String atsign, {String cramSecret}) async {
  //   var result = await atClientServiceInstance.authenticate(atsign,
  //       cramSecret: cramSecret);
  //   return result;
  // }

  ///authenticates by restoring a backup zip file.
  Future<bool> authenticateWithAESKey(String atsign,
      {String jsonData, String decryptKey}) async {
    var atClientService = _getClientServiceForAtsign(atsign);
    var _atClientPreference = await _getAtClientPreference();
    var result = await atClientService.authenticate(atsign, _atClientPreference,
        jsonData: jsonData, decryptKey: decryptKey);
    _atsign = atsign;
    return result;
  }

  // ///Fetches atsign from device keychain.
  // Future<String> getAtSign() async {
  //   return await atClientServiceInstance.getAtSign();
  // }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceMap[atsign].getPkamPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await atClientServiceMap[atsign].getPkamPublicKey(atsign);
  }

  Future<String> getAESKey(String atsign) async {
    return await atClientServiceMap[atsign].getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    var result = await atClientServiceMap[atsign].getEncryptedKeys(atsign);
    result[atsign] = await this.getAESKey(atsign);
    return result;
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

  Future<bool> isExistingAtsign(String atsign) async {
    var atSignsList = await getAtsignList();
    var status = await _checkAtSignServerStatus(atsign);
    var isExist = atSignsList != null ? atSignsList.contains(atsign) : false;
    if (status == ServerStatus.teapot) {
      isExist = false;
    }
    return isExist;
  }

  Future<List<String>> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList;
  }

  Future<ServerStatus> _checkAtSignServerStatus(String atsign) async {
    var atStatusImpl = AtStatusImpl(rootUrl: AppConstants.serverDomain);
    var status = await atStatusImpl.get(atsign);
    return status.serverStatus;
  }

  Future<AtSignStatus> checkAtsignStatus(String atsign) async {
    atsign = this.formatAtSign(atsign);
    var atStatusImpl = AtStatusImpl(rootUrl: AppConstants.serverDomain);
    var status = await atStatusImpl.get(atsign);
    return status.status();
  }

  _sync() async {
    await _getAtClientForAtsign().getSyncManager().sync();
  }
}
