import 'dart:async';
import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/common_components/custom_toast.dart';
import 'package:at_events_flutter/models/enums_model.dart';
import 'package:at_events_flutter/models/event_member_location.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

/// [masterSwitchState] will control whether location is sent to any user
///
/// [locationPromptDialog] will be called whenever package is about to send location and [masterSwitchState] is false.
///
/// Make sure that [locationPromptDialog] is a dialog or a function which can ask the user to turn the [masterSwitchState]
/// true if needed.
class EventLocationShare {
  EventLocationShare._();
  static final EventLocationShare _instance = EventLocationShare._();
  factory EventLocationShare() => _instance;

  bool masterSwitchState = true;
  StreamSubscription<Position>? positionStream;
  List<EventNotificationModel> eventsToShareLocationWith = <EventNotificationModel>[];
  Function? locationPromptDialog;

  void init() {
    _initialiseEventData();

    print('EventLocationShare init');
    for (EventNotificationModel e in eventsToShareLocationWith) {
      print(e.key);
    }
    sendLocation();
  }

  Future<void> dispose() async {
    await positionStream?.cancel();
  }

  void setLocationPrompt(Function _locationPrompt) {
    locationPromptDialog = _locationPrompt;
  }

  void setMasterSwitchState(bool _state) {
    masterSwitchState = _state;
    if (!_state) {
      init();
    } else {
      /// TODO: Turn off location in all events
      // deleteAllLocationKey();
    }
  }

  /// TODO: We can form EventMemberLocation objects here, do that we need not loop later while sending
  ///
  /// TODO: Can filter events for a specific time limit
  void _initialiseEventData() {
    eventsToShareLocationWith = <EventNotificationModel>[];

    for (int i = 0; i < EventKeyStreamService().allEventNotifications.length; i++) {
      if ((EventKeyStreamService().allEventNotifications[i].eventNotificationModel == null) ||
          (EventKeyStreamService().allEventNotifications[i].eventNotificationModel!.isCancelled == true)) {
        continue;
      }

      EventNotificationModel eventNotificationModel =
          EventKeyStreamService().allEventNotifications[i].eventNotificationModel!;

      if ((eventNotificationModel.atsignCreator == AtEventNotificationListener().currentAtSign)) {
        if (eventNotificationModel.isSharing!) {
          eventsToShareLocationWith.add(eventNotificationModel);
        }
      } else {
        AtContact? currentGroupMember;
        for (int i = 0; i < eventNotificationModel.group!.members!.length; i++) {
          if (eventNotificationModel.group!.members!.elementAt(i).atSign ==
              AtEventNotificationListener().currentAtSign) {
            currentGroupMember = eventNotificationModel.group!.members!.elementAt(i);
            break;
          }
        }

        if (currentGroupMember != null &&
            currentGroupMember.tags!['isAccepted'] == true &&
            currentGroupMember.tags!['isSharing'] == true &&
            currentGroupMember.tags!['isExited'] == false) {
          eventsToShareLocationWith.add(eventNotificationModel);
        }
      }
    }
  }

