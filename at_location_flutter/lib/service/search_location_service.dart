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
    var url =
        "https://nominatim.openstreetmap.org/search?q=${address.replaceAll(RegExp(' '), '+')}&format=json&addressdetails=1";
    var response = await http.get(Uri.parse(url));

    List addresses = jsonDecode(response.body);
    var share = <LocationModal>[];
    for (Map ad in addresses) {
      share.add(LocationModal.fromJson(ad));
    }

    atLocationSink.add(share);
  }
}
