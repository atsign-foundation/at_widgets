import 'dart:async';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
import 'key_stream_service.dart';

/// [masterSwitchState] will control whether location is sent to any user
///
/// [locationPromptDialog] will be called whenever package is about to send location and [masterSwitchState] is false.
///
/// Make sure that [locationPromptDialog] is a dialog or a function which can ask the user to turn the [masterSwitchState]
/// true if needed.
class SendLocationNotification {
  SendLocationNotification._();
  static final SendLocationNotification _instance = SendLocationNotification._();
  factory SendLocationNotification() => _instance;
  Timer? timer;
  final String locationKey = 'locationnotify';
  List<LocationNotificationModel?> atsignsToShareLocationWith = <LocationNotificationModel?>[];
  StreamSubscription<Position>? positionStream;
  bool masterSwitchState = true;
  Function? locationPromptDialog;

  AtClientImpl? atClient;

  void init(AtClientImpl? newAtClient) {
    if ((timer != null) && (timer!.isActive)) timer!.cancel();
    atClient = newAtClient;
    atsignsToShareLocationWith = <LocationNotificationModel?>[];
    print('atsignsToShareLocationWith length - ${atsignsToShareLocationWith.length}');
    if (positionStream != null) positionStream!.cancel();
    findAtSignsToShareLocationWith();
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

  void findAtSignsToShareLocationWith() {
    atsignsToShareLocationWith = <LocationNotificationModel?>[];
    for (KeyLocationModel notification in KeyStreamService().allLocationNotifications) {
      if ((notification.locationNotificationModel!.atsignCreator == atClient!.currentAtSign) &&
          (notification.locationNotificationModel!.isSharing) &&
          (notification.locationNotificationModel!.isAccepted) &&
          (!notification.locationNotificationModel!.isExited)) {
        atsignsToShareLocationWith.add(notification.locationNotificationModel);
      }
    }

    sendLocation();
  }

  void dispose() {
    positionStream?.cancel();
  }

  Future<void> addMember(LocationNotificationModel? notification) async {
    if (atsignsToShareLocationWith
            .indexWhere((LocationNotificationModel? element) => element!.key == notification!.key) >
        -1) {
      return;
    }

    LatLng? myLocation = await getMyLocation();
    if (myLocation != null) {
      if (masterSwitchState) {
        await prepareLocationDataAndSend(notification!, myLocation);

        if (MixedConstants.isDedicated) {
          // ignore: unawaited_futures
          SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
      } else {
        /// method from main app
        if (locationPromptDialog != null) {
          atsignsToShareLocationWith.add(notification);
          locationPromptDialog!();

          /// return as when main switch is turned on, it will send location to all.
          return;
        }
      }
    } else {
      // ignore: unnecessary_null_comparison
      if (AtLocationNotificationListener().navKey != null) {
        CustomToast().show('Location permission not granted', AtLocationNotificationListener().navKey.currentContext!);
      }
    }

    // add
    atsignsToShareLocationWith.add(notification);
    print('after adding atsignsToShareLocationWith length ${atsignsToShareLocationWith.length}');
  }

  Future<void> removeMember(String? key) async {
    LocationNotificationModel? locationNotificationModel;
    atsignsToShareLocationWith.removeWhere((LocationNotificationModel? element) {
      if (key!.contains(element!.key!)) locationNotificationModel = element;
      return key.contains(element.key!);
    });
    if (locationNotificationModel != null) {
      await sendNull(locationNotificationModel!);
    }

    print('after deleting atsignsToShareLocationWith length ${atsignsToShareLocationWith.length}');
  }

  Future<void> sendLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) || (permission == LocationPermission.whileInUse))) {
      /// The stream doesnt run until 100m is covered
      /// So, we send data once
      LatLng? _currentMyLatLng = await getMyLocation();

      if (_currentMyLatLng != null && masterSwitchState) {
        await Future.forEach(atsignsToShareLocationWith, (dynamic notification) async {
          // ignore: await_only_futures
          await prepareLocationDataAndSend(notification, LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
        });
        if (MixedConstants.isDedicated) {
          // ignore: unawaited_futures
          SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
      }

      ///
      positionStream = Geolocator.getPositionStream(distanceFilter: 100).listen((Position myLocation) async {
        if (masterSwitchState) {
          await Future.forEach(atsignsToShareLocationWith, (dynamic notification) async {
            // ignore: unawaited_futures
            prepareLocationDataAndSend(notification, LatLng(myLocation.latitude, myLocation.longitude));
          });
          if (MixedConstants.isDedicated) {
            // ignore: unawaited_futures
            SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
          }
        }
      });
    }
  }

  Future<void> prepareLocationDataAndSend(LocationNotificationModel notification, LatLng myLocation) async {
    bool isSend = false;

    if (notification.to == null) {
      isSend = true;
    } else if ((DateTime.now().difference(notification.from!) > const Duration(seconds: 0)) &&
        (notification.to!.difference(DateTime.now()) > const Duration(seconds: 0))) {
      isSend = true;
    }
    if (isSend) {
      String atkeyMicrosecondId = notification.key!.split('-')[1].split('@')[0];
      AtKey atKey = newAtKey(5000, 'locationnotify-$atkeyMicrosecondId', notification.receiver,
          ttl: (notification.to != null) ? notification.to!.difference(DateTime.now()).inMilliseconds : null);

      LocationNotificationModel newLocationNotificationModel = LocationNotificationModel()
        ..atsignCreator = notification.atsignCreator
        ..receiver = notification.receiver
        ..isAccepted = notification.isAccepted
        ..isAcknowledgment = notification.isAcknowledgment
        ..isExited = notification.isExited
        ..isRequest = notification.isRequest
        ..isSharing = notification.isSharing
        ..from = DateTime.now()
        ..to = notification.to
        ..lat = myLocation.latitude
        ..long = myLocation.longitude
        ..key = 'locationnotify-$atkeyMicrosecondId';
      try {
        await atClient!.put(
          atKey,
          LocationNotificationModel.convertLocationNotificationToJson(newLocationNotificationModel),
          isDedicated: MixedConstants.isDedicated,
        );
      } catch (e) {
        print('error in sending location: $e');
      }
    }
  }

  Future<bool> sendNull(LocationNotificationModel locationNotificationModel) async {
    String atkeyMicrosecondId = locationNotificationModel.key!.split('-')[1].split('@')[0];
    AtKey atKey = newAtKey(-1, 'locationnotify-$atkeyMicrosecondId', locationNotificationModel.receiver);
    bool result = await atClient!.delete(atKey, isDedicated: MixedConstants.isDedicated);
    print('$atKey delete operation $result');
    if (result) {
      if (MixedConstants.isDedicated) {
        await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
      }
    }
    return result;
  }

  Future<void> deleteAllLocationKey() async {
    List<String> response = await atClient!.getKeys(
      regex: locationKey,
    );
    await Future.forEach(response, (dynamic key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        AtKey atKey = getAtKey(key);
        bool result = await atClient!.delete(atKey, isDedicated: MixedConstants.isDedicated);
        print('$key is deleted ? $result');
      }
    });

    if (MixedConstants.isDedicated) {
      await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
    }
  }

  AtKey newAtKey(int ttr, String key, String? sharedWith, {int? ttl}) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = ttr
      ..metadata!.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = atClient!.currentAtSign;
    if (ttl != null) atKey.metadata!.ttl = ttl;
    return atKey;
  }
}
