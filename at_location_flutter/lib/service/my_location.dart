import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

/// Returns current [LatLng] of the device.
///
/// If location service is disabled or denied, returns null.
/// Else requests for permission and tries to return [LatLng] if permission granted.
Future<LatLng?> getMyLocation() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if ((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse)) {
      Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    }

    return null;
  } catch (e) {
    print('Error in getLocation $e');
    return null;
  }
}
