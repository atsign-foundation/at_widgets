import 'dart:convert';
import 'dart:math' as math;
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:crypto/crypto.dart';

import 'api_service.dart';

class DistanceCalculate {
  DistanceCalculate._();
  static final DistanceCalculate _instance = DistanceCalculate._();
  factory DistanceCalculate() => _instance;

  signature() async {
    String baseString =
        "grant_type=client_credentials&oauth_consumer_key=_YgpWGq1ckEcRmk8U1CuRA&oauth_nonce=LIIpk4&oauth_signature_method=HMAC-SHA256&oauth_timestamp=1456945283&oauth_version=1.0";
    baseString = 'POST&https://account.api.here.com/oauth2/token&${baseString}';
    String signing_key =
        'OHwhj9ljU7NFT16SUykayaioZMcX_gjv5cTUqSxZiUz8CKrGh7QmPMegRmz5gOX4R1WpUMGe0X2qP8WrVfjcGA&';
    String base64Key = 'DfeRt...';
    String message = 'blabla';

    List<int> messageBytes = utf8.encode(baseString);
    List<int> key = base64.decode(signing_key);
    Hmac hmac = new Hmac(sha256, key);
    Digest digest = hmac.convert(messageBytes);

    String signature = base64.encode(digest.bytes);
  }

  // getToken() async {
  //   String str =
  //       "grant_type=client_credentials&oauth_consumer_key=Kpcjef3oUIjxgpNYgAJSuA&oauth_nonce=LIIpk4&oauth_signature_method=HMAC-SHA256&oauth_timestamp=1456945283&oauth_version=1.0";
  //   // List<int> secretBytes = utf8.encode('secret');
  //   // var hmac = HMAC(Sha256, secretBytes);
  //   // var digest = hmac.close();

  //   // var hash = CryptoUtils.bytesToBase64(digest);
  //   String baseString =
  //       "grant_type=client_credentials&oauth_consumer_key=_YgpWGq1ckEcRmk8U1CuRA&oauth_nonce=LIIpk4&oauth_signature_method=HMAC-SHA256&oauth_timestamp=1456945283&oauth_version=1.0";
  //   baseString = 'POST&https://account.api.here.com/oauth2/token&${baseString}';
  //   String signing_key =
  //       'OHwhj9ljU7NFT16SUykayaioZMcX_gjv5cTUqSxZiUz8CKrGh7QmPMegRmz5gOX4R1WpUMGe0X2qP8WrVfjcGA&';
  //   String base64Key = 'DfeRt...';
  //   String message = 'blabla';

  //   List<int> messageBytes = utf8.encode(baseString + signing_key);
  //   // List<int> key = base64.decode(signing_key);
  //   Hmac hmac = new Hmac(baseString, signing_key);
  //   Digest digest = hmac.convert(messageBytes);

  //   String signature = base64.encode(digest.bytes);
  //   // different
  //   var url = 'https://account.api.here.com/oauth2/token';
  //   var response = await ApiService().postRequest(
  //     url,
  //     headers: {
  //       "oauth_consumer_key": "Kpcjef3oUIjxgpNYgAJSuA",
  //       // "oauth_nonce" : "<Random string, uniquely generated for each request>",
  //       "oauth_signature":
  //           "hTycqsBooWcbyGwM4efhq1vFHVROFR-at0akS-CFch6UhC5lanMxrC2IpnUAU-2wqLsirzySSQ0FnWFuajoqeg",
  //       "signature_method": "HMAC-SHA256",
  //       // "oauth_timestamp" : "<Epoch seconds>",
  //       "version": "1.0",
  //       "Content-Type": "application/x-www-form-urlencoded"
  //     },
  //     // encoding: "application/x-www-form-urlencoded"
  //   );

  //   print(response);
  // }

  Future<String> calculateETA(LatLng origin, LatLng destination) async {
    try {
      var url =
          'https://router.hereapi.com/v8/routes?transportMode=car&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&return=summary';
      var response = await ApiService().getRequest("$url", {
        "Authorization": "Bearer ${MixedConstants.BEARER_TOKEN}",
        "Content-Type": "application/json"
      });
      var data = response;
      data = jsonDecode(data['body']);
      var _min = (data['routes'][0]['sections'][0]['summary']['duration'] / 60);
      var _time = _min > 60
          ? '${((_min / 60).toStringAsFixed(0))}hr ${(_min % 60).toStringAsFixed(0)}min'
          : '${_min.toStringAsFixed(2)}min';

      return _time;
    } catch (e) {
      print(' error in ETA');
      return '?';
    }
  }
}
