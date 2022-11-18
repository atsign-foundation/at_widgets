// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
import 'package:at_utils/at_logger.dart';
import 'package:location/location.dart';

/// Returns current [LatLng] of the device.
///
/// If location service is disabled or denied, returns null.
/// Else requests for permission and tries to return [LatLng] if permission granted.
Future<LatLng?> getMyLocation() async {
  final _logger = AtSignLogger('getMyLocation');

  try {
    Location location = Location();

    var _permission = await isLocationServiceEnabled();

    if(_permission){
      var _locationData = await location.getLocation();
      return LatLng(_locationData.latitude!, _locationData.longitude!);
    }

    return null;
  } catch (e) {
    _logger.severe('Error in getLocation $e');
    return null;
  }
}

/// checks if location service is enabled.
Future<bool> isLocationServiceEnabled() async {
  final _logger = AtSignLogger('isLocationServiceEnabled');

  try {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  } catch (e) {
    return false;
  }
}

/// Returns current [LatLng] of the device without checking for permissions.
/// Use this function when it is known that location permission is enabled.
Future<LatLng?> getCurrentPosition() async {
  final _logger = AtSignLogger('getCurrentPosition');

  try {
    var _locationData = await Location().getLocation();
    return LatLng(_locationData.latitude!, _locationData.longitude!);
  } catch (e) {
    _logger.severe('$e');
    return null;
  }
}
