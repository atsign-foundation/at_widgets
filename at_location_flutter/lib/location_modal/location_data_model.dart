import 'dart:convert';

import 'package:latlong2/latlong.dart';

class LocationDataModel {
  /// [locationSharingFor] accepts id as key and [LocationSharingFor] as data.
  late Map<String, LocationSharingFor> locationSharingFor;
  double? lat, long;
  late DateTime lastUpdatedAt;
  late String sender, receiver;
  LocationDataModel(this.locationSharingFor, this.lat, this.long,
      this.lastUpdatedAt, this.sender, this.receiver);

  Map<String, dynamic> toJson() {
    return {
      'locationSharingFor': json.encode(locationSharingFor),
      'lat': lat.toString(),
      'long': long.toString(),
      'lastUpdatedAt': lastUpdatedAt.toUtc().toString(),
      'sender': sender,
      'receiver': receiver
    };
  }

  LocationDataModel.fromJson(Map<String, dynamic> data) {
    if (data['locationSharingFor'] == null ||
        data['lastUpdatedAt'] == null ||
        data['sender'] == null ||
        data['receiver'] == null) {
      assert(true, 'values can not be null');
    }

    Map<String, LocationSharingFor> tempLocationSharingFor = {};
    var locSharingMap = jsonDecode(data['locationSharingFor']);

    locSharingMap.forEach((key, value) {
      var locationData = LocationSharingFor.fromJson(value);
      tempLocationSharingFor[key] = locationData;
    });

    lat = data['lat'] != null ? double.parse(data['lat']) : null;
    long = data['long'] != null ? double.parse(data['long']) : null;
    lastUpdatedAt = DateTime.parse(data['lastUpdatedAt']).toLocal();
    sender = data['sender'];
    receiver = data['receiver'];
    locationSharingFor = {...tempLocationSharingFor};
  }

  LatLng? get getLatLng =>
      lat != null && long != null ? LatLng(lat!, long!) : null;

  @override
  String toString() {
    return '$locationSharingFor, $getLatLng, $lastUpdatedAt, $sender, $receiver';
  }
}

class LocationSharingFor {
  DateTime? from, to;
  late LocationSharingType locationSharingType;

  LocationSharingFor(this.from, this.to, this.locationSharingType);

  LocationSharingFor.fromJson(Map<String, dynamic> data) {
    from = DateTime.parse(data['from']).toLocal();
    to = DateTime.parse(data['to']).toLocal();
    locationSharingType =
        data['locationSharingType'] == 'LocationSharingType.Event'
            ? LocationSharingType.Event
            : LocationSharingType.P2P;
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from != null ? from!.toUtc().toString() : null,
      'to': to != null ? to!.toUtc().toString() : null,
      'locationSharingType': locationSharingType.toString()
    };
  }
}

enum LocationSharingType { Event, P2P }
