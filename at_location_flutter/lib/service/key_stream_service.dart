import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';

import 'contact_service.dart';
import 'send_location_notification.dart';
import 'sharing_location_service.dart';
import 'sync_secondary.dart';

class KeyStreamService {
  KeyStreamService._();
  static final KeyStreamService _instance = KeyStreamService._();
  factory KeyStreamService() => _instance;

  AtClientImpl? atClientInstance;
  AtContactsImpl? atContactImpl;
  AtContact? loggedInUserDetails;
  List<KeyLocationModel> allLocationNotifications = <KeyLocationModel>[];
  String? currentAtSign;
  List<AtContact> contactList = <AtContact>[];

  StreamController<List<KeyLocationModel>> atNotificationsController =
      StreamController<List<KeyLocationModel>>.broadcast();
  Stream<List<KeyLocationModel>> get atNotificationsStream => atNotificationsController.stream;
  StreamSink<List<KeyLocationModel>> get atNotificationsSink => atNotificationsController.sink;

  Function(List<KeyLocationModel>)? streamAlternative;

  Future<void> init(AtClientImpl? clientInstance, {Function(List<KeyLocationModel>)? streamAlternative}) async {
    loggedInUserDetails = null;
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance!.currentAtSign;
    allLocationNotifications = <KeyLocationModel>[];
    this.streamAlternative = streamAlternative;

    atNotificationsController = StreamController<List<KeyLocationModel>>.broadcast();
    await getAllNotifications();

    loggedInUserDetails = await getAtSignDetails(currentAtSign);
    await getAllContactDetails(currentAtSign!);
  }

  void dispose() {
    atNotificationsController.close();
  }

  Future<void> getAllContactDetails(String currentAtSign) async {
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
    contactList = await atContactImpl!.listContacts();
  }

  /// adds all share and request location notifications to [atNotificationsSink]
  Future<void> getAllNotifications() async {
    await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);

    List<String> allResponse = await atClientInstance!.getKeys(
      regex: 'sharelocation-',
    );

    List<String> allRequestResponse = await atClientInstance!.getKeys(
      regex: 'requestlocation-',
    );

    allResponse = <String>[...allResponse, ...allRequestResponse];

    if (allResponse.isEmpty) {
      SendLocationNotification().init(atClientInstance);
      notifyListeners();
      return;
    }

    for (String key in allResponse) {
      if ('@${key.split(':')[1]}'.contains(currentAtSign!)) {
        KeyLocationModel tempHyridNotificationModel = KeyLocationModel(key: key);
        allLocationNotifications.add(tempHyridNotificationModel);
      }
    }

    for (KeyLocationModel notification in allLocationNotifications) {
      AtKey atKey = getAtKey(notification.key!);
      notification.atKey = atKey;
    }

    for (int i = 0; i < allLocationNotifications.length; i++) {
      AtValue? value = await (getAtValue(allLocationNotifications[i].atKey!));
      if (value != null) {
        allLocationNotifications[i].atValue = value;
      }
    }

    convertJsonToLocationModel();
    filterData();

    await checkForPendingLocations();

    notifyListeners();
    await updateEventAccordingToAcknowledgedData();
    await checkForDeleteRequestAck();

