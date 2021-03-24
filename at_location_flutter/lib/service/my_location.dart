import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';

Future<LatLng> getMyLocation() async {
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
  Position position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
}
