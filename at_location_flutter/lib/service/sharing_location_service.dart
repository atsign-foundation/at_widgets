import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/common_components/location_prompt_dialog.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'at_location_notification_listener.dart';

class SharingLocationService {
  static final SharingLocationService _singleton =
      SharingLocationService._internal();
  SharingLocationService._internal();

  factory SharingLocationService() {
    return _singleton;
  }

  List checkForAlreadyExisting(String? atsign) {
    var index = KeyStreamService().allLocationNotifications.indexWhere((e) =>
        ((e.locationNotificationModel!.receiver == atsign) &&
            (e.locationNotificationModel!.key!
                .contains(MixedConstants.SHARE_LOCATION))));
    if (index > -1) {
      return [
        true,
        KeyStreamService()
            .allLocationNotifications[index]
            .locationNotificationModel
      ];
    } else {
      return [false];
    }
  }

  Future<bool?> sendShareLocationEvent(String? atsign, bool isAcknowledgment,
      {int? minutes}) async {
    try {
      // var alreadyExists = checkForAlreadyExisting(atsign);
      var result;
      // if (alreadyExists[0]) {
      //   var newLocationNotificationModel = LocationNotificationModel.fromJson(
      //       jsonDecode(
      //           LocationNotificationModel.convertLocationNotificationToJson(
      //               alreadyExists[1])));

      //   newLocationNotificationModel.to =
      //       DateTime.now().add(Duration(minutes: minutes!));

      //   await locationPromptDialog(
      //       text:
      //           'You are already sharing your location with $atsign. Would you like to update it ?',
      //       locationNotificationModel: newLocationNotificationModel,
      //       isShareLocationData: true,
      //       isRequestLocationData: false,
      //       yesText: 'Yes! Update',
      //       noText: 'No');
      //   return null;
      // }

      AtKey atKey;
      if (minutes != null) {
        atKey = newAtKey((minutes * 60000),
            'sharelocation-${DateTime.now().microsecondsSinceEpoch}', atsign,
            ttl: (minutes * 60000),
            expiresAt: DateTime.now().add(Duration(minutes: minutes)));
      } else {
        atKey = newAtKey(
          60000,
          'sharelocation-${DateTime.now().microsecondsSinceEpoch}',
          atsign,
        );
      }

      var locationNotificationModel = LocationNotificationModel()
        ..atsignCreator = AtLocationNotificationListener().currentAtSign
        ..key = atKey.key
        ..lat = 12
        ..long = 12
        ..receiver = atsign
        ..from = DateTime.now()
        ..isAcknowledgment = isAcknowledgment;

      if ((minutes != null)) {
        locationNotificationModel.to =
            DateTime.now().add(Duration(minutes: minutes));
      }
      result = await AtLocationNotificationListener().atClientInstance!.put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel),
            isDedicated: MixedConstants.isDedicated,
          );
      print('sendLocationNotification:$result');

      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
        await KeyStreamService().addDataToList(locationNotificationModel);
      }
      return result;
    } catch (e) {
      print('sending share location failed $e');
      return false;
    }
  }

  Future<bool> shareLocationAcknowledgment(
      LocationNotificationModel locationNotificationModel,
      bool isAccepted) async {
    try {
      var atkeyMicrosecondId = locationNotificationModel.key!
          .split('sharelocation-')[1]
          .split('@')[0];
      var atKey = newAtKey(-1, 'sharelocationacknowledged-$atkeyMicrosecondId',
          locationNotificationModel.atsignCreator);
      locationNotificationModel.isAccepted = isAccepted;
      locationNotificationModel.isExited = !isAccepted;

      var result = await AtLocationNotificationListener().atClientInstance!.put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel),
            isDedicated: MixedConstants.isDedicated,
          );
      print('sendLocationNotificationAcknowledgment:$result');
      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
      }
      return result;
    } catch (e) {
      print('sending share awk failed $e');
      return false;
    }
  }

  Future<bool> updateWithShareLocationAcknowledge(
      LocationNotificationModel locationNotificationModel,
      {bool? isSharing}) async {
    try {
      var atkeyMicrosecondId = locationNotificationModel.key!
          .split('sharelocation-')[1]
          .split('@')[0];

      var response =
          await AtLocationNotificationListener().atClientInstance!.getKeys(
                regex: 'sharelocation-$atkeyMicrosecondId',
              );

      var key = getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      if (isSharing != null) locationNotificationModel.isSharing = isSharing;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);

      if ((locationNotificationModel.from != null) &&
          (locationNotificationModel.to != null)) {
        key.metadata!.ttl = locationNotificationModel.to!
                .difference(locationNotificationModel.from!)
                .inMinutes *
            60000;
        key.metadata!.ttr = locationNotificationModel.to!
                .difference(locationNotificationModel.from!)
                .inMinutes *
            60000;
        key.metadata!.expiresAt = locationNotificationModel.to;
      }

      var result = await AtLocationNotificationListener().atClientInstance!.put(
            key,
            notification,
            isDedicated: MixedConstants.isDedicated,
          );
      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
        KeyStreamService()
            .mapUpdatedLocationDataToWidget(locationNotificationModel);
      }

      print('update result - $result');
      return result;
    } catch (e) {
      print('update share location failed $e');

      return false;
    }
  }

  Future removePerson(
      LocationNotificationModel locationNotificationModel) async {
    var result;
    if (locationNotificationModel.atsignCreator ==
        AtLocationNotificationListener().currentAtSign) {
      locationNotificationModel.isAccepted = false;
      locationNotificationModel.isExited = true;
      result =
          await updateWithShareLocationAcknowledge(locationNotificationModel);
    } else {
      result =
          await shareLocationAcknowledgment(locationNotificationModel, false);
    }
    return result;
  }

  Future<bool> deleteKey(
      LocationNotificationModel locationNotificationModel) async {
    try {
      var atkeyMicrosecondId = locationNotificationModel.key!
          .split('sharelocation-')[1]
          .split('@')[0];

      var response =
          await AtLocationNotificationListener().atClientInstance!.getKeys(
                regex: 'sharelocation-$atkeyMicrosecondId',
              );

      var key = getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      var result = await AtLocationNotificationListener()
          .atClientInstance!
          .delete(key, isDedicated: MixedConstants.isDedicated);
      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
        KeyStreamService().removeData(key.key);
      }
      return result;
    } catch (e) {
      print('error in deleting key $e');
      return false;
    }
  }

  Future<void> deleteAllKey() async {
    var response =
        await AtLocationNotificationListener().atClientInstance!.getKeys(
              regex: '',
            );
    await Future.forEach(response, (dynamic key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        var atKey = getAtKey(key);
        var result = await AtLocationNotificationListener()
            .atClientInstance!
            .delete(atKey, isDedicated: MixedConstants.isDedicated);
        print('$key is deleted ? $result');
      }
    });

    if (MixedConstants.isDedicated) {
      await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
    }
  }

  AtKey newAtKey(int ttr, String key, String? sharedWith,
      {int? ttl, DateTime? expiresAt}) {
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = ttr
      ..metadata!.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = AtLocationNotificationListener().currentAtSign;
    if (ttl != null) atKey.metadata!.ttl = ttl;
    if (expiresAt != null) atKey.metadata!.expiresAt = expiresAt;
    return atKey;
  }
}