    SendLocationNotification().init(atClientInstance);
  }

  /// Updates any received notification with [haveResponded] true, if already responded.
  Future<void> checkForPendingLocations() async {
    for (KeyLocationModel notification in allLocationNotifications) {
      if (notification.key!.contains(MixedConstants.shareLocation)) {
        if ((notification.locationNotificationModel!.atsignCreator != currentAtSign) &&
            (!notification.locationNotificationModel!.isAccepted) &&
            (!notification.locationNotificationModel!.isExited)) {
          String atkeyMicrosecondId = notification.key!.split('sharelocation-')[1].split('@')[0];
          String acknowledgedKeyId = 'sharelocationacknowledged-$atkeyMicrosecondId';
          List<String> allRegexResponses = await atClientInstance!.getKeys(regex: acknowledgedKeyId);
          if ((allRegexResponses.toString() != 'null') && (allRegexResponses.isNotEmpty)) {
            notification.haveResponded = true;
          }
        }
      }

      if (notification.key!.contains(MixedConstants.requestLocation)) {
        if ((notification.locationNotificationModel!.atsignCreator == currentAtSign) &&
            (!notification.locationNotificationModel!.isAccepted) &&
            (!notification.locationNotificationModel!.isExited)) {
          String atkeyMicrosecondId = notification.key!.split('requestlocation-')[1].split('@')[0];
          String acknowledgedKeyId = 'requestlocationacknowledged-$atkeyMicrosecondId';
          List<String> allRegexResponses = await atClientInstance!.getKeys(regex: acknowledgedKeyId);
          if ((allRegexResponses.toString() != 'null') && (allRegexResponses.isNotEmpty)) {
            notification.haveResponded = true;
          }
        }
      }
    }
  }

  void updatePendingStatus(LocationNotificationModel notification) {
    for (int i = 0; i < allLocationNotifications.length; i++) {
      if ((allLocationNotifications[i].key!.contains(notification.key!))) {
        allLocationNotifications[i].haveResponded = true;
        break;
      }
    }
    notifyListeners();
  }

  /// Checks for missed 'Remove Person' requests for request location notifications
  Future<void> checkForDeleteRequestAck() async {
    // Letting other events complete
    await Future<dynamic>.delayed(const Duration(seconds: 5));

    List<String> dltRequestLocationResponse = await atClientInstance!.getKeys(
      regex: 'deleterequestacklocation',
    );

    for (int i = 0; i < dltRequestLocationResponse.length; i++) {
      /// Operate on receied notifications
      if (dltRequestLocationResponse[i].contains('cached')) {
        String atkeyMicrosecondId = dltRequestLocationResponse[i].split('deleterequestacklocation-')[1].split('@')[0];

        int _index = allLocationNotifications.indexWhere((KeyLocationModel element) {
          return (element.locationNotificationModel!.key!.contains(atkeyMicrosecondId) &&
              (element.locationNotificationModel!.key!.contains(MixedConstants.shareLocation)));
        });

        if (_index == -1) continue;

        await RequestLocationService().deleteKey(allLocationNotifications[_index].locationNotificationModel!);
      }
    }
  }

  void convertJsonToLocationModel() {
    for (int i = 0; i < allLocationNotifications.length; i++) {
      try {
        if ((allLocationNotifications[i].atValue!.value != null) &&
            (allLocationNotifications[i].atValue!.value != 'null')) {
          LocationNotificationModel locationNotificationModel =
              LocationNotificationModel.fromJson(jsonDecode(allLocationNotifications[i].atValue!.value));
          allLocationNotifications[i].locationNotificationModel = locationNotificationModel;
        }
      } catch (e) {
        print('convertJsonToLocationModel error :$e');
      }
    }
  }

  /// Removes past notifications and notification where data is null.
  void filterData() {
    List<KeyLocationModel> tempArray = <KeyLocationModel>[];
    for (int i = 0; i < allLocationNotifications.length; i++) {
      if ((allLocationNotifications[i].locationNotificationModel.toString() == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null)) {
        tempArray.add(allLocationNotifications[i]);
      } else {
        if ((allLocationNotifications[i].locationNotificationModel!.to != null) &&
            (allLocationNotifications[i].locationNotificationModel!.to!.difference(DateTime.now()).inMinutes < 0)) {
          tempArray.add(allLocationNotifications[i]);
        }
      }
    }
    allLocationNotifications.removeWhere((KeyLocationModel element) => tempArray.contains(element));
  }

  /// Checks for any missed notifications and updates respective notification
  Future<void> updateEventAccordingToAcknowledgedData() async {
    await Future.forEach((allLocationNotifications), (dynamic notification) async {
      if (notification.key.contains(MixedConstants.shareLocation)) {
        if ((notification.locationNotificationModel.atsignCreator == currentAtSign) &&
            (!notification.locationNotificationModel.isAcknowledgment)) {
          await forShareLocation(notification);
        }
      } else if (notification.key.contains(MixedConstants.requestLocation)) {
        if ((notification.locationNotificationModel.atsignCreator == currentAtSign) &&
            (!notification.locationNotificationModel.isAcknowledgment)) {
          await forRequestLocation(notification);
        }
      }
    });
  }

  Future<void> forShareLocation(KeyLocationModel notification) async {
    String atkeyMicrosecondId = notification.key!.split('sharelocation-')[1].split('@')[0];
    String acknowledgedKeyId = 'sharelocationacknowledged-$atkeyMicrosecondId';

    List<String> allRegexResponses = await atClientInstance!.getKeys(regex: acknowledgedKeyId);

    if (allRegexResponses.toString() != 'null' && allRegexResponses.isNotEmpty) {
      AtKey acknowledgedAtKey = getAtKey(allRegexResponses[0]);

      AtValue result = await atClientInstance!.get(acknowledgedAtKey).catchError((dynamic e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });

      LocationNotificationModel acknowledgedEvent = LocationNotificationModel.fromJson(jsonDecode(result.value));
      await SharingLocationService().updateWithShareLocationAcknowledge(acknowledgedEvent);
    }
  }

  Future<void> forRequestLocation(KeyLocationModel notification) async {
    String atkeyMicrosecondId = notification.key!.split('requestlocation-')[1].split('@')[0];

    String acknowledgedKeyId = 'requestlocationacknowledged-$atkeyMicrosecondId';

    List<String>? allRegexResponses = await atClientInstance!.getKeys(regex: acknowledgedKeyId);

    if ((allRegexResponses.toString() != 'null') && (allRegexResponses.isNotEmpty)) {
      AtKey acknowledgedAtKey = getAtKey(allRegexResponses[0]);

      AtValue result = await atClientInstance!.get(acknowledgedAtKey).catchError((dynamic e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });

      LocationNotificationModel acknowledgedEvent = LocationNotificationModel.fromJson(jsonDecode(result.value));
      await RequestLocationService().updateWithRequestLocationAcknowledge(acknowledgedEvent);
    }
  }

  /// Updates any [KeyLocationModel] data for updated data
  void mapUpdatedLocationDataToWidget(LocationNotificationModel locationData) {
    String newLocationDataKeyId;
    if (locationData.key!.contains(MixedConstants.shareLocation)) {
      newLocationDataKeyId = locationData.key!.split('sharelocation-')[1].split('@')[0];
    } else {
      newLocationDataKeyId = locationData.key!.split('requestlocation-')[1].split('@')[0];
    }

    for (int i = 0; i < allLocationNotifications.length; i++) {
      if (allLocationNotifications[i].key!.contains(newLocationDataKeyId)) {
        allLocationNotifications[i].locationNotificationModel = locationData;
      }
    }
    notifyListeners();

    // Update location sharing
    if ((locationData.isSharing) && (locationData.isAccepted)) {
      if (locationData.atsignCreator == currentAtSign) {
        SendLocationNotification().addMember(locationData);
      }
    } else {
      SendLocationNotification().removeMember(locationData.key);
    }
  }

  /// Removes a notification from list
  void removeData(String? key) {
    allLocationNotifications.removeWhere((KeyLocationModel notification) => key!.contains(notification.atKey!.key!));
    notifyListeners();
    // Remove location sharing
    SendLocationNotification().removeMember(key);
  }

  /// Adds new [KeyLocationModel] data for new received notification
  Future<KeyLocationModel> addDataToList(LocationNotificationModel locationNotificationModel) async {
    String newLocationDataKeyId;
    String tempKey;
    if (locationNotificationModel.key!.contains(MixedConstants.shareLocation)) {
      newLocationDataKeyId = locationNotificationModel.key!.split('sharelocation-')[1].split('@')[0];
      tempKey = 'sharelocation-$newLocationDataKeyId';
    } else {
      newLocationDataKeyId = locationNotificationModel.key!.split('requestlocation-')[1].split('@')[0];
      tempKey = 'requestlocation-$newLocationDataKeyId';
    }

    List<String> key = <String>[];
    if (key.isEmpty) {
      key = await atClientInstance!.getKeys(
        regex: tempKey,
      );
    }
    if (key.isEmpty) {
      key = await atClientInstance!.getKeys(
        regex: tempKey,
        sharedWith: locationNotificationModel.receiver,
      );
    }
    if (key.isEmpty) {
      key = await atClientInstance!.getKeys(
        regex: tempKey,
        sharedBy: locationNotificationModel.key!.contains('share')
            ? locationNotificationModel.atsignCreator
            : locationNotificationModel.receiver,
      );
    }

    KeyLocationModel tempHyridNotificationModel = KeyLocationModel(key: key[0]);

    tempHyridNotificationModel.atKey = getAtKey(key[0]);
    tempHyridNotificationModel.atValue = await (getAtValue(tempHyridNotificationModel.atKey!));
    tempHyridNotificationModel.locationNotificationModel = locationNotificationModel;
    allLocationNotifications.add(tempHyridNotificationModel);

    notifyListeners();

    if ((tempHyridNotificationModel.locationNotificationModel!.isSharing)) {
      if (tempHyridNotificationModel.locationNotificationModel!.atsignCreator == currentAtSign) {
        await SendLocationNotification().addMember(tempHyridNotificationModel.locationNotificationModel);
      }
    }
    return tempHyridNotificationModel;
  }

  Future<dynamic> getAtValue(AtKey key) async {
    try {
      AtValue atvalue = await atClientInstance!.get(key).catchError((dynamic e) {
        print('error in in key_stream_service get $e');
      });

      if (atvalue is! AtValue) {
        return atvalue;
      } else {
        return null;
      }
    } catch (e) {
      print('error in key_stream_service getAtValue:$e');
      return null;
    }
  }

  /// Returns updated list
  void notifyListeners() {
    // print('notifyListeners');
    // allLocationNotifications.forEach((element) {
    //   print(LocationNotificationModel.convertLocationNotificationToJson(
    //       element.locationNotificationModel!));
    // });
    if (streamAlternative != null) {
      streamAlternative!(allLocationNotifications);
    }
    atNotificationsSink.add(allLocationNotifications);
  }
}