  /// Will be called from addDataToList or mapUpdatedEventDataToWidget
  Future<void> addMember(EventNotificationModel _newData) async {
    if (eventsToShareLocationWith.indexWhere((EventNotificationModel element) => element.key == _newData.key) > -1) {
      return;
    }

    LatLng? myLocation = await getMyLocation();
    if (myLocation != null) {
      if (masterSwitchState) {
        await prepareLocationDataAndSend(_newData, myLocation);
        if (MixedConstants.isDedicated) {
          // ignore: unawaited_futures
          SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
      } else {
        /// method from main app
        if (locationPromptDialog != null) {
          eventsToShareLocationWith.add(_newData);
          locationPromptDialog!();

          /// return as when main switch is turned on, it will send location to all.
          return;
        }
      }
    } else {
      if (AtEventNotificationListener().navKey != null) {
        CustomToast().show('Location permission not granted', AtEventNotificationListener().navKey!.currentContext);
      }
    }

    // add
    eventsToShareLocationWith.add(_newData);
    print('after adding atsignsToShareLocationWith length ${eventsToShareLocationWith.length}');
  }

  /// Will be called from addDataToList or mapUpdatedEventDataToWidget
  Future<void> removeMember(String? key) async {
    eventsToShareLocationWith.removeWhere((EventNotificationModel element) => key!.contains(element.key!));

    print('after deleting atsignsToShareLocationWith length ${eventsToShareLocationWith.length}');
  }

  Future<void> sendLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) || (permission == LocationPermission.whileInUse))) {
      /// The stream doesnt run until 100m is covered
      /// So, we send data once
      LatLng? _currentMyLatLng = await getMyLocation();

      if (_currentMyLatLng != null && masterSwitchState) {
        await Future.forEach(eventsToShareLocationWith, (dynamic notification) async {
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
          await Future.forEach(eventsToShareLocationWith, (dynamic notification) async {
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

  Future<void> prepareLocationDataAndSend(
      EventNotificationModel _storedEventNotificationModel, LatLng _myLocation) async {
    late EventNotificationModel _eventNotificationModel;

    /// To get updated event data
    for (int i = 0; i < EventKeyStreamService().allEventNotifications.length; i++) {
      if (EventKeyStreamService().allEventNotifications[i].eventNotificationModel!.key ==
          _storedEventNotificationModel.key) {
        _eventNotificationModel = EventKeyStreamService().allEventNotifications[i].eventNotificationModel!;
        break;
      }
    }

    // ignore: unnecessary_null_comparison
    if (_eventNotificationModel == null) {
      return;
    }

    if (_eventNotificationModel.isCancelled == true) {
      return;
    }

    if (_eventNotificationModel.atsignCreator == AtEventNotificationListener().currentAtSign) {
      DateTime _from = _eventNotificationModel.event!.startTime!;
      DateTime? _to = _eventNotificationModel.event!.endTime;

      if ((DateTime.now().difference(_from) > const Duration(seconds: 0)) &&
          (_to!.difference(DateTime.now()) > const Duration(seconds: 0))) {
        EventNotificationModel _event = EventNotificationModel.fromJson(
            jsonDecode(EventNotificationModel.convertEventNotificationToJson(_eventNotificationModel)));

        _event.lat = _myLocation.latitude;
        _event.long = _myLocation.longitude;

        await EventKeyStreamService().actionOnEvent(_event, ATKEY_TYPE_ENUM.CREATEEVENT);
      }
    } else {
      late AtContact currentGroupMember;

      /// TODO: Optimise this, dont do this on every loop. Do only once
      for (AtContact groupMember in _eventNotificationModel.group!.members!) {
        // sending location to other group members
        if (groupMember.atSign == AtEventNotificationListener().currentAtSign) {
          currentGroupMember = groupMember;
        }
      }

      DateTime _from = startTimeEnumToTimeOfDay(
          currentGroupMember.tags!['shareFrom'].toString(), _eventNotificationModel.event!.startTime)!;
      DateTime? _to = endTimeEnumToTimeOfDay(
          currentGroupMember.tags!['shareTo'].toString(), _eventNotificationModel.event!.endTime);

      if ((DateTime.now().difference(_from) > const Duration(seconds: 0)) &&
          (_to!.difference(DateTime.now()) > const Duration(seconds: 0))) {
        EventMemberLocation _data = EventMemberLocation(
            fromAtSign: AtEventNotificationListener().currentAtSign,
            receiver: _eventNotificationModel.atsignCreator,
            key: _eventNotificationModel.key,
            lat: _myLocation.latitude,
            long: _myLocation.longitude);

        String atkeyMicrosecondId = _eventNotificationModel.key!.split('-')[1].split('@')[0];

        AtKey atKey = newAtKey(5000, '${MixedConstants.eventMemberLocationKey}-$atkeyMicrosecondId',
            _eventNotificationModel.atsignCreator);

        try {
          await AtEventNotificationListener().atClientInstance!.put(
              atKey,
              EventMemberLocation.convertLocationNotificationToJson(
                _data,
              ),
              isDedicated: MixedConstants.isDedicated);
        } catch (e) {
          print('error in sending location: $e');
        }
      }
    }
  }

  AtKey newAtKey(int ttr, String key, String? sharedWith) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = ttr
      // ..metadata.ttl = MixedConstants.maxTTL
      ..metadata!.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = AtEventNotificationListener().currentAtSign;
    return atKey;
  }
}
