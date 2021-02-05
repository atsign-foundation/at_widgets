import 'dart:async';
import 'dart:convert';
import 'package:at_location_flutter/location_modal/location_modal.dart';
import 'package:http/http.dart' as http;

class SearchLocationService {
  SearchLocationService._();
  // ignore: prefer_final_fields
  static SearchLocationService _instance = SearchLocationService._();
  factory SearchLocationService() => _instance;

  final _atLocationStreamController =
      StreamController<List<LocationModal>>.broadcast();
  Stream<List<LocationModal>> get atLocationStream =>
      _atLocationStreamController.stream;
  StreamSink<List<LocationModal>> get atLocationSink =>
      _atLocationStreamController.sink;

  void getAddressLatLng(String address) async {
    //For maptiler
    //https://api.maptiler.com/geocoding/bokaro.json?key=B3Wus46C2WZFhwZKQkEx
    var url =
        "https://nominatim.openstreetmap.org/search?q=${address.replaceAll(RegExp(' '), '+')}&format=json&addressdetails=1";
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    List addresses = jsonDecode(response.body);
    List<LocationModal> share = [];
    for (Map ad in addresses) {
      share.add(LocationModal.fromJson(ad));
    }

    atLocationSink.add(share);
  }
}
