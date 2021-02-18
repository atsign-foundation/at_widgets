import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class MyLocation {
  MyLocation._();
  static final _instance = MyLocation._();
  factory MyLocation() => _instance;

  Future<LatLng> myLocation() async {
    Location _location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    LatLng myLocation;
    switch (AtLocationNotificationListener().currentAtSign) {
      case '@ashish🛠':
        {
          myLocation = LatLng(38, -122.406417);
          break;
        }
      case '@colin🛠':
        {
          myLocation = LatLng(39, -122.406417);
          break;
        }
      case '@bob🛠':
        {
          myLocation = LatLng(40, -122.406417);
          break;
        }
    }

    return myLocation;
    _locationData = await _location.getLocation();

    return LatLng(_locationData.latitude, _locationData.longitude);
  }
}
