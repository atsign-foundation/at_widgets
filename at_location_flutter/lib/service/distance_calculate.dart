import 'dart:convert';
import 'dart:math' as math;
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

  var bearerToken =
      "eyJhbGciOiJSUzUxMiIsImN0eSI6IkpXVCIsImlzcyI6IkhFUkUiLCJhaWQiOiJNejdBcWJxakp1aGlMaFV2Q1hUOCIsImlhdCI6MTYxMTIzNjQ5MCwiZXhwIjoxNjExMzIyODkwLCJraWQiOiJqMSJ9.ZXlKaGJHY2lPaUprYVhJaUxDSmxibU1pT2lKQk1qVTJRMEpETFVoVE5URXlJbjAuLjlxb0Z0WFNsWlQteFV5dmdGQ3V0N2cuOC11UXp4a3VVbWZqV25HZGxmaC1XSHlxOFRMZkd5ekdNZThtdHZNalM4M3YzSVc4R1ptc0k2VDZJTUNiZTdWdXZ6Rm4talZEYnhyc0ZxTGxqaWtfbFJudE5nMndiY2hXNnYzeVY4bV9tQzRxVW1GSnRwMXhuRkFtWVBhbTI5NE9JcTA4MGtySHNGcnBtLTJNN2c5NjlBLm5pMm1NVkhsaWJPbFJ6RmtZUXJwM1hUVFRoM3k3SGNJc2pGenRaRlZWNnM.MOITgO01le_3DyEF-1Vk9bn_ZQbc8lWM1g2n_7p9Qkhi8Us0_0l-r-P-KsxNcDywPPbGipaFsXsqyXtnyGO44X7gDUOdk-3ztRMjeLx_eOt8CD-ULlF-0zW5WyBUkySfD08Kau33UhOKBgRr2x6leHFCsDvYHrfQRWPpbOdWOrMji40lfmWsS43YHeflyFlVwNUNVNQmjAODPTFlG_KNRx_thJ8QVukp95BeVW1nDKFpxwjyGWZpRk99-Njsydph1N2jtq_wxrxoWN41UiVxShu5cifIrgXRDmdeLaPXzJnKIWbgTF3q9RtpH_BbXm4MzIk7SZAGFSWK8NLVTvZjdg";

  // the url gives { "message": "Invalid coordinate value.", "code": "InvalidValue"} if any point is greater than 90
  // but here last urls value is stored somehow
  Future<String> caculateETA(LatLng origin, LatLng destination) async {
    try {
      var url =
          'https://router.hereapi.com/v8/routes?transportMode=car&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&return=summary';
      var response = await ApiService().getRequest("$url", {
        "Authorization": "Bearer $bearerToken",
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
