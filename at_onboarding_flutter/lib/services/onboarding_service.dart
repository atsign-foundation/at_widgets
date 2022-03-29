import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/material.dart';

/// Service to handle onboarding flow
class OnboardingService {
  static final OnboardingService _singleton = OnboardingService._internal();

  OnboardingService._internal();
  factory OnboardingService.getInstance() {
    return _singleton;
  }

  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  final AtSignLogger _logger = AtSignLogger('Onboarding Service');

  Map<String?, AtClientService> atClientServiceMap =
      <String?, AtClientService>{};
  String? _atsign;
  AtClientPreference _atClientPreference = AtClientPreference();

  String? _namespace;
  Widget? _applogo;
  bool? _isPkam;
  late Function onboardFunc;

  ServerStatus? serverStatus;

  set setLogo(Widget? logo) => _applogo = logo;
  Widget? get logo => _applogo;

  bool? get isPkam => _isPkam;

  set setAtClientPreference(AtClientPreference preference) {
    _atClientPreference = preference
      ..cramSecret = null
      ..privateKey = null;
  }

  AtClientPreference get atClientPreference => _atClientPreference;

  set namespace(String namespace) => _namespace = namespace;
  String? get appNamespace => _namespace;
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
    AtClientService service = AtClientService();
    return service;
  }

  /// Fetches atsign from device keychain.
  Future<String?> getAtSign() async {
    return _keyChainManager.getAtSign();
  }

  ///
  Future<bool?> isUsingSharedStorage() async {
    final result = await _keyChainManager.isUsingSharedStorage();
    return result;
  }

  ///Call this function before start onboarding
  Future<void> initialSetup({required bool usingSharedStorage}) async {
    await _keyChainManager.initialSetup(useSharedStorage: usingSharedStorage);
  }

  /// Returns `true` if authentication is successful for the existing atsign in device.
  Future<bool> onboard() async {
    AtClientService atClientServiceInstance =
        _getClientServiceForAtsign(_atsign)!;
    bool result = await atClientServiceInstance.onboard(
        atClientPreference: _atClientPreference, atsign: _atsign);
    _atsign ??= await getAtSign();
    atClientServiceMap.putIfAbsent(_atsign, () => atClientServiceInstance);
    await _sync(_atsign);
    return result;
  }

  /// Returns `false` if fails in authenticating [atsign] with [cramSecret]/[privateKey].
  /// Throws Excpetion if atsign is null.
  Future<dynamic> authenticate(String? atsign,
      {String? cramSecret,
      String? jsonData,
      String? decryptKey,
      OnboardingStatus? status}) async {
    _isPkam = false;
    atsign = formatAtSign(atsign);
    if (atsign == null) {
      throw '@sign cannot be null';
    }
    Completer<dynamic> c = Completer<dynamic>();
    try {
      serverStatus = await _checkAtSignServerStatus(atsign);
      if (serverStatus != ServerStatus.teapot &&
          serverStatus != ServerStatus.activated) {
        c.complete(AtOnboardingResponseStatus.serverNotReached);
        if (cramSecret == null) {
          _isPkam = true;
        }
        return c.future;
      }
      AtClientService atClientService = _getClientServiceForAtsign(atsign)!;
      _atClientPreference.cramSecret = cramSecret;
      if (cramSecret != null) {
        _atClientPreference.privateKey = null;
      }
      bool isAuthenticated = await atClientService.authenticate(
          atsign, _atClientPreference,
          jsonData: jsonData, decryptKey: decryptKey, status: status);
      if (isAuthenticated) {
        _atsign = atsign;
        atClientServiceMap.putIfAbsent(_atsign, () => atClientService);
        c.complete(AtOnboardingResponseStatus.authSuccess);
        await _sync(_atsign);
      }
    } catch (e) {
      _logger.severe('error in authenticating =>  ${e.toString()}');
      if (e == AtOnboardingResponseStatus.timeOut) {
        c.completeError(e);
      } else {
        c.completeError(
            e.runtimeType == OnboardingStatus ? e : AtOnboardingResponseStatus.authFailed);
      }
    }
    return c.future;
  }

  /// Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return KeychainUtil.getPkamPrivateKey(atsign);
  }

  /// Fetches publickey for [atsign] from device keychain.
  Future<String?> getPublicKey(String atsign) async {
    return KeychainUtil.getPkamPublicKey(atsign);
  }

  /// Fetches AESkey for [atsign] from device keychain.
  Future<String?> getAESKey(String atsign) async {
    return KeychainUtil.getAESKey(atsign);
  }

  /// Fetches encryption keys for [atsign] from device keychain.
  Future<Map<String, String?>> getEncryptedKeys(String atsign) async {
    Map<String, String?> result = await KeychainUtil.getEncryptedKeys(atsign);
    result[atsign] = await getAESKey(atsign);
    return result;
  }

  /// Returns null if [atsign] is null else the formatted [atsign].
  /// [atsign] must be non-null.
  String? formatAtSign(String? atsign) {
    if (atsign == null || atsign == '') {
      return null;
    }
    atsign = atsign.trim().toLowerCase().replaceAll(' ', '');
    atsign = !atsign.startsWith('@') ? '@$atsign' : atsign;
    return atsign;
  }

  Future<bool> isExistingAtsign(String? atsign) async {
    if (atsign == null) {
      return false;
    }
    atsign = formatAtSign(atsign);
    List<String> atSignsList = await getAtsignList();
    ServerStatus? status = await _checkAtSignServerStatus(atsign!).timeout(
        Duration(seconds: AtOnboardingConstants.responseTimeLimit),
        onTimeout: () => throw AtOnboardingResponseStatus.timeOut);
    bool isExist =
        atSignsList.isNotEmpty ? atSignsList.contains(atsign) : false;
    if (status == ServerStatus.teapot) {
      isExist = false;
    }
    return isExist;
  }

  /// returns the list of all onboarded atsigns
  Future<List<String>> getAtsignList() async {
    List<String>? atSignsList =
        await _keyChainManager.getAtSignListFromKeychain();
    atSignsList == null ? atSignsList = <String>[] : atSignsList = atSignsList;
    return atSignsList;
  }

  Future<ServerStatus?> _checkAtSignServerStatus(String atsign) async {
    AtStatusImpl atStatusImpl =
        AtStatusImpl(rootUrl: AtOnboardingConstants.serverDomain);
    AtStatus status = await atStatusImpl.get(atsign);
    return status.serverStatus;
  }

  /// Returns the status of an atsign
  Future<AtSignStatus?> checkAtsignStatus({String? atsign}) async {
    atsign = atsign ?? _atsign;
    if (atsign == null) {
      return null;
    }
    atsign = formatAtSign(atsign);
    AtStatusImpl atStatusImpl =
        AtStatusImpl(rootUrl: AtOnboardingConstants.serverDomain);
    AtStatus status = await atStatusImpl.get(atsign!);
    return status.status();
  }

  /// Function to make the atsign passed as primary
  Future<bool> changePrimaryAtsign({required String atsign}) async {
    final result = await _keyChainManager.makeAtSignPrimary(atsign);
    if (result == true) {
      setAtsign = atsign;
    }
    return result;
  }

  /// sync call to get data from secondary
  Future<void> _sync(String? atSign) async {
    _getClientServiceForAtsign(atSign)!.atClientManager.syncService.sync();
  }
}
