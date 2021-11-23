import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_data_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/service/notify_and_put.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'key_stream_service.dart';

/// [masterSwitchState] will control whether location is sent to any user
///
/// [locationPromptDialog] will be called whenever package is about to send location and [masterSwitchState] is false.
///
/// Make sure that [locationPromptDialog] is a dialog or a function which can ask the user to turn the [masterSwitchState]
/// true if needed.
class SendLocationNotification {
  SendLocationNotification._();
  static final SendLocationNotification _instance =
      SendLocationNotification._();
  factory SendLocationNotification() => _instance;
  Timer? timer;
  final String locationKey = 'location-notify';
  StreamSubscription<Position>? positionStream;
  bool masterSwitchState = true;
  Function? locationPromptDialog;
  Map<String, LocationDataModel> allAtsignsLocationData = {};
  List<String> _atsignsToSendLocationwith = [];
  AtClient? atClient;
  bool isEventInUse = false,
      isLocationDataInitialized = false,
      isEventDataInitialized = false;

  LocationDataModel? getLocationDataModel(String _atsign) =>
      allAtsignsLocationData[_atsign];

  reset() {
    allAtsignsLocationData = {};
    _atsignsToSendLocationwith = [];
    isEventInUse = false;
    isLocationDataInitialized = false;
    isEventDataInitialized = false;
  }

  void init(AtClient? newAtClient) {
    if ((timer != null) && (timer!.isActive)) timer!.cancel();
    atClient = newAtClient;
    isEventInUse = AtLocationNotificationListener().isEventInUse;
    if (positionStream != null) positionStream!.cancel();
    findAtSignsToShareLocationWith();
  }

// TODO: write a function to compare new data with saved ones and remove the expired data.

  getAllLocationShareKeys() async {
    var allLocationKeyStrings =
        await AtClientManager.getInstance().atClient.getKeys(
              regex: locationKey,
            );

    print('allLocationKeyStrings : $allLocationKeyStrings');

    await Future.forEach(allLocationKeyStrings, (dynamic key) async {
      if (!'@$key'.contains('cached')) {
        var atKey = getAtKey(key);
        AtValue? _atValue = await KeyStreamService().getAtValue(atKey);
        if ((_atValue != null) && (_atValue.value != null)) {
          try {
            var _locationDataModel =
                LocationDataModel.fromJson(jsonDecode(_atValue.value));
            allAtsignsLocationData[_locationDataModel.receiver] =
                _locationDataModel;
          } catch (e) {
            print('Error in getAllLocationData $e');
          }
        }
      }
    });

    print('filteredAtsigns : $allAtsignsLocationData');
  }

  compareForMissingInvites(List<LocationDataModel> _newLocationDataModel) {
    for (var _locationDataModel in _newLocationDataModel) {
      if (allAtsignsLocationData[_locationDataModel.receiver] != null) {
        var _receiverLocationDataModel =
            allAtsignsLocationData[_locationDataModel.receiver]!;

        if (_locationDataModel.locationSharingFor.keys.isEmpty) {
          continue;
        }

        var _id = _locationDataModel.locationSharingFor.keys.first;
        if (_receiverLocationDataModel.locationSharingFor[_id] != null) {
          continue;
        } else {
          _receiverLocationDataModel.locationSharingFor = {
            ..._receiverLocationDataModel.locationSharingFor,
            ..._locationDataModel.locationSharingFor
          };

          if (!_atsignsToSendLocationwith
              .contains(_locationDataModel.receiver)) {
            _atsignsToSendLocationwith.add(_locationDataModel.receiver);
          }
        }
      } else {
        allAtsignsLocationData[_locationDataModel.receiver] =
            _locationDataModel;
      }
    }
  }

  initEventData(List<LocationDataModel> locationDataModel) {
    // _appendLocationDataModelData(locationDataModel);
    compareForMissingInvites(locationDataModel);

    isEventDataInitialized = true;
    if (isLocationDataInitialized) {
      sendLocation();
    }
  }

