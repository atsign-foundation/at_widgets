import 'dart:async';
import 'package:flutter/material.dart';
import 'package:atsign_authentication_helper/screens/private_key_qrcode_generator.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

class AuthenticationService {
  static final AuthenticationService _singleton =
      AuthenticationService._internal();
  AuthenticationService._internal();

  factory AuthenticationService.getInstance() {
    return _singleton;
  }

  AtClientService atClientServiceInstance;
  set setAtClientServiceInstance(AtClientService instance) {
    atClientServiceInstance = instance;
  }

  AtClientPreference atClientPreference;
  set setAtClientPreference(AtClientPreference preference) {
    atClientPreference = preference;
  }

  String _atsign;
  String get currentAtsign => _atsign;
  final String AUTH_SUCCESS = 'Authentication successful';

  // next route set from using app
  Widget _nextScreen;
  set setNextScreen(Widget nextScreen) {
    _nextScreen = nextScreen;
  }

  Widget get nextScreen => _nextScreen;

  // QR code scan
  Future authenticate(String qrCodeString, BuildContext context) async {
    var c = Completer();
    if (qrCodeString.contains('@')) {
      try {
        var params = qrCodeString.split(':');
        if (params?.length == 2) {
          await authenticateWithCram(params[0], cramSecret: params[1]);
          _atsign = params[0];
          c.complete(AUTH_SUCCESS);
          await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => PrivateKeyQRCodeGenScreen()));
        }
      } catch (e) {
        print('error in authenticating =>  ${e.toString()}');
        c.complete('Failed to Authenticate');
        print(e);
      }
    } else {
      // wrong bar code
      c.complete('incorrect QR code');
      print('incorrect QR code');
    }
    return c.future;
  }

  // first time setup with cram authentication
  Future<bool> authenticateWithCram(String atsign, {String cramSecret}) async {
    atClientPreference.cramSecret = cramSecret;
    var result =
        await atClientServiceInstance.authenticate(atsign, atClientPreference);
    return result;
  }

  Future<bool> authenticateWithAESKey(String atsign,
      {String cramSecret, String jsonData, String decryptKey}) async {
    atClientPreference.cramSecret = cramSecret;
    var result = await atClientServiceInstance.authenticate(
        atsign, atClientPreference,
        jsonData: jsonData, decryptKey: decryptKey);
    _atsign = atsign;
    return result;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await atClientServiceInstance.getAtSign();
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await atClientServiceInstance.getPublicKey(atsign);
  }

  Future<String> getAESKey(String atsign) async {
    return await atClientServiceInstance.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    return await atClientServiceInstance.getEncryptedKeys(atsign);
  }
}
