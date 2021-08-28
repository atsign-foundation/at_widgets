import 'dart:async';
import 'dart:convert';
import 'package:at_location_flutter/location_modal/location_modal.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

class SearchLocationService {
  SearchLocationService._();
  // ignore: prefer_final_fields
  static SearchLocationService _instance = SearchLocationService._();
  factory SearchLocationService() => _instance;

  final StreamController<List<LocationModal>> _atLocationStreamController =
      StreamController<List<LocationModal>>.broadcast();
  Stream<List<LocationModal>> get atLocationStream => _atLocationStreamController.stream;
  StreamSink<List<LocationModal>> get atLocationSink => _atLocationStreamController.sink;

  void dispose() {
    _atLocationStreamController.close();
  }

  /// Adds location matching to [address] to [atLocationSink].
  /// If [currentLocation] is passed then will add locations nearby the [currentLocation].
  ///
  /// Make sure that [apiKey] is passed while initialising.
  Future<void> getAddressLatLng(String address, LatLng? currentLocation) async {
    String? url;
    if (currentLocation != null) {
      url =
          'https://geocode.search.hereapi.com/v1/geocode?q=${address.replaceAll(RegExp(' '), '+')}&apiKey=${MixedConstants.API_KEY}&at=${currentLocation.latitude},${currentLocation.longitude}';
    } else {
      url =
          'https://geocode.search.hereapi.com/v1/geocode?q=${address.replaceAll(RegExp(' '), '+')}&apiKey=${MixedConstants.API_KEY}';
    }
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> addresses = jsonDecode(response.body);
    List<dynamic> data = addresses['items'];
    List<LocationModal> share = <LocationModal>[];
    //// Removed because of nulls safety
    // for (Map ad in data ?? []) {
    for (Map<String, dynamic> ad in data) {
      share.add(LocationModal.fromJson(ad));
    }

    atLocationSink.add(share);
  }
}