  _appendLocationDataModelData(List<LocationDataModel> locationDataModel) {
    locationDataModel.forEach((element) {
      if (allAtsignsLocationData[element.receiver] != null) {
        allAtsignsLocationData[element.receiver]!.locationSharingFor = {
          ...allAtsignsLocationData[element.receiver]!.locationSharingFor,
          ...element.locationSharingFor
        };
      } else {
        allAtsignsLocationData[element.receiver] = element;
      }
    });

    print('allAtsignsLocationData data :${allAtsignsLocationData}');
  }

  void findAtSignsToShareLocationWith() {
    List<LocationDataModel> _newlocationDataModel = [];
    KeyStreamService()
        .allLocationNotifications
        .forEach((KeyLocationModel notification) {
      LocationDataModel _locationDataModel =
          locationNotificationModelToLocationDataModel(
              notification.locationNotificationModel!);
      _newlocationDataModel.add(_locationDataModel);
    });
    compareForMissingInvites(_newlocationDataModel);

    print('allAtsignsLocationData: ');
    allAtsignsLocationData.forEach((key, value) {
      print('$key : ${allAtsignsLocationData[key]}');
    });

    isLocationDataInitialized = true;
    if ((isEventDataInitialized && isEventInUse) || !isEventInUse) {
      sendLocation();
    }
  }

  void setLocationPrompt(Function _locationPrompt) {
    locationPromptDialog = _locationPrompt;
  }

  void setMasterSwitchState(bool _state) {
    masterSwitchState = _state;
    if (_state) {
      findAtSignsToShareLocationWith();
    } else {
      deleteAllLocationKey();
    }
  }

  /// we are assuming that the _newLocationDataModel has a new share id
  /// if it has a same id already in [allAtsignsLocationData[_newLocationDataModel.receiver]]
  /// then we won't add it again
  Future<void> addMember(LocationDataModel _newLocationDataModel) async {
    if (allAtsignsLocationData[_newLocationDataModel.receiver] != null) {
      /// don't add and send again if already present
      var _receiverLocationDataModel =
          allAtsignsLocationData[_newLocationDataModel.receiver]!;

      if (_newLocationDataModel.locationSharingFor.keys.isEmpty) {
        return;
      }

      //// TODO: Might be wrong
      var _id = _newLocationDataModel.locationSharingFor.keys.first;
      if (_receiverLocationDataModel.locationSharingFor[_id] != null) {
        return;
      }
    }

    // add
    _appendLocationDataModelData([_newLocationDataModel]);

    var locationDataModel = getLocationDataModel(_newLocationDataModel
        .receiver); // get updated (aggregated LocationDataModel)

    if (locationDataModel == null) {
      return;
    }

    var myLocation = await getMyLocation();
    if (myLocation != null) {
      if (masterSwitchState) {
        await prepareLocationDataAndSend(
            locationDataModel.receiver, locationDataModel, myLocation);
      } else {
        /// method from main app
        if (locationPromptDialog != null) {
          // _appendLocationDataModelData([locationDataModel]);
          locationPromptDialog!();

          /// return as when main switch is turned on, it will send location to all.
          return;
        }
      }
    } else {
      // ignore: unnecessary_null_comparison
      if (AtLocationNotificationListener().navKey != null) {
        CustomToast().show('Location permission not granted',
            AtLocationNotificationListener().navKey.currentContext!,
            isError: true);
      }
    }
  }

