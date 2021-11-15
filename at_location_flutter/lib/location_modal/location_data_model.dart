import 'package:latlong2/latlong.dart';

class LocationDataModel {
  /// [locationSharingFor] accepts id as key and [LocationSharingFor] as data.
  late Map<String, LocationSharingFor> locationSharingFor;
  late double lat, long;
  late DateTime lastUpdatedAt;
  late String sender, receiver;

  LocationDataModel(this.locationSharingFor, this.lat, this.long,
      this.lastUpdatedAt, this.sender, this.receiver);

  LatLng get getLatLng => LatLng(lat, long);

  @override
  String toString() {
    return '$locationSharingFor, $getLatLng, $lastUpdatedAt, $sender, $receiver';
  }
}

class LocationSharingFor {
  late DateTime from, to;
  late LocationSharingType locationSharingType;

  LocationSharingFor(this.from, this.to, this.locationSharingType);
}

enum LocationSharingType { event, p2p }

/// string-> atsign
/// for sending and receiving location
Map<String, LocationDataModel>? locationReceivedData;
