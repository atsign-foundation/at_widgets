import 'dart:convert';
import 'package:latlong/latlong.dart';

class EventMemberLocation {
  double lat, long;
  String key, fromAtSign, receiver;

  EventMemberLocation(
      {this.lat, this.long, this.fromAtSign, this.receiver, this.key});

  LatLng get getLatLng => LatLng(lat, long);

  EventMemberLocation.fromJson(Map<String, dynamic> json)
      : fromAtSign = json['fromAtSign'],
        receiver = json['receiver'],
        lat = json['lat'] != 'null' && json['lat'] != null
            ? double.parse(json['lat'])
            : null,
        long = json['long'] != 'null' && json['long'] != null
            ? double.parse(json['long'])
            : null,
        key = json['key'] ?? '';

  static String convertLocationNotificationToJson(
      EventMemberLocation eventMemberLocation) {
    var notification = json.encode({
      'fromAtSign': eventMemberLocation.fromAtSign,
      'receiver': eventMemberLocation.receiver,
      'lat': eventMemberLocation.lat.toString(),
      'long': eventMemberLocation.long.toString(),
      'key': eventMemberLocation.key.toString(),
    });

    return notification;
  }
}