  void removeMember(String inviteId, List<String> atsignsToRemove,
      {bool isSharing = false,
      required bool isExited,
      required bool isAccepted}) async {
    // LocationNotificationModel? locationNotificationModel;
    // atsignsToShareLocationWith.removeWhere((element) {
    //   if (key!.contains(element!.key!)) locationNotificationModel = element;
    //   return key.contains(element.key!);
    // });
    // if (locationNotificationModel != null) {
    //   await sendNull(locationNotificationModel!);
    // }

    // print(
    // 'after deleting atsignsToShareLocationWith length ${atsignsToShareLocationWith.length}');

    inviteId = trimAtsignsFromKey(inviteId);

    List<String> updatedAtsigns = [], atsignsToDelete = [];
    allAtsignsLocationData.forEach((key, value) {
      atsignsToRemove.forEach((atsignToRemove) {
        if ((compareAtSign(key, atsignToRemove)) &&
            (allAtsignsLocationData[key]?.locationSharingFor[inviteId] !=
                null)) {
          allAtsignsLocationData[key]
              ?.locationSharingFor[inviteId]!
              .isAccepted = isAccepted;
          allAtsignsLocationData[key]?.locationSharingFor[inviteId]!.isSharing =
              isSharing;
          allAtsignsLocationData[key]?.locationSharingFor[inviteId]!.isExited =
              isExited;

          updatedAtsigns.add(key);

          // .remove(inviteId);
          // if (allAtsignsLocationData[key]?.locationSharingFor.isEmpty ??
          //     false) {
          //   atsignsToDelete.add(key);
          // } else {
          // so that we dont update and delete the same key
          // updatedAtsigns.add(key);
          // }
        }
      });
    });
    if (updatedAtsigns.isNotEmpty) {
      await sendLocationAfterDataUpdate(updatedAtsigns);
    }

    if (atsignsToDelete.isNotEmpty) {
      await sendNull(atsignsToDelete);
    }
  }

  sendLocationAfterDataUpdate(List<String> atsignsUpdated) async {
    var _currentMyLatLng = await getMyLocation();
    // if (_currentMyLatLng == null) {
    //   return;
    // }

    await Future.forEach(atsignsUpdated, (String atsign) async {
      if ((allAtsignsLocationData[atsign] != null)) {
        bool isLocSharing = false;

        for (var key
            in allAtsignsLocationData[atsign]!.locationSharingFor.entries) {
          if (allAtsignsLocationData[atsign]!
              .locationSharingFor[key]!
              .isSharing) {
            isLocSharing = true;
            break;
          }
        }

        await prepareLocationDataAndSend(
            atsign,
            allAtsignsLocationData[atsign]!,
            (isLocSharing
                ? _currentMyLatLng ?? allAtsignsLocationData[atsign]!.getLatLng
                : null));

        /// send last latLng if _currentMyLatLng is null
      }
    });
  }

