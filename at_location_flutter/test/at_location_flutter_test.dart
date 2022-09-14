import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/distance_calculate.dart';
import 'package:at_location_flutter/service/location_service.dart';
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

  test("update_my_latlng", () async {
    LocationService().hybridUsersList = [];
    var pos = await getMyLocation();
    LocationService().addCurrentUserMarker = true;
    var _myData = HybridModel(displayName: "45expected", latLng: pos, eta: '?');
    LocationService().updateMyLatLng(_myData);
    expect(LocationService().hybridUsersList.length, 1);
  });

  test("add_my_details_to_hybrid_users_list", () async {
    LocationService().hybridUsersList = [];
    LocationService().addCurrentUserMarker = true;
    when((() => GeolocatorPlatform.instance.getPositionStream(
            locationSettings: const LocationSettings(distanceFilter: 10))))
        .thenAnswer((invocation) => Stream.value(mockPosition));
    await LocationService().addMyDetailsToHybridUsersList();
    expect(LocationService().hybridUsersList.length, 1);
  });

  test("add_center_marker", () async {
    LocationService().hybridUsersList = [];
    LocationService().textForCenter = "";
    var pos = await getMyLocation();
    LocationService().etaFrom = pos;
    LocationService().addCentreMarker();
    expect(LocationService().hybridUsersList.length, 1);
  });

  test("add_details", () async {
    var pos = await getMyLocation();
    var hybridModel =
        HybridModel(displayName: "45expected", latLng: pos, eta: '?');
    var hybridModel2 =
        HybridModel(displayName: "83apedistinct", latLng: pos, eta: '?');
    LocationService().hybridUsersList = [hybridModel2];
    await LocationService().addDetails(hybridModel);
    expect(LocationService().hybridUsersList.length, 1);
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

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #getPositionStream,
        null,
        <Symbol, Object?>{
          #desiredAccuracy: locationSettings?.accuracy ?? LocationAccuracy.best,
          #distanceFilter: locationSettings?.distanceFilter ?? 0,
          #timeLimit: locationSettings?.timeLimit ?? 0,
        },
      ),
      // returnValue: Stream.value(mockPosition),
    );
  }
}
