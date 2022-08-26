import 'package:at_location_flutter/service/my_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

Position get mockPosition => Position(
    latitude: 52.561270,
    longitude: 5.639382,
    timestamp: DateTime.fromMillisecondsSinceEpoch(
      500,
      isUtc: true,
    ),
    altitude: 3000.0,
    accuracy: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    GeolocatorPlatform.instance = MockGeolocatorPlatform();
  });

  test("get_my_location", () async {
    var res = await getMyLocation();
    expect(res, isA<LatLng>());
  });

  test("is_location_enabled", () async {
    var res = await isLocationServiceEnabled();
    expect(res, true);
  });

  test("get_current_position", () async {
    var res = await getCurrentPosition();
    expect(res, isA<LatLng>());
  });
}

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  @override
  Future<LocationPermission> checkPermission() =>
      Future.value(LocationPermission.whileInUse);

  @override
  Future<bool> isLocationServiceEnabled() => Future.value(true);

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) =>
      Future.value(mockPosition);
}