  void sendLocation() async {
    var permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      //// TODO: send location to only [_atsignsToSendLocationwith], for first time

      /// The stream doesnt run until 100m is covered
      /// So, we send data once
      // var _currentMyLatLng = await getMyLocation();

      // if (_currentMyLatLng != null && masterSwitchState) {
      //   for (var field in allAtsignsLocationData.entries) {
      //     await prepareLocationDataAndSend(field.key, field.value,
      //         LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
      //   }

      //   // await Future.forEach(atsignsToShareLocationWith,
      //   //     (dynamic notification) async {
      //   //   // ignore: await_only_futures
      //   //   await prepareLocationDataAndSend(notification,
      //   //       LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
      //   // });
      // }

      ///
      positionStream = Geolocator.getPositionStream(distanceFilter: 100)
          .listen((myLocation) async {
        //// TODO: send location only when myLocation has changed
        print(
            'myLocation.latitude : ${myLocation.latitude}, long : ${myLocation.longitude}');
        if (masterSwitchState) {
          for (var field in allAtsignsLocationData.entries) {
            print(
                'sending to atsign : ${field.key}, value : ${field.value.locationSharingFor}');
            await prepareLocationDataAndSend(field.key, field.value,
                LatLng(myLocation.latitude, myLocation.longitude));
          }
          // await Future.forEach(atsignsToShareLocationWith,
          //     (dynamic notification) async {
          //   // ignore: unawaited_futures
          //   prepareLocationDataAndSend(notification,
          //       LatLng(myLocation.latitude, myLocation.longitude));
          // });
        }
      });
    }
  }

  Future<void> prepareLocationDataAndSend(String receiver,
      LocationDataModel locationData, LatLng? myLocation) async {
    var isSend = true;

    //// TODO: Send location to only those whose from and to is between DateTime.now()
    // for (var field in locationData.locationSharingFor.entries) {
    //   if ((field.value.from == null) && (field.value.to == null)) {
    //     isSend = true;
    //     break;
    //   }

    //   if (field.value.from != null) {
    //     isSend = true;
    //     if (DateTime.now().isBefore(field.value.from!)) {
    //       isSend = false;
    //     }
    //   }
    // }

    // if (locationData. == null) {
    //   isSend = true;
    // } else if ((DateTime.now().difference(notification.from!) >
    //         Duration(seconds: 0)) &&
    //     (notification.to!.difference(DateTime.now()) > Duration(seconds: 0))) {
    //   isSend = true;
    // }
    if (isSend) {
      // var atkeyMicrosecondId = notification.key!.split('-')[1].split('@')[0];
      var atKey = newAtKey(
          5000, '$locationKey-${receiver.replaceAll('@', '')}', receiver,
          ttl: null);

      locationData.lat = myLocation?.latitude;
      locationData.long = myLocation?.longitude;

      locationData.lastUpdatedAt = DateTime.now();

      //// TODO: Uncomment and test, to send null as latLng
      // bool _shouldSendNull = false;
      // locationData.locationSharingFor.forEach((key, value) {
      //   if ((_shouldSendNull) && (value.isSharing)) {
      //     _shouldSendNull = true;
      //   }
      // });

      // if (!_shouldSendNull) {
      //   locationData.lat = null;
      //   locationData.long = null;
      // }

      try {
        print('locationData.toJson() : ${locationData.toJson()}');
        var _res = await NotifyAndPut().notifyAndPut(
            atKey, jsonEncode(locationData.toJson()),
            saveDataIfUndelivered: true);
        // await AtClientManager.getInstance().notificationService.notify(
        //       NotificationParams.forUpdate(
        //         atKey,
        //         value: jsonEncode(locationData.toJson()),
        //       ),
        //     );

        if (_res) {
          allAtsignsLocationData[receiver] =
              locationData; // update the map if successfully sent
        }
        print('send loc data : $_res');

        // atClient!.put(
        //   atKey,
        //   LocationNotificationModel.convertLocationNotificationToJson(
        //       newLocationNotificationModel),
        // );
        // print('prepareLocationDataAndSend in location package ========> $_res');
      } catch (e) {
        print('error in sending location: $e');
      }
    }
  }

  /// will delete [locationKey] for the atsign and remove from [allAtsignsLocationData]
  Future<bool> sendNull(List<String> atsigns) async {
    var result;

    await Future.forEach(atsigns, (String _atsign) async {
      var atKey =
          newAtKey(-1, '$locationKey-${_atsign.replaceAll('@', '')}', _atsign);
      result = await atClient!.delete(
        atKey,
      );
      if (result) {
        allAtsignsLocationData.remove(_atsign); // remove from map as well
      }
      print('result : ${result}');
    });

    return result;
  }

  void deleteAllLocationKey() async {
    var response = await atClient?.getKeys(
      regex: '$locationKey',
    );
    await Future.forEach(response ?? [], (dynamic key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        var atKey = getAtKey(key);
        var result = await atClient!.delete(
          atKey,
        );
        print('$key is deleted ? $result');
      }
    });
  }

  AtKey newAtKey(int ttr, String key, String sharedWith, {int? ttl}) {
    if (sharedWith[0] != '@') {
      sharedWith = '@' + sharedWith;
    }

    String sharedBy = (atClient!.getCurrentAtSign()![0] != '@')
        ? ('@' + atClient!.getCurrentAtSign()!)
        : atClient!.getCurrentAtSign()!;
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = ttr
      ..metadata!.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = sharedBy;
    if (ttl != null) atKey.metadata!.ttl = ttl;
    return atKey;
  }

  LocationDataModel locationNotificationModelToLocationDataModel(
      LocationNotificationModel locationNotificationModel) {
    return LocationDataModel(
      {
        trimAtsignsFromKey(locationNotificationModel.key!): LocationSharingFor(
            locationNotificationModel.from!,
            locationNotificationModel.to!,
            LocationSharingType.P2P,
            locationNotificationModel.isAccepted,
            locationNotificationModel.isExited,
            locationNotificationModel.isSharing)
      },
      null,
      null,
      DateTime.now(),
      locationNotificationModel.atsignCreator!,
      locationNotificationModel.receiver!,
    );
  }
}
