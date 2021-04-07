import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'at_location_notification_listener.dart';

class SharingLocationService {
  static final SharingLocationService _singleton =
      SharingLocationService._internal();
  SharingLocationService._internal();

  factory SharingLocationService() {
    return _singleton;
  }

  Future<bool> sendShareLocationEvent(String atsign, bool isAcknowledgment,
      {int minutes}) async {
    try {
      AtKey atKey;
      if (minutes != null) {
        atKey = newAtKey((minutes * 60000),
            "sharelocation-${DateTime.now().microsecondsSinceEpoch}", atsign,
            ttl: (minutes * 60000),
            expiresAt: DateTime.now().add(Duration(minutes: minutes)));
      } else {
        atKey = newAtKey(
          60000,
          "sharelocation-${DateTime.now().microsecondsSinceEpoch}",
          atsign,
        );
      }

      LocationNotificationModel locationNotificationModel =
          LocationNotificationModel()
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
      var result = await AtLocationNotificationListener().atClientInstance.put(
          atKey,
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel));
      print('sendLocationNotification:$result');

      if (result) {
        KeyStreamService().addDataToList(locationNotificationModel);
      }
      return result;
    } catch (e) {
      print('sending share location failed $e');
      return false;
    }
  }

  shareLocationAcknowledgment(
      LocationNotificationModel locationNotificationModel,
      bool isAccepted) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('sharelocation-')[1]
          .split('@')[0];
      AtKey atKey = newAtKey(
          -1,
          "sharelocationacknowledged-$atkeyMicrosecondId",
          locationNotificationModel.atsignCreator);
      locationNotificationModel.isAccepted = isAccepted;
      locationNotificationModel.isExited = !isAccepted;

      var result = await AtLocationNotificationListener().atClientInstance.put(
          atKey,
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel));
      print('sendLocationNotificationAcknowledgment:$result');
      return result;
    } catch (e) {
      print('sending share awk failed $e');
      return false;
    }
  }

  updateWithShareLocationAcknowledge(
      LocationNotificationModel locationNotificationModel,
      {bool isSharing}) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('sharelocation-')[1]
          .split('@')[0];

      List<String> response =
          await AtLocationNotificationListener().atClientInstance.getKeys(
                regex: 'sharelocation-$atkeyMicrosecondId',
              );

      AtKey key = getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      if (isSharing != null) locationNotificationModel.isSharing = isSharing;

      var notification =
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel);

      if ((locationNotificationModel.from != null) &&
          (locationNotificationModel.to != null)) {
        key.metadata.ttl = locationNotificationModel.to
                .difference(locationNotificationModel.from)
                .inMinutes *
            60000;
        key.metadata.ttr = locationNotificationModel.to
                .difference(locationNotificationModel.from)
                .inMinutes *
            60000;
        key.metadata.expiresAt = locationNotificationModel.to;
      }

      var result = await AtLocationNotificationListener()
          .atClientInstance
          .put(key, notification);
      if (result) {
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

  removePerson(LocationNotificationModel locationNotificationModel) async {
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

  deleteKey(LocationNotificationModel locationNotificationModel) async {
    try {
      String atkeyMicrosecondId = locationNotificationModel.key
          .split('sharelocation-')[1]
          .split('@')[0];

      List<String> response =
          await AtLocationNotificationListener().atClientInstance.getKeys(
                regex: 'sharelocation-$atkeyMicrosecondId',
              );

      AtKey key = getAtKey(response[0]);

      locationNotificationModel.isAcknowledgment = true;

      var result =
          await AtLocationNotificationListener().atClientInstance.delete(key);
      if (result) {
        KeyStreamService().removeData(key.key);
      }
      return result;
    } catch (e) {
      print('error in deleting key $e');
      return false;
    }
  }

  deleteAllKey() async {
    List<String> response =
        await AtLocationNotificationListener().atClientInstance.getKeys(
              regex: '',
            );
    response.forEach((key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        AtKey atKey = getAtKey(key);
        var result = await AtLocationNotificationListener()
            .atClientInstance
            .delete(atKey);
        print('$key is deleted ? $result');
      }
    });
  }

  AtKey newAtKey(int ttr, String key, String sharedWith,
      {int ttl, DateTime expiresAt}) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
      ..metadata.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = AtLocationNotificationListener().currentAtSign;
    if (ttl != null) atKey.metadata.ttl = ttl;
    if (expiresAt != null) atKey.metadata.expiresAt = expiresAt;
    return atKey;
  }
}
