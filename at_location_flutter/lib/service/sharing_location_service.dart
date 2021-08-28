import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/common_components/location_prompt_dialog.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'at_location_notification_listener.dart';

class SharingLocationService {
  static final SharingLocationService _singleton = SharingLocationService._internal();
  SharingLocationService._internal();

  factory SharingLocationService() {
    return _singleton;
  }

  List<dynamic> checkForAlreadyExisting(String? atsign) {
    int index = KeyStreamService().allLocationNotifications.indexWhere((KeyLocationModel e) =>
        ((e.locationNotificationModel!.receiver == atsign) &&
            (e.locationNotificationModel!.key!.contains(MixedConstants.shareLocation))));
    if (index > -1) {
      return <dynamic>[true, KeyStreamService().allLocationNotifications[index].locationNotificationModel];
    } else {
      return <dynamic>[false];
    }
  }

  bool checkIfEventIsRejected(LocationNotificationModel locationNotificationModel) {
    if ((!locationNotificationModel.isAccepted) && (locationNotificationModel.isExited)) {
      return true;
    }

    return false;
  }

  Future<void> sendShareLocationToGroup(List<AtContact> selectedContacts, {int? minutes}) async {
    await Future.forEach(selectedContacts, (AtContact selectedContact) async {
      bool? _state = await sendShareLocationEvent(selectedContact.atSign!, false, minutes: minutes);
      if (_state == true) {
        CustomToast().show('Share Location Request sent to ${selectedContact.atSign!}',
            AtLocationNotificationListener().navKey.currentContext!);
      } else if (_state == false) {
        CustomToast().show('Something went wrong for ${selectedContact.atSign!}',
            AtLocationNotificationListener().navKey.currentContext!,
            bgColor: AllColors().RED);
      }
    });
  }

