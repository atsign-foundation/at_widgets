// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:latlong2/latlong.dart';

/// Model class for the location data.
/// [locationSharingFor] accepts id as key and [LocationSharingFor] as data.
/// [lat] and [long] are the latitude and longitude of the location.
/// [lastUpdatedAt] is the time at which the location was last updated.
/// [sender] is the atsign of the sender.
/// [receiver] is the atsign of the receiver.
class LocationDataModel {
  /// [locationSharingFor] accepts id as key and [LocationSharingFor] as data.
  late Map<String, LocationSharingFor> locationSharingFor;
  double? lat, long;
  late DateTime lastUpdatedAt;
  late String sender, receiver;

  /// Enhancement: add a bool for retry

  LocationDataModel(this.locationSharingFor, this.lat, this.long, this.lastUpdatedAt, this.sender, this.receiver);

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

    lat = data['lat'] != null && data['lat'] != 'null' ? double.parse(data['lat']) : null;
    long = data['long'] != null && data['long'] != 'null' ? double.parse(data['long']) : null;
    lastUpdatedAt = DateTime.parse(data['lastUpdatedAt']).toLocal();
    sender = data['sender'];
    receiver = data['receiver'];
    locationSharingFor = {...tempLocationSharingFor};
  }

  LatLng? get getLatLng => lat != null && long != null ? LatLng(lat!, long!) : null;

  @override
  String toString() {
    return '$locationSharingFor, $getLatLng, $lastUpdatedAt, $sender, $receiver';
  }
}

/// Model class for the location sharing data.
/// [from] is the time from which the location is shared.
/// [to] is the time until the location will be shared.
/// [locationSharingType] is the type of location sharing.
/// [isAccepted] is true if the location is accepted.
/// [isExited] is true if the location is exited.
/// [isSharing] is true if the location is being shared.
class LocationSharingFor {
  DateTime? from, to;
  late LocationSharingType locationSharingType;
  late bool isAccepted, isExited, isSharing;

  LocationSharingFor(this.from, this.to, this.locationSharingType, this.isAccepted, this.isExited, this.isSharing);

  LocationSharingFor.fromJson(Map<String, dynamic> data) {
    from = (data['from'] != null && data['from'] != 'null') ? DateTime.parse(data['from']).toLocal() : null;
    to = (data['to'] != null && data['to'] != 'null') ? DateTime.parse(data['to']).toLocal() : null;
    locationSharingType = data['locationSharingType'] == 'LocationSharingType.Event'
        ? LocationSharingType.Event
        : LocationSharingType.P2P;
    isAccepted = data['isAccepted'] == 'true' ? true : false;
    isExited = data['isExited'] == 'true' ? true : false;
    isSharing = data['isSharing'] == 'true' ? true : false;
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from != null ? from!.toUtc().toString() : null,
      'to': to != null ? to!.toUtc().toString() : null,
      'locationSharingType': locationSharingType.toString(),
      'isAccepted': isAccepted.toString(),
      'isExited': isExited.toString(),
      'isSharing': isSharing.toString(),
    };
  }
}

// describe the LocationSharingType enum...
/// Enum for the type of location sharing.
/// [Event] is for sharing location for an event.
/// [P2P] is for sharing location for a person.
enum LocationSharingType { Event, P2P }
