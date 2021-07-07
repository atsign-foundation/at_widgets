import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong/latlong.dart';

class EventMemberLocation {
  double? lat, long;
  String? key, fromAtSign, receiver;
  DateTime? startSharingFrom, shareUntil;

  EventMemberLocation(
      {this.lat,
      this.long,
      this.fromAtSign,
      this.receiver,
      this.key,
      this.startSharingFrom,
      this.shareUntil});

  LatLng get getLatLng => LatLng(lat!, long!);

  EventMemberLocation.fromJson(Map<String, dynamic> json)
      : fromAtSign = json['fromAtSign'],
        receiver = json['receiver'],
        lat = json['lat'] != 'null' && json['lat'] != null
            ? double.parse(json['lat'])
            : null,
        long = json['long'] != 'null' && json['long'] != null
            ? double.parse(json['long'])
            : null,
        startSharingFrom = json['startSharingFrom'] != null
            ? DateTime.parse(json['startSharingFrom']).toLocal()
            : null,
        shareUntil = json['shareUntil'] != null
            ? DateTime.parse(json['shareUntil']).toLocal()
            : null,
        key = json['key'] ?? '';

  static String convertLocationNotificationToJson(
      EventMemberLocation eventMemberLocation) {
    var notification = json.encode({
      'fromAtSign': eventMemberLocation.fromAtSign,
      'receiver': eventMemberLocation.receiver,
      'lat': eventMemberLocation.lat.toString(),
      'long': eventMemberLocation.long.toString(),
      'startSharingFrom': eventMemberLocation.startSharingFrom != null
          ? eventMemberLocation.startSharingFrom!.toUtc().toString()
          : null,
      'shareUntil': eventMemberLocation.shareUntil != null
          ? eventMemberLocation.shareUntil!.toUtc().toString()
          : null,
      'key': eventMemberLocation.key.toString(),
    });

    return notification;
  }
}