  /// Sends a 'sharelocation' key to [atsign] with duration of [minutes] minute
  Future<bool?> sendShareLocationEvent(String? atsign, bool isAcknowledgment, {int? minutes}) async {
    try {
      List<dynamic> alreadyExists = checkForAlreadyExisting(atsign);
      bool result;
      if (alreadyExists[0]) {
        LocationNotificationModel newLocationNotificationModel = LocationNotificationModel.fromJson(
            jsonDecode(LocationNotificationModel.convertLocationNotificationToJson(alreadyExists[1])));

        bool isRejected = checkIfEventIsRejected(newLocationNotificationModel);

        if (minutes != null) {
          newLocationNotificationModel.to = DateTime.now().add(Duration(minutes: minutes));
        } else {
          newLocationNotificationModel.to = null;
        }

        if (isRejected) {
          newLocationNotificationModel.rePrompt = true;
        }

        String msg = isRejected
            ? 'Your share location request has been rejected by $atsign. Would you like to prompt them again & update your request ?'
            : 'You already are sharing your location with $atsign. Would you like to update it ?';

        await locationPromptDialog(
            text: msg,
            locationNotificationModel: newLocationNotificationModel,
            isShareLocationData: true,
            isRequestLocationData: false,
            yesText: isRejected ? 'Yes! Re-Prompt' : 'Yes! Update',
            noText: 'No');
        return null;
      }

      AtKey atKey;
      if (minutes != null) {
        atKey = newAtKey((minutes * 60000), 'sharelocation-${DateTime.now().microsecondsSinceEpoch}', atsign,
            ttl: (minutes * 60000), expiresAt: DateTime.now().add(Duration(minutes: minutes)));
      } else {
        atKey = newAtKey(
          60000,
          'sharelocation-${DateTime.now().microsecondsSinceEpoch}',
          atsign,
        );
      }

      LocationNotificationModel locationNotificationModel = LocationNotificationModel()
        ..atsignCreator = AtLocationNotificationListener().currentAtSign
        ..key = atKey.key
        ..lat = 12
        ..long = 12
        ..receiver = atsign
        ..from = DateTime.now()
        ..isAcknowledgment = isAcknowledgment;

      if ((minutes != null)) {
        locationNotificationModel.to = DateTime.now().add(Duration(minutes: minutes));
      }
      result = await AtLocationNotificationListener().atClientInstance!.put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(locationNotificationModel),
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

  /// Sends a 'sharelocationacknowledged' key to [originalLocationNotificationModel].atsignCreator with isAccepted as [isAccepted]
  Future<bool> shareLocationAcknowledgment(
      LocationNotificationModel originalLocationNotificationModel, bool isAccepted) async {
    try {
      LocationNotificationModel locationNotificationModel = LocationNotificationModel.fromJson(
          jsonDecode(LocationNotificationModel.convertLocationNotificationToJson(originalLocationNotificationModel)));
      String atkeyMicrosecondId = locationNotificationModel.key!.split('sharelocation-')[1].split('@')[0];
      AtKey atKey =
          newAtKey(-1, 'sharelocationacknowledged-$atkeyMicrosecondId', locationNotificationModel.atsignCreator);
      locationNotificationModel.isAccepted = isAccepted;
      locationNotificationModel.isExited = !isAccepted;

      bool result = await AtLocationNotificationListener().atClientInstance!.put(
            atKey,
            LocationNotificationModel.convertLocationNotificationToJson(locationNotificationModel),
            isDedicated: MixedConstants.isDedicated,
          );
      print('sendLocationNotificationAcknowledgment:$result');
      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
        KeyStreamService().updatePendingStatus(locationNotificationModel);
      }
      return result;
    } catch (e) {
      print('sending share awk failed $e');
      return false;
    }
  }

  /// Updates originally created [locationNotificationModel] with [originalLocationNotificationModel] data
  Future<bool> updateWithShareLocationAcknowledge(LocationNotificationModel originalLocationNotificationModel,
      {bool? isSharing, bool rePrompt = false}) async {
    try {
      LocationNotificationModel locationNotificationModel = LocationNotificationModel.fromJson(
          jsonDecode(LocationNotificationModel.convertLocationNotificationToJson(originalLocationNotificationModel)));

      String atkeyMicrosecondId = locationNotificationModel.key!.split('sharelocation-')[1].split('@')[0];

      List<String> response = await AtLocationNotificationListener().atClientInstance!.getKeys(
            regex: 'sharelocation-$atkeyMicrosecondId',
          );

      AtKey key = getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;
      locationNotificationModel.rePrompt = rePrompt; // Dont show dialog box again

      if (isSharing != null) locationNotificationModel.isSharing = isSharing;

      String notification = LocationNotificationModel.convertLocationNotificationToJson(locationNotificationModel);

      if ((locationNotificationModel.from != null) && (locationNotificationModel.to != null)) {
        key.metadata!.ttl = locationNotificationModel.to!.difference(locationNotificationModel.from!).inMinutes * 60000;
        key.metadata!.ttr = locationNotificationModel.to!.difference(locationNotificationModel.from!).inMinutes * 60000;
        key.metadata!.expiresAt = locationNotificationModel.to;
      }

      bool result = await AtLocationNotificationListener().atClientInstance!.put(
            key,
            notification,
            isDedicated: MixedConstants.isDedicated,
          );
      if (result) {
        if (MixedConstants.isDedicated) {
          await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
        KeyStreamService().mapUpdatedLocationDataToWidget(locationNotificationModel);
      }

      print('update result - $result');
      return result;
    } catch (e) {
      print('update share location failed $e');

      return false;
    }
  }

  Future<bool> removePerson(LocationNotificationModel locationNotificationModel) async {
    bool result;
    if (locationNotificationModel.atsignCreator == AtLocationNotificationListener().currentAtSign) {
      locationNotificationModel.isAccepted = false;
      locationNotificationModel.isExited = true;
      result = await updateWithShareLocationAcknowledge(locationNotificationModel);
    } else {
      result = await shareLocationAcknowledgment(locationNotificationModel, false);
    }
    return result;
  }

  /// Deletes originally created [locationNotificationModel] notification
  Future<bool> deleteKey(LocationNotificationModel locationNotificationModel) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key!.split('sharelocation-')[1].split('@')[0];

      List<String> response = await AtLocationNotificationListener().atClientInstance!.getKeys(
            regex: 'sharelocation-$atkeyMicrosecondId',
          );

      AtKey key = getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      bool result =
          await AtLocationNotificationListener().atClientInstance!.delete(key, isDedicated: MixedConstants.isDedicated);
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
    List<String> response = await AtLocationNotificationListener().atClientInstance!.getKeys(
          regex: '',
        );
    await Future.forEach(response, (dynamic key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        AtKey atKey = getAtKey(key);
        bool result = await AtLocationNotificationListener()
            .atClientInstance!
            .delete(atKey, isDedicated: MixedConstants.isDedicated);
        print('$key is deleted ? $result');
      }
    });

    if (MixedConstants.isDedicated) {
      await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
    }
  }

  AtKey newAtKey(int ttr, String key, String? sharedWith, {int? ttl, DateTime? expiresAt}) {
    AtKey atKey = AtKey()
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
