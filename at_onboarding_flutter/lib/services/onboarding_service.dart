import 'dart:async';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart';

class OnboardingService {
  static final OnboardingService _singleton = OnboardingService._internal();

  OnboardingService._internal();
  factory OnboardingService.getInstance() {
    return _singleton;
  }

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  AtSignLogger _logger = AtSignLogger('Onboarding Service');

  Map<String?, AtClientService> atClientServiceMap = {};
  String? _atsign;
  AtClientPreference _atClientPreference = AtClientPreference();

  String? _namespace;
  Widget? _applogo;
  bool? _isPkam;
  late Function onboardFunc;

  ServerStatus? serverStatus;

  set setLogo(Widget? logo) => _applogo = logo;
  get logo => _applogo;

  get isPkam => _isPkam;

  set setAtClientPreference(AtClientPreference _preference) {
    _atClientPreference = _preference
      ..cramSecret = null
      ..privateKey = null;
  }

  get atClientPreference => _atClientPreference;

  set namespace(String namespace) => _namespace = namespace;
  get appNamespace => _namespace;
  set setAtsign(String? atsign) {
    atsign = formatAtSign(atsign);
    _atsign = atsign;
  }

  String? get currentAtsign => _atsign;

  // next route set from using app
  Widget? _nextScreen;
  set setNextScreen(Widget? nextScreen) {
    _nextScreen = nextScreen;
  }

  Widget? fistTimeAuthScreen;

  Widget? get nextScreen => _nextScreen;

  AtClientService? _getClientServiceForAtsign(String? atsign) {
    if (atClientServiceMap.containsKey(atsign)) {
      return atClientServiceMap[atsign];
    }
    var service = AtClientService();
    return service;
  }

  AtClientImpl? _getAtClientForAtsign({String? atsign}) {
    atsign ??= _atsign;
    if (atClientServiceMap.containsKey(atsign)) {
      return atClientServiceMap[atsign]!.atClient as AtClientImpl?;
    }
    return null;
  }

  ///Fetches atsign from device keychain.
  Future<String?> getAtSign() async {
    return await _keyChainManager.getAtSign();
  }

  ///Returns `true` if authentication is successful for the existing atsign in device.
  Future<bool> onboard() async {
    var atClientServiceInstance = _getClientServiceForAtsign(_atsign)!;
    var result = await atClientServiceInstance.onboard(
        atClientPreference: _atClientPreference, atsign: _atsign);
    if (_atsign == null) {
      _atsign = await this.getAtSign();
    }
    atClientServiceMap.putIfAbsent(_atsign, () => atClientServiceInstance);
    _sync();
    return result;
  }

  ///Returns `false` if fails in authenticating [atsign] with [cramSecret]/[privateKey].
  ///Throws Excpetion if atsign is null.
  Future authenticate(String? atsign,
      {String? cramSecret,
      String? jsonData,
      String? decryptKey,
      OnboardingStatus? status}) async {
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
      var atClientService = _getClientServiceForAtsign(atsign)!;
      _atClientPreference..cramSecret = cramSecret;
      if (cramSecret != null) {
        _atClientPreference..privateKey = null;
      }
      await atClientService
          .authenticate(atsign, _atClientPreference,
              jsonData: jsonData, decryptKey: decryptKey, status: status)
          .then((value) async {
        _atsign = atsign;
        atClientServiceMap.putIfAbsent(_atsign, () => atClientService);
        c.complete(ResponseStatus.AUTH_SUCCESS);
        await _sync();
      });
    } catch (e) {
      _logger.severe("error in authenticating =>  ${e.toString()}");
      if (e == ResponseStatus.TIME_OUT) {
        c.completeError(e);
      } else {
        c.completeError(
            e.runtimeType == OnboardingStatus ? e : ResponseStatus.AUTH_FAILED);
      }
    }
    return c.future;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return await atClientServiceMap[atsign]!.getPkamPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String?> getPublicKey(String atsign) async {
    return await atClientServiceMap[atsign]!.getPkamPublicKey(atsign);
  }

  Future<String?> getAESKey(String atsign) async {
    return await atClientServiceMap[atsign]!.getAESKey(atsign);
  }

  Future<Map<String, String?>> getEncryptedKeys(String atsign) async {
    Map<String, String?> result =
        await atClientServiceMap[atsign]!.getEncryptedKeys(atsign);
    result[atsign] = await this.getAESKey(atsign);
    return result;
  }

  ///Returns null if [atsign] is null else the formatted [atsign].
  ///[atsign] must be non-null.
  String? formatAtSign(String? atsign) {
    if (atsign == null || atsign == '') {
      return null;
    }
    atsign = atsign.trim().toLowerCase().replaceAll(' ', '');
    atsign = !atsign.startsWith('@') ? '@' + atsign : atsign;
    return atsign;
  }

  Future<bool?> isExistingAtsign(String? atsign) async {
    if (atsign == null) {
      return null;
    }
    atsign = this.formatAtSign(atsign);
    var atSignsList = await getAtsignList();
    var status = await _checkAtSignServerStatus(atsign!).timeout(
        Duration(seconds: AppConstants.responseTimeLimit),
        onTimeout: () => throw ResponseStatus.TIME_OUT);
    var isExist = atSignsList != null ? atSignsList.contains(atsign) : false;
    if (status == ServerStatus.teapot) {
      isExist = false;
    }
    return isExist;
  }

  Future<List<String>?> getAtsignList() async {
    var atSignsList = await _keyChainManager.getAtSignListFromKeychain();
    return atSignsList;
  }

  Future<ServerStatus?> _checkAtSignServerStatus(String atsign) async {
    var atStatusImpl = AtStatusImpl(rootUrl: AppConstants.serverDomain);
    var status = await atStatusImpl.get(atsign);
    return status.serverStatus;
  }

  Future<AtSignStatus?> checkAtsignStatus({String? atsign}) async {
    atsign = atsign ?? this._atsign;
    if (atsign == null) {
      return null;
    }
    atsign = this.formatAtSign(atsign);
    var atStatusImpl = AtStatusImpl(rootUrl: AppConstants.serverDomain);
    var status = await atStatusImpl.get(atsign!);
    return status.status();
  }

  _sync() async {
    if (_atClientPreference.syncStrategy == SyncStrategy.ONDEMAND) {
      await _getAtClientForAtsign()!.getSyncManager()!.sync();
    }
  }
}
