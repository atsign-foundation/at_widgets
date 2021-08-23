import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:http/io_client.dart';

class FreeAtsignService {
  static final freeAtsignService = FreeAtsignService._internal();
  FreeAtsignService._internal() {
    _init();
  }

  factory FreeAtsignService() => freeAtsignService;

  late var _http;
  bool initialized = false;

  _init() {
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    _http = new IOClient(ioc);
    initialized = true;
  }

  //To login with an @sign
  Future<dynamic> loginWithAtsign(String atsign) async {
    // if init was not called earlier, call here to initialize the http
    if (!initialized) {
      _init();
    }
    Map data = {'atsign': "$atsign"};

    String path = AppConstants.apiPath + AppConstants.authWithAtsign;

    var response = await postRequest(path, data);

    return response;
  }

  //validating atsign with verification code
  Future<dynamic> verificationWithAtsign(
      String atsign, String verificationCode) async {
    // if init was not called earlier, call here to initialize the http
    if (!initialized) {
      _init();
    }
    String path = AppConstants.apiPath + AppConstants.validationWithAtsign;
    Map data = {'atsign': "$atsign", 'otp': "$verificationCode"};

    var response = await postRequest(path, data);

    return response;
  }

//To get free @sign from the server
  Future<dynamic> getFreeAtsigns() async {
    // if init was not called earlier, call here to initialize the http
    if (!initialized) {
      _init();
    }
    var url = Uri.https(AppConstants.apiEndPoint,
        '${AppConstants.apiPath}${AppConstants.getFreeAtsign}');

    var response = await _http.get(url, headers: {
      "Authorization": '${AppConstants.apiKey}',
      "Content-Type": "application/json"
    });

    return response;
  }

//To register the person with the provided atsign and email
//It will send an OTP to the registered email
  Future<dynamic> registerPerson(String atsign, String email,
      {String? oldEmail}) async {
    if (!initialized) {
      _init();
    }
    Map data;
    String path = AppConstants.apiPath + AppConstants.registerPerson;
    if (oldEmail != null) {
      data = {'email': '$email', 'atsign': "$atsign", 'oldEmail': '$oldEmail'};
    } else {
      data = {'email': '$email', 'atsign': "$atsign"};
    }

    var response = await postRequest(path, data);
    return response;
  }

//It will validate the person with atsign, email and the OTP.
//If the validation is successful, it will return a cram secret for the user to login
  Future<dynamic> validatePerson(String atsign, String email, String? otp,
      {bool confirmation = false}) async {
    if (!initialized) {
      _init();
    }
    Map data;
    String path = AppConstants.apiPath + AppConstants.validatePerson;
    data = {
      'email': '$email',
      'atsign': "$atsign",
      'otp': '$otp',
      'confirmation': confirmation
    };
    var response = await postRequest(path, data);

    return response;
  }

  // common POST request call
  Future<dynamic> postRequest(String path, Map data) async {
    var url = Uri.https(AppConstants.apiEndPoint, '$path');

    String body = json.encode(data);
    return _http.post(url, body: body, headers: {
      'Authorization': '${AppConstants.apiKey}',
      'Content-Type': 'application/json'
    });
  }
}
