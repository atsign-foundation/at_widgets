import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/common_components/location_prompt_dialog.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';

import 'at_location_notification_listener.dart';
import 'key_stream_service.dart';

class RequestLocationService {
  static final RequestLocationService _singleton =
      RequestLocationService._internal();
  RequestLocationService._internal();

  factory RequestLocationService() {
    return _singleton;
  }

  List checkForAlreadyExisting(String? atsign) {
    var index = KeyStreamService().allLocationNotifications.indexWhere((e) =>
        ((e.locationNotificationModel!.atsignCreator == atsign) &&
            (e.locationNotificationModel!.key!
                .contains(MixedConstants.REQUEST_LOCATION))));
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

  bool checkIfEventIsNotResponded(
      LocationNotificationModel locationNotificationModel) {
    if ((!locationNotificationModel.isAccepted) &&
        (!locationNotificationModel.isExited)) {
      return true;
    }

    return false;
  }

  bool checkIfEventIsRejected(
      LocationNotificationModel locationNotificationModel) {
    if ((!locationNotificationModel.isAccepted) &&
        (locationNotificationModel.isExited)) {
      return true;
    }

    return false;
  }

  /// Sends a 'requestlocation' key to [atsign].
  Future<bool?> sendRequestLocationEvent(String? atsign) async {
    try {
      var alreadyExists = checkForAlreadyExisting(atsign);
      var result;

      if (alreadyExists[0]) {
        var newLocationNotificationModel = LocationNotificationModel.fromJson(
            jsonDecode(
                LocationNotificationModel.convertLocationNotificationToJson(
                    alreadyExists[1])));

        var isNotResponded =
            checkIfEventIsNotResponded(newLocationNotificationModel);

        newLocationNotificationModel.rePrompt = true;

        if (isNotResponded) {
          await locationPromptDialog(
              text:
                  'You have already requested $atsign. But your request has not been responded yet. Would you like to prompt them again?',
              locationNotificationModel: newLocationNotificationModel,
              isShareLocationData: false,
              isRequestLocationData: true,
              yesText: 'Yes! Re-Prompt',
              noText: 'No');

          return null;
        }

        var isRejected = checkIfEventIsRejected(newLocationNotificationModel);
        if (isRejected) {
          await locationPromptDialog(
            text:
                'You have already requested $atsign. But your request has been rejected. Would you like to prompt them again?',
            locationNotificationModel: newLocationNotificationModel,
            isShareLocationData: false,
            isRequestLocationData: true,
            yesText: 'Yes! Re-Prompt',
            noText: 'No',
          );

          return null;
        }

        await locationPromptDialog(
          text: 'You have already requested $atsign',
          isShareLocationData: false,
          isRequestLocationData: false,
          onlyText: true,
        );

        return null;
      }

      var atKey = newAtKey(60000,
          'requestlocation-${DateTime.now().microsecondsSinceEpoch}', atsign);

      var locationNotificationModel = LocationNotificationModel()
        ..atsignCreator = atsign
        ..key = atKey.key
        ..isRequest = true
        ..receiver =
            AtLocationNotificationListener().atClientInstance!.getCurrentAtSign();

      result = await AtLocationNotificationListener().atClientInstance!.put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel),
            isDedicated: MixedConstants.isDedicated,
          );
      print('requestLocationNotification:$result');

      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
        await KeyStreamService().addDataToList(locationNotificationModel);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Sends a 'requestlocationacknowledged' key to [originalLocationNotificationModel].receiver with isAccepted as [isAccepted]
  /// and duration of [minutes] minute
  Future<bool> requestLocationAcknowledgment(
      LocationNotificationModel originalLocationNotificationModel,
      bool isAccepted,
      {int? minutes,
      bool? isSharing}) async {
    try {
      var locationNotificationModel = LocationNotificationModel.fromJson(
          jsonDecode(
              LocationNotificationModel.convertLocationNotificationToJson(
                  originalLocationNotificationModel)));

      var atkeyMicrosecondId = locationNotificationModel.key!
          .split('requestlocation-')[1]
          .split('@')[0];
      AtKey atKey;

      atKey = newAtKey(
        60000,
        'requestlocationacknowledged-$atkeyMicrosecondId',
        locationNotificationModel.receiver,
      );

      locationNotificationModel
        ..isAccepted = isAccepted
        ..isExited = !isAccepted
        ..lat = isAccepted ? 12 : 0
        ..long = isAccepted ? 12 : 0;

      if (isSharing != null) locationNotificationModel.isSharing = isSharing;

      if (isAccepted && (minutes != null)) {
        locationNotificationModel.from = DateTime.now();
        locationNotificationModel.to =
            DateTime.now().add(Duration(minutes: minutes));
      }

      var result = await AtLocationNotificationListener().atClientInstance!.put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel),
            isDedicated: MixedConstants.isDedicated,
          );
      print('requestLocationAcknowledgment $result');

      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
        KeyStreamService().updatePendingStatus(locationNotificationModel);
      }

