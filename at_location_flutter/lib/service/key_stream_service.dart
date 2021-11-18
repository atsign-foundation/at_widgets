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

  AtClient? atClientInstance;
  AtContactsImpl? atContactImpl;
  AtContact? loggedInUserDetails;
  List<KeyLocationModel> allLocationNotifications = [];
  String? currentAtSign;
  List<AtContact> contactList = [];

  // ignore: close_sinks
  StreamController atNotificationsController =
      StreamController<List<KeyLocationModel>>.broadcast();
  Stream<List<KeyLocationModel>> get atNotificationsStream =>
      atNotificationsController.stream as Stream<List<KeyLocationModel>>;
  StreamSink<List<KeyLocationModel>> get atNotificationsSink =>
      atNotificationsController.sink as StreamSink<List<KeyLocationModel>>;

  Function(List<KeyLocationModel>)? streamAlternative;

  void init(AtClient? clientInstance,
      {Function(List<KeyLocationModel>)? streamAlternative}) async {
    loggedInUserDetails = null;
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance!.getCurrentAtSign();
    allLocationNotifications = [];
    this.streamAlternative = streamAlternative;

    atNotificationsController =
        StreamController<List<KeyLocationModel>>.broadcast();
    getAllNotifications();

    loggedInUserDetails = await getAtSignDetails(currentAtSign);
    getAllContactDetails(currentAtSign!);
  }

  void getAllContactDetails(String currentAtSign) async {
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
    contactList = await atContactImpl!.listContacts();
  }

  /// adds all share and request location notifications to [atNotificationsSink]
  void getAllNotifications() async {
    AtClientManager.getInstance().syncService.sync();

    var allResponse = await atClientInstance!.getKeys(
      regex: 'sharelocation-',
    );

    var allRequestResponse = await atClientInstance!.getKeys(
      regex: 'requestlocation-',
    );

    allResponse = [...allResponse, ...allRequestResponse];

    if (allResponse.isEmpty) {
      SendLocationNotification().init(atClientInstance);
      notifyListeners();
      return;
    }

    allResponse.forEach((key) {
      // if ('@${key.split(':')[1]}'.contains(currentAtSign!)) {
      var tempHyridNotificationModel = KeyLocationModel(key: key);
      allLocationNotifications.add(tempHyridNotificationModel);
      // }
    });

    allLocationNotifications.forEach((notification) {
      var atKey = getAtKey(notification.key!);
      notification.atKey = atKey;
    });

    for (var i = 0; i < allLocationNotifications.length; i++) {
      AtValue? value = await (getAtValue(allLocationNotifications[i].atKey!));
      if (value != null) {
        allLocationNotifications[i].atValue = value;
      }
    }

    convertJsonToLocationModel();
    filterData();

    await checkForPendingLocations();

    notifyListeners();
    // updateEventAccordingToAcknowledgedData();
    // checkForDeleteRequestAck();

    SendLocationNotification().init(atClientInstance);

    /// TODO: start monitor after this, so that our list is calculated, and any new/old upcoming notification can be compared
  }

  /// Updates any received notification with [haveResponded] true, if already responded.
  Future<void> checkForPendingLocations() async {
    await Future.forEach(allLocationNotifications,
        (KeyLocationModel notification) async {
      if (notification.key!.contains(MixedConstants.SHARE_LOCATION)) {
        if ((notification.locationNotificationModel!.atsignCreator !=
                currentAtSign) &&
            (!notification.locationNotificationModel!.isAccepted) &&
            (!notification.locationNotificationModel!.isExited)) {
          var atkeyMicrosecondId =
              notification.key!.split('sharelocation-')[1].split('@')[0];
          var acknowledgedKeyId =
              'sharelocationacknowledged-$atkeyMicrosecondId';
          var allRegexResponses =
              await atClientInstance!.getKeys(regex: acknowledgedKeyId);
          // ignore: unnecessary_null_comparison
          if ((allRegexResponses != null) && (allRegexResponses.isNotEmpty)) {
            notification.haveResponded = true;
          }
        }
      }

      if (notification.key!.contains(MixedConstants.REQUEST_LOCATION)) {
        if ((notification.locationNotificationModel!.atsignCreator ==
                currentAtSign) &&
            (!notification.locationNotificationModel!.isAccepted) &&
            (!notification.locationNotificationModel!.isExited)) {
          var atkeyMicrosecondId =
              notification.key!.split('requestlocation-')[1].split('@')[0];
          var acknowledgedKeyId =
              'requestlocationacknowledged-$atkeyMicrosecondId';
          var allRegexResponses =
              await atClientInstance!.getKeys(regex: acknowledgedKeyId);
          // ignore: unnecessary_null_comparison
          if ((allRegexResponses != null) && (allRegexResponses.isNotEmpty)) {
            notification.haveResponded = true;
          }
        }
      }
    });
  }

  void updatePendingStatus(LocationNotificationModel notification) {
    for (var i = 0; i < allLocationNotifications.length; i++) {
      if ((allLocationNotifications[i].key!.contains(notification.key!))) {
        allLocationNotifications[i].haveResponded = true;
        break;
      }
    }
    notifyListeners();
  }

  /// Checks for missed 'Remove Person' requests for request location notifications
  void checkForDeleteRequestAck() async {
    // Letting other events complete
    await Future.delayed(Duration(seconds: 5));

    var dltRequestLocationResponse = await atClientInstance!.getKeys(
      regex: 'deleterequestacklocation',
    );

    for (var i = 0; i < dltRequestLocationResponse.length; i++) {
      /// Operate on receied notifications
      if (dltRequestLocationResponse[i].contains('cached')) {
        var atkeyMicrosecondId = dltRequestLocationResponse[i]
            .split('deleterequestacklocation-')[1]
            .split('@')[0];

        var _index = allLocationNotifications.indexWhere((element) {
          return (element.locationNotificationModel!.key!
                  .contains(atkeyMicrosecondId) &&
              (element.locationNotificationModel!.key!
                  .contains(MixedConstants.SHARE_LOCATION)));
        });

        if (_index == -1) continue;

        await RequestLocationService().deleteKey(
            allLocationNotifications[_index].locationNotificationModel!);
      }
    }
  }

  void convertJsonToLocationModel() {
    for (var i = 0; i < allLocationNotifications.length; i++) {
      try {
        if ((allLocationNotifications[i].atValue!.value != null) &&
            (allLocationNotifications[i].atValue!.value != 'null')) {
          var locationNotificationModel = LocationNotificationModel.fromJson(
              jsonDecode(allLocationNotifications[i].atValue!.value));
          allLocationNotifications[i].locationNotificationModel =
              locationNotificationModel;
        }
      } catch (e) {
        print('convertJsonToLocationModel error :$e');
      }
    }
  }

  /// Removes past notifications and notification where data is null.
  void filterData() {
    var tempArray = <KeyLocationModel>[];
    for (var i = 0; i < allLocationNotifications.length; i++) {
      // ignore: unrelated_type_equality_checks
      if ((allLocationNotifications[i].locationNotificationModel == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null)) {
        tempArray.add(allLocationNotifications[i]);
      } else {
        if ((allLocationNotifications[i].locationNotificationModel!.to !=
                null) &&
            (allLocationNotifications[i]
                    .locationNotificationModel!
                    .to!
                    .difference(DateTime.now())
                    .inMinutes <
                0)) tempArray.add(allLocationNotifications[i]);
      }
    }
    allLocationNotifications
        .removeWhere((element) => tempArray.contains(element));
  }

  /// Checks for any missed notifications and updates respective notification
  void updateEventAccordingToAcknowledgedData() async {
    await Future.forEach((allLocationNotifications),
        (KeyLocationModel notification) async {
      if (notification.key!.contains(MixedConstants.SHARE_LOCATION)) {
        if ((notification.locationNotificationModel!.atsignCreator ==
                currentAtSign) &&
            (!notification.locationNotificationModel!.isAcknowledgment)) {
          forShareLocation(notification);
        }
      } else if (notification.key!.contains(MixedConstants.REQUEST_LOCATION)) {
        if ((notification.locationNotificationModel!.atsignCreator ==
                currentAtSign) &&
            (!notification.locationNotificationModel!.isAcknowledgment)) {
          forRequestLocation(notification);
        }
      }
    });
  }

  void forShareLocation(KeyLocationModel notification) async {
    var atkeyMicrosecondId =
        notification.key!.split('sharelocation-')[1].split('@')[0];
    var acknowledgedKeyId = 'sharelocationacknowledged-$atkeyMicrosecondId';

    var allRegexResponses =
        await atClientInstance!.getKeys(regex: acknowledgedKeyId);

    // ignore: unnecessary_null_comparison
    if ((allRegexResponses != null) && (allRegexResponses.isNotEmpty)) {
      var acknowledgedAtKey = getAtKey(allRegexResponses[0]);

      var result = await atClientInstance!.get(acknowledgedAtKey).catchError(
          // ignore: return_of_invalid_type_from_catch_error
          (e) => print('error in get ${e.errorCode} ${e.errorMessage}'));

      var acknowledgedEvent =
          LocationNotificationModel.fromJson(jsonDecode(result.value));

      await SharingLocationService()
          .updateWithShareLocationAcknowledge(acknowledgedEvent);
    }
  }

  void forRequestLocation(KeyLocationModel notification) async {
    var atkeyMicrosecondId =
        notification.key!.split('requestlocation-')[1].split('@')[0];

    var acknowledgedKeyId = 'requestlocationacknowledged-$atkeyMicrosecondId';

    var allRegexResponses =
        await atClientInstance!.getKeys(regex: acknowledgedKeyId);

    // ignore: unnecessary_null_comparison
    if ((allRegexResponses != null) && (allRegexResponses.isNotEmpty)) {
      var acknowledgedAtKey = getAtKey(allRegexResponses[0]);

      var result = await atClientInstance!.get(acknowledgedAtKey).catchError(
          // ignore: return_of_invalid_type_from_catch_error
          (e) => print('error in get ${e.errorCode} ${e.errorMessage}'));

      var acknowledgedEvent =
          LocationNotificationModel.fromJson(jsonDecode(result.value));

      await RequestLocationService()
          .updateWithRequestLocationAcknowledge(acknowledgedEvent);
    }
  }

  /// Updates any [KeyLocationModel] data for updated data
  void mapUpdatedLocationDataToWidget(LocationNotificationModel locationData) {
    String newLocationDataKeyId;
    if (locationData.key!.contains(MixedConstants.SHARE_LOCATION)) {
      newLocationDataKeyId =
          locationData.key!.split('sharelocation-')[1].split('@')[0];
    } else {
      newLocationDataKeyId =
          locationData.key!.split('requestlocation-')[1].split('@')[0];
    }

    //// TODO: If we want to add any such notification that is not in the list, but we get a update
    // var _locationDataNotPresent = true;

    for (var i = 0; i < allLocationNotifications.length; i++) {
      if (allLocationNotifications[i].key!.contains(newLocationDataKeyId)) {
        allLocationNotifications[i].locationNotificationModel = locationData;
        // _locationDataNotPresent = false;
      }
    }

    // if (_locationDataNotPresent) {
    //   addDataToList(locationData);
    // }
    notifyListeners();

    // Update location sharing
    if ((locationData.isSharing) && (locationData.isAccepted)) {
      if (locationData.atsignCreator == currentAtSign) {
        SendLocationNotification().addMember(SendLocationNotification()
            .locationNotificationModelToLocationDataModel(locationData));
      }
    } else {
      //TODO: verify receiver
      if (locationData.atsignCreator == currentAtSign) {
        SendLocationNotification()
            .removeMember(locationData.key!, [locationData.receiver!]);
      }
    }
  }

  /// Removes a notification from list
  void removeData(String? key) {
    String atsignToDelete = '';
    allLocationNotifications.removeWhere((notification) {
      if (key!.contains(notification.atKey!.key!)) {
        atsignToDelete = notification.locationNotificationModel!.receiver!;
      }
      return key!.contains(notification.atKey!.key!);
    });
    notifyListeners();
    // Remove location sharing
    //TODO: verify receiver
    SendLocationNotification().removeMember(key!, [atsignToDelete]);
  }

  /// Adds new [KeyLocationModel] data for new received notification
  Future<dynamic> addDataToList(
      LocationNotificationModel locationNotificationModel,
      {String? receivedkey}) async {
    /// with rSDK we can get previous notification, this will restrict us to add one notification twice
    for (var _locationNotification in allLocationNotifications) {
      if (_locationNotification.locationNotificationModel!.key ==
          locationNotificationModel.key) {
        return;
      }
    }

    String? key;

    if (receivedkey != null) {
      key = receivedkey;
    } else {
      String tempKey;
      String newLocationDataKeyId;
      if (locationNotificationModel.key!
          .contains(MixedConstants.SHARE_LOCATION)) {
        newLocationDataKeyId = locationNotificationModel.key!
            .split('sharelocation-')[1]
            .split('@')[0];
        tempKey = 'sharelocation-$newLocationDataKeyId';
      } else {
        newLocationDataKeyId = locationNotificationModel.key!
            .split('requestlocation-')[1]
            .split('@')[0];
        tempKey = 'requestlocation-$newLocationDataKeyId';
      }

      var keys = <String>[];
      if (keys.isEmpty) {
        keys = await atClientInstance!.getKeys(
          regex: tempKey,
        );
      }
      if (keys.isEmpty) {
        keys = await atClientInstance!.getKeys(
          regex: tempKey,
          sharedWith: locationNotificationModel.receiver,
        );
      }
      if (keys.isEmpty) {
        keys = await atClientInstance!.getKeys(
          regex: tempKey,
          sharedBy: locationNotificationModel.key!.contains('share')
              ? locationNotificationModel.atsignCreator
              : locationNotificationModel.receiver,
        );
      }

      if (keys.isEmpty) {
        return;
      }

      key = keys[0];
    }

    var tempHyridNotificationModel = KeyLocationModel(key: key);

    tempHyridNotificationModel.atKey = getAtKey(key);
    tempHyridNotificationModel.atValue =
        await (getAtValue(tempHyridNotificationModel.atKey!));
    tempHyridNotificationModel.locationNotificationModel =
        locationNotificationModel;
    allLocationNotifications.add(tempHyridNotificationModel);

    notifyListeners();

    if ((tempHyridNotificationModel.locationNotificationModel!.isSharing)) {
      if (tempHyridNotificationModel.locationNotificationModel!.atsignCreator ==
          currentAtSign) {
        // ignore: unawaited_futures
        SendLocationNotification().addMember(SendLocationNotification()
            .locationNotificationModelToLocationDataModel(
                tempHyridNotificationModel.locationNotificationModel!));
      }
    }
    return tempHyridNotificationModel;
  }

  Future<dynamic> getAtValue(AtKey key) async {
    try {
      var atvalue = await atClientInstance!
          .get(key)
          // ignore: return_of_invalid_type_from_catch_error
          .catchError((e) => print('error in in key_stream_service get $e'));

      // ignore: unnecessary_null_comparison
      if (atvalue != null) {
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
