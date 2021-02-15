import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';

import 'send_location_notification.dart';
import 'sharing_location_service.dart';

class KeyStreamService {
  KeyStreamService._();
  static final KeyStreamService _instance = KeyStreamService._();
  factory KeyStreamService() => _instance;

  AtClientImpl atClientInstance;
  List<KeyLocationModel> allLocationNotifications = [];
  String currentAtSign;

  StreamController _atNotificationsController;
  Stream<List<KeyLocationModel>> get atNotificationsStream =>
      _atNotificationsController.stream;
  StreamSink<List<KeyLocationModel>> get atNotificationsSink =>
      _atNotificationsController.sink;

  init(AtClientImpl clientInstance) {
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
    allLocationNotifications = [];
    _atNotificationsController =
        StreamController<List<KeyLocationModel>>.broadcast();
    getAllNotifications();
  }

  getAllNotifications() async {
    List<String> allResponse = await atClientInstance.getKeys(
      regex: 'sharelocation-',
    );

    if (allResponse.length == 0) {
      SendLocationNotification().init(atClientInstance);
      return;
    }

    allResponse.forEach((key) {
      if ('@${key.split(':')[1]}'.contains(currentAtSign)) {
        print('key -> $key');
        KeyLocationModel tempHyridNotificationModel =
            KeyLocationModel(key: key);
        allLocationNotifications.add(tempHyridNotificationModel);
      }
    });

    allLocationNotifications.forEach((notification) {
      AtKey atKey = AtKey.fromString(notification.key);
      notification.atKey = atKey;
    });

    for (int i = 0; i < allLocationNotifications.length; i++) {
      AtValue value = await getAtValue(allLocationNotifications[i].atKey);
      if (value != null) {
        allLocationNotifications[i].atValue = value;
      }
    }

    convertJsonToLocationModel();
    filterData();

    notifyListeners();
    updateEventAccordingToAcknowledgedData();

    SendLocationNotification().init(atClientInstance);
  }

  convertJsonToLocationModel() {
    print(
        'allShareLocationNotifications.length -> ${allLocationNotifications.length}');
    for (int i = 0; i < allLocationNotifications.length; i++) {
      try {
        if ((allLocationNotifications[i].atValue.value != null) &&
            (allLocationNotifications[i].atValue.value != "null")) {
          LocationNotificationModel locationNotificationModel =
              LocationNotificationModel.fromJson(
                  jsonDecode(allLocationNotifications[i].atValue.value));
          allLocationNotifications[i].locationNotificationModel =
              locationNotificationModel;
          print(
              'locationNotificationModel $i -> ${locationNotificationModel.getLatLng}');
        }
      } catch (e) {
        print('convertJsonToLocationModel error :$e');
      }
    }
  }

  filterData() {
    List<KeyLocationModel> tempArray = [];
    for (int i = 0; i < allLocationNotifications.length; i++) {
      if ((allLocationNotifications[i].locationNotificationModel == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null))
        tempArray.add(allLocationNotifications[i]);
    }
    allLocationNotifications
        .removeWhere((element) => tempArray.contains(element));

    tempArray.forEach((element) {
      print('removed data ${element.key}');
      print('${element.locationNotificationModel}');
    });
  }

  updateEventAccordingToAcknowledgedData() async {
    // from all the notifications check whose isAcknowledgment is false
    // check for sharelocationacknowledged notification with same keyID, if present then update

    allLocationNotifications.forEach((notification) async {
      if ((notification.locationNotificationModel.atsignCreator ==
              currentAtSign) &&
          (!notification.locationNotificationModel.isAcknowledgment)) {
        String atkeyMicrosecondId =
            notification.key.split('sharelocation-')[1].split('@')[0];
        print('atkeyMicrosecondId $atkeyMicrosecondId');
        String acknowledgedKeyId =
            'sharelocationacknowledged-$atkeyMicrosecondId';

        List<String> allRegexResponses =
            await atClientInstance.getKeys(regex: acknowledgedKeyId);
        print('lenhtg ${allRegexResponses.length}');
        if ((allRegexResponses != null) && (allRegexResponses.length > 0)) {
          AtKey acknowledgedAtKey = AtKey.fromString(allRegexResponses[0]);

          AtValue result = await atClientInstance
              .get(acknowledgedAtKey)
              .catchError((e) =>
                  print("error in get ${e.errorCode} ${e.errorMessage}"));

          LocationNotificationModel acknowledgedEvent =
              LocationNotificationModel.fromJson(jsonDecode(result.value));
          SharingLocationService()
              .updateWithShareLocationAcknowledge(acknowledgedEvent);
        }
      }
    });
  }

  mapUpdatedLocationDataToWidget(LocationNotificationModel locationData) {
    String newLocationDataKeyId =
        locationData.key.split('sharelocation-')[1].split('@')[0];

    for (int i = 0; i < allLocationNotifications.length; i++) {
      if (allLocationNotifications[i].key.contains(newLocationDataKeyId)) {
        allLocationNotifications[i].locationNotificationModel = locationData;
      }
    }
    notifyListeners();
    SendLocationNotification().findAtSignsToShareLocationWith();
  }

  removeData(String key) {
    allLocationNotifications
        .removeWhere((notification) => notification.key == key);
    print('allLocationNotifications after removing $allLocationNotifications');
    notifyListeners();
    SendLocationNotification().findAtSignsToShareLocationWith();
  }

  Future<KeyLocationModel> addDataToList(
      LocationNotificationModel locationNotificationModel) async {
    String newLocationDataKeyId =
        locationNotificationModel.key.split('sharelocation-')[1].split('@')[0];
    String tempKey = 'sharelocation-$newLocationDataKeyId';
    List<String> key = [];
    if (locationNotificationModel.atsignCreator == currentAtSign) {
      key = await atClientInstance.getKeys(
        regex: tempKey,
        // sharedWith: locationNotificationModel.receiver,
      );
    } else {
      key = await atClientInstance.getKeys(
        regex: tempKey,
        sharedBy: locationNotificationModel.atsignCreator,
      );
    }

    KeyLocationModel tempHyridNotificationModel = KeyLocationModel(key: key[0]);

    tempHyridNotificationModel.atKey = AtKey.fromString(key[0]);
    tempHyridNotificationModel.atValue =
        await getAtValue(tempHyridNotificationModel.atKey);
    tempHyridNotificationModel.locationNotificationModel =
        locationNotificationModel;
    allLocationNotifications.add(tempHyridNotificationModel);
    print('addDataToList:${allLocationNotifications}');

    notifyListeners();
    SendLocationNotification().findAtSignsToShareLocationWith();

    return tempHyridNotificationModel;
  }

  Future<dynamic> getAtValue(AtKey key) async {
    try {
      AtValue atvalue = await atClientInstance
          .get(key)
          .catchError((e) => print("error in in key_stream_service get $e"));

      if (atvalue != null)
        return atvalue;
      else
        return null;
    } catch (e) {
      print('error in key_stream_service getAtValue:$e');
      return null;
    }
  }

  notifyListeners() {
    atNotificationsSink.add(allLocationNotifications);
  }
}
