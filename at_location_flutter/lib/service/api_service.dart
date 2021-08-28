import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>> getRequest(String url, [Map<String, String>? header]) async {
    bool val = await ConnectivityService().checkConnectivity();
    if (val) {
      return http.get(Uri.parse(url), headers: header).then((http.Response response) {
        int statusCode = response.statusCode;
        print(statusCode);
        if (statusCode == 200) {
          return <String, dynamic>{
            'status': true,
            'body': utf8.decode(response.bodyBytes),
            'message': 'success',
            'header': response.headers,
            'code': statusCode,
          };
        } else {
          return <String, dynamic>{
            'status': false,
            'body': response.body,
            'message': (response.statusCode == 404)
                ? 'Page not Found'
                : (response.statusCode == 401)
                    ? 'Unauthorized'
                    : 'Error occured while Fetching Data',
            'header': response.headers,
            'code': statusCode,
          };
        }
      });
    } else {
      return <String, dynamic>{
        'status': false,
        'message': 'No Internet',
      };
    }
  }

  Future<Map<String, dynamic>> postRequest(String url,
      {Map<String, String>? headers, dynamic body, dynamic encoding}) async {
    bool val = await ConnectivityService().checkConnectivity();
    if (val) {
      return http
          .post(Uri.parse(url), body: json.encode(body), headers: headers, encoding: encoding)
          .then((http.Response response) {
        int statusCode = response.statusCode;
        print(statusCode);
        if (statusCode == 200) {
          return <String, dynamic>{
            'status': true,
            'body': utf8.decode(response.bodyBytes),
            'message': 'success',
            'header': response.headers,
            'code': statusCode,
          };
        } else if (statusCode == 201) {
          return <String, dynamic>{
            'status': true,
            'body': response.body,
            'message': 'created',
            'header': response.headers,
            'code': statusCode,
          };
        } else {
          return <String, dynamic>{
            'status': false,
            'body': response.body,
            'message': (response.statusCode == 404)
                ? 'Page not Found'
                : (response.statusCode == 401)
                    ? 'Unauthorized'
                    : 'Error occured while Fetching Data',
            'header': response.headers,
            'code': statusCode,
          };
        }
      });
    } else {
      return <String, dynamic>{
        'status': false,
        'message': 'No Internet',
      };
    }
  }
}

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;

  Future<bool> checkConnectivity() async {
    Socket? socket;
    bool connectivity;
    await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    try {
      socket = await Socket.connect('google.com', 80, timeout: const Duration(seconds: 4));
      connectivity = true;
    } catch (e) {
      checkInternetConnection();
      connectivity = false;
    } finally {
      try {
        await socket?.close();
      } catch (e) {
        print(e);
      }
    }
    print('conn $connectivity');
    return connectivity;
  }

  void checkInternetConnection() {}
}