      if ((result) && (!isSharing!)) {
        KeyStreamService().removeData(atKey.key);
      }

      return result;
    } catch (e) {
      return false;
    }
  }

  /// Updates originally created [locationNotificationModel] with [originalLocationNotificationModel] data
  /// If [rePrompt] is true, then will show dialog box on receiver's side.
  Future updateWithRequestLocationAcknowledge(
      LocationNotificationModel originalLocationNotificationModel,
      {bool rePrompt = false}) async {
    try {
      var locationNotificationModel = LocationNotificationModel.fromJson(
          jsonDecode(
              LocationNotificationModel.convertLocationNotificationToJson(
                  originalLocationNotificationModel)));

      var atkeyMicrosecondId = locationNotificationModel.key!
          .split('requestlocation-')[1]
          .split('@')[0];

      var response =
          await AtLocationNotificationListener().atClientInstance!.getKeys(
                regex: 'requestlocation-$atkeyMicrosecondId',
              );

      var key = getAtKey(response[0]);

      if ((locationNotificationModel.isAccepted) &&
          (locationNotificationModel.from != null) &&
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

      locationNotificationModel.isAcknowledgment = true;
      locationNotificationModel.rePrompt = rePrompt;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);
      var result;
      result = await AtLocationNotificationListener().atClientInstance!.put(
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
      return false;
    }
  }

  /// Sends a 'deleterequestacklocation' key to delete the originally created key
  Future<bool> sendDeleteAck(
      LocationNotificationModel locationNotificationModel) async {
    try {
      var atkeyMicrosecondId = locationNotificationModel.key!
          .split('requestlocation-')[1]
          .split('@')[0];
      AtKey atKey;
      atKey = newAtKey(
        60000,
        'deleterequestacklocation-$atkeyMicrosecondId',
        locationNotificationModel.receiver,
      );

      var result = await AtLocationNotificationListener().atClientInstance!.put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(
                locationNotificationModel),
            isDedicated: MixedConstants.isDedicated,
          );
      print('sendDeleteAck $result');
      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
      }
      return result;
    } catch (e) {
      print('sendDeleteAck error $e');
      return false;
    }
  }

  /// Deletes originally created [locationNotificationModel] notification
  Future<bool> deleteKey(
      LocationNotificationModel locationNotificationModel) async {
    var atkeyMicrosecondId = locationNotificationModel.key!
        .split('requestlocation-')[1]
        .split('@')[0];

    var response =
        await AtLocationNotificationListener().atClientInstance!.getKeys(
              regex: 'requestlocation-$atkeyMicrosecondId',
            );

    var key = getAtKey(response[0]);

    locationNotificationModel.isAcknowledgment = true;

    var result =
        await AtLocationNotificationListener().atClientInstance!.delete(
              key,
              isDedicated: MixedConstants.isDedicated,
            );
    print('$key delete operation $result');

    if (result) {
      if (MixedConstants.isDedicated) {
        await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
      }
      KeyStreamService().removeData(key.key);
    }
    return result;
  }

  AtKey newAtKey(int ttr, String key, String? sharedWith,
      {int? ttl, DateTime? expiresAt}) {
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = ttr
      ..metadata!.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy =
          AtLocationNotificationListener().atClientInstance!.getCurrentAtSign();
    if (ttl != null) atKey.metadata!.ttl = ttl;
    if (expiresAt != null) atKey.metadata!.expiresAt = expiresAt;

    return atKey;
  }
}
