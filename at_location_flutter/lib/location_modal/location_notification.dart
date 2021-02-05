import 'dart:convert';
import 'package:at_contact/at_contact.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

// !isExited && !isisAccepted => decide later
// isExited && !isAccepted => rejected
class LocationNotificationModel {
  String atsignCreator, receiver, key;
  double lat, long;
  bool isAccepted, isSharing, isExited, isAcknowledgment, isRequest, updateMap;
  DateTime from, to;
  AtContact atContact;
  LocationNotificationModel({
    this.lat,
    this.long,
    this.atsignCreator,
    this.receiver,
    this.from,
    this.to,
    this.isRequest = false,
    this.isAcknowledgment = false,
    this.isAccepted = false,
    this.isExited = false,
    this.isSharing = true,
    this.updateMap = false,
  });

  getAtContact() {
    atContact = AtContact(atSign: receiver);
  }

  LatLng get getLatLng => LatLng(this.lat, this.long);
  LocationNotificationModel.fromJson(Map<String, dynamic> json)
      : atsignCreator = json['atsignCreator'],
        receiver = json['receiver'],
        lat = json['lat'] != 'null' && json['lat'] != null
            ? double.parse(json['lat'])
            : 0,
        long = json['long'] != 'null' && json['long'] != null
            ? double.parse(json['long'])
            : 0,
        key = json['key'] ?? '',
        isAcknowledgment = json['isAcknowledgment'] == 'true' ? true : false,
        isAccepted = json['isAccepted'] == 'true' ? true : false,
        isExited = json['isExited'] == 'true' ? true : false,
        isRequest = json['isRequest'] == 'true' ? true : false,
        isSharing = json['isSharing'] == 'true' ? true : false,
        from = json['from'] != 'null' ? DateTime.parse(json['from']) : null,
        to = json['to'] != 'null' ? DateTime.parse(json['to']) : null,
        updateMap = json['updateMap'] == 'true' ? true : false;
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'long': long,
        'isAccepted': isAccepted,
        'atsignCreator': atsignCreator,
        'isExited': isExited,
        'isSharing': isSharing
      };
  static String convertLocationNotificationToJson(
      LocationNotificationModel locationNotificationModel) {
    var notification = json.encode({
      'atsignCreator': locationNotificationModel.atsignCreator,
      'receiver': locationNotificationModel.receiver,
      'lat': locationNotificationModel.lat.toString(),
      'long': locationNotificationModel.long.toString(),
      'key': locationNotificationModel.key.toString(),
      'from': locationNotificationModel.from.toString(),
      'to': locationNotificationModel.to.toString(),
      'isAcknowledgment': locationNotificationModel.isAcknowledgment.toString(),
      'isRequest': locationNotificationModel.isRequest.toString(),
      'isAccepted': locationNotificationModel.isAccepted.toString(),
      'isExited': locationNotificationModel.isExited.toString(),
      'updateMap': locationNotificationModel.updateMap.toString(),
      'isSharing': locationNotificationModel.isSharing.toString()
    });
    return notification;
  }
}
