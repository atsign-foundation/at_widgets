import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';

class SDKService {
  static final KeyChainManager _keyChainManager = KeyChainManager.getInstance();
  Map<String, AtClientService>? atClientServiceMap = Map<String, AtClientService>();
  List<String>? atSignsList ;
  String? currentAtsign;
  String? lastOnboardedAtsign;
  Map<String, bool>? monitorConnectionMap = Map<String, bool>();

  static final SDKService _singleton = SDKService._internal();
  SDKService._internal();

  factory SDKService() {
    return _singleton;
  }

  ///Returns [atsign]'s atClient instance.
  ///If [atsign] is null then it will be current @sign.
  AtClientImpl? _getAtClientForAtsign({String? atsign}) {
    atsign ??= currentAtsign!;
    if (atClientServiceMap!.containsKey(atsign)) {
      return atClientServiceMap![atsign]!.atClient;
    }
    return null;
  }

  ///Fetches atsign from device keychain.
  Future<String?> getAtSign() async {
    return await _keyChainManager.getAtSign();
  }

  ///Deletes the [atsign] from device storage.
  Future<void> deleteAtSign(String atsign) async {
    await _keyChainManager.deleteAtSignFromKeychain(atsign);
    atClientServiceMap!.remove(atsign);
    monitorConnectionMap!.remove(atsign);
    if (atsign == currentAtsign) currentAtsign = null;
    if (atsign == lastOnboardedAtsign) lastOnboardedAtsign = null;
    atSignsList!.remove(atsign);
  }

  ///Returns list of atsigns stored in device storage.
  Future<List<String>?> getAtsignList() async {

      atSignsList = (await _keyChainManager.getAtSignListFromKeychain());
    return atSignsList ;
  }

  ///Makes [atsign] as primary in device storage and returns `true` for successful change.
  Future<bool> makeAtSignPrimary(String atsign) async {
    return await _keyChainManager.makeAtSignPrimary(atsign);
  }

  ///Returns `true` on updating [atKey] with [value] for current @sign.
  Future<bool?> put(AtKey atKey, dynamic value) async {
    return await _getAtClientForAtsign()?.put(atKey, value);
  }

  ///Returns `true` on deleting [atKey] for current @sign.
  Future<bool?> delete(AtKey atKey) async {
    return await _getAtClientForAtsign()?.delete(atKey);
  }

  ///Starts monitor for current @sign and accepts a [responseCallback].
  Future<bool> startMonitor(
    Function responseCallback,
  ) async {
    currentAtsign = await getAtSign();
    bool exist = monitorConnectionMap!.containsKey(currentAtsign);
    if (exist) {
      return true;
    }
    String? privateKey =
        await _getAtClientForAtsign()!.getPrivateKey(currentAtsign!);
    await _getAtClientForAtsign()!.startMonitor(privateKey!, responseCallback);
    monitorConnectionMap!.putIfAbsent(currentAtsign!, () => true);
    return true;
  }


  ///Resets [atsigns] list from device storage.
  Future<void> resetAtsigns(List<String> atsigns) async {
    for (String atsign in atsigns) {
      await _keyChainManager.resetAtSignFromKeychain(atsign);
      atClientServiceMap!.remove(atsign);
      monitorConnectionMap!.remove(atsign);
    }
    this.currentAtsign = null;
    this.lastOnboardedAtsign = null;
    this.atSignsList ;
  }

  ///Returns `true` if [atsign] is onboarded in the app.
  bool isOnboarded(String atsign) {
    return atClientServiceMap!.containsKey(atsign);
  }

  sync() async {
    await _getAtClientForAtsign()!.getSyncManager()!.sync();
  }

  // ///Returns `true` if [value] is a non empty string.
  // bool isValid(var value) {
  //   var result = value == null || value == '' || value == 'null';
  //   return !result;
  // }


  ///Returns null if [atsign] is null else the formatted [atsign].
  ///[atsign] must be non-null.
  String? formatAtSign(String atsign) {
    if (atsign == null) {
      return null;
    }
    atsign = atsign.trim().toLowerCase().replaceAll(' ', '');
    atsign = !atsign.startsWith('@') ? '@' + atsign : atsign;
    return atsign;
  }
}
