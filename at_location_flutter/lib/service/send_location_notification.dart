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
  final String locationKey = 'locationnotify';
  List<LocationNotificationModel?> atsignsToShareLocationWith = [];
  StreamSubscription<Position>? positionStream;
  bool masterSwitchState = true;
  Function? locationPromptDialog;
  Map<String, LocationDataModel> allAtsignsLocationData = {};
  AtClient? atClient;
  bool isEventInUse = false,
      isLocationDataInitialized = false,
      isEventDataInitialized = false;

  LocationDataModel? getLocationDataModel(String _atsign) =>
      allAtsignsLocationData[_atsign];

  void init(AtClient? newAtClient) {
    if ((timer != null) && (timer!.isActive)) timer!.cancel();
    atClient = newAtClient;
    atsignsToShareLocationWith = [];
    isEventInUse = AtLocationNotificationListener().isEventInUse;
    print(
        'atsignsToShareLocationWith length - ${atsignsToShareLocationWith.length}');
    if (positionStream != null) positionStream!.cancel();
    findAtSignsToShareLocationWith();
  }

  initEventData(List<LocationDataModel> locationDataModel) {
    appendLocationDataModelData(locationDataModel);

    isEventDataInitialized = true;
    if (isLocationDataInitialized) {
      sendLocation();
    }
  }

  appendLocationDataModelData(List<LocationDataModel> locationDataModel) {
    locationDataModel.forEach((element) {
      if (allAtsignsLocationData[element.receiver] != null) {
        allAtsignsLocationData[element.receiver]!
            .locationSharingFor
            .addAll(element.locationSharingFor);
      } else {
        allAtsignsLocationData[element.receiver] = element;
      }
    });
  }

  void findAtSignsToShareLocationWith() {
    atsignsToShareLocationWith = [];

    KeyStreamService()
        .allLocationNotifications
        .forEach((KeyLocationModel notification) {
      LocationDataModel locationDataModel =
          locationNotificationModelToLocationDataModel(
              notification.locationNotificationModel!);

      if (allAtsignsLocationData[locationDataModel.receiver] != null) {
        allAtsignsLocationData[locationDataModel.receiver]!
            .locationSharingFor
            .addAll(locationDataModel.locationSharingFor);
      } else {
        allAtsignsLocationData[locationDataModel.receiver] = locationDataModel;
      }
    });

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

  Future<void> addMember(LocationDataModel _newLocationDataModel) async {
    // add
    appendLocationDataModelData([_newLocationDataModel]);

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
          // appendLocationDataModelData([locationDataModel]);
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

    print(
        'after adding atsignsToShareLocationWith length ${atsignsToShareLocationWith.length}');
  }

  void removeMember(String inviteId, List<String> atsignsToRemove) async {
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

    List<String> updatedAtsigns = [], atsignsToDelete = [];
    allAtsignsLocationData.forEach((key, value) {
      atsignsToRemove.forEach((atsignToRemove) {
        if (compareAtSign(key, atsignToRemove)) {
          allAtsignsLocationData[key]?.locationSharingFor.remove(inviteId);
          if (allAtsignsLocationData[key]?.locationSharingFor.isEmpty ??
              false) {
            atsignsToDelete.add(key);
          } else {
            // so that we dont update and delete the same key
            updatedAtsigns.add(key);
          }
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
      if ((allAtsignsLocationData[atsign] != null) &&
          (_currentMyLatLng != null ||
              allAtsignsLocationData[atsign]!.getLatLng != null)) {
        await prepareLocationDataAndSend(
            atsign,
            allAtsignsLocationData[atsign]!,
            _currentMyLatLng ?? allAtsignsLocationData[atsign]!.getLatLng!);

        /// send last latLng if _currentMyLatLng is null
      }
    });
  }

  void sendLocation() async {
    var permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      /// The stream doesnt run until 100m is covered
      /// So, we send data once
      var _currentMyLatLng = await getMyLocation();

      if (_currentMyLatLng != null && masterSwitchState) {
        for (var field in allAtsignsLocationData.entries) {
          await prepareLocationDataAndSend(field.key, field.value,
              LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
        }

        // await Future.forEach(atsignsToShareLocationWith,
        //     (dynamic notification) async {
        //   // ignore: await_only_futures
        //   await prepareLocationDataAndSend(notification,
        //       LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
        // });
      }

      ///
      positionStream = Geolocator.getPositionStream(distanceFilter: 100)
          .listen((myLocation) async {
        if (masterSwitchState) {
          for (var field in allAtsignsLocationData.entries) {
            await prepareLocationDataAndSend(field.key, field.value,
                LatLng(_currentMyLatLng!.latitude, _currentMyLatLng.longitude));
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
      LocationDataModel locationData, LatLng myLocation) async {
    var isSend = false;

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
      var atKey = newAtKey(5000, '$locationKey-$receiver', receiver, ttl: null);

      locationData.lat = myLocation.latitude;
      locationData.long = myLocation.longitude;

      locationData.lastUpdatedAt = DateTime.now();

      try {
        print('locationData.toJson() : ${locationData.toJson()}');
        var _res =
            await AtClientManager.getInstance().notificationService.notify(
                  NotificationParams.forUpdate(
                    atKey,
                    value: jsonEncode(locationData.toJson()),
                  ),
                );

        if (_res.notificationStatusEnum == NotificationStatusEnum.delivered) {
          allAtsignsLocationData[receiver] =
              locationData; // update the map if successfully sent
        }
        print('send loc data : ${_res}');

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
      var atKey = newAtKey(-1, '$locationKey-$_atsign', _atsign);
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

  AtKey newAtKey(int ttr, String key, String? sharedWith, {int? ttl}) {
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = ttr
      ..metadata!.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = atClient!.getCurrentAtSign();
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
            LocationSharingType.P2P)
      },
      null,
      null,
      DateTime.now(),
      locationNotificationModel.atsignCreator!,
      locationNotificationModel.receiver!,
    );
  }
}
