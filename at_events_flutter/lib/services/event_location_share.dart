import 'dart:async';
import 'dart:convert';

import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/models/event_member_location.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/sync_secondary.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

/// We cannot use same key for creating acknowledgments and sending location
/// as if something goes wrong and our key containing our location reaches just after I send request to turn of my location
/// Then it will again turn on my location
/// as tags in the location key will be of the previous state
class EventLocationShare {
  EventLocationShare._();
  static final EventLocationShare _instance = EventLocationShare._();
  factory EventLocationShare() => _instance;

  bool masterSwitchState = true;
  StreamSubscription<Position> positionStream;
  List<EventNotificationModel> eventsToShareLocationWith = [];

  /// TODO:
  /// Doubt, whetherwe should have some kind of list which will send
  /// Or should we use the entire events list and use it

  Future<void> addMember() async {}

  void removeMember() async {}

  void sendLocation() async {
    var permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      /// The stream doesnt run until 100m is covered
      /// So, we send data once
      var _currentMyLatLng = await getMyLocation();

      if (_currentMyLatLng != null && masterSwitchState) {
        await Future.forEach(eventsToShareLocationWith,
            (dynamic notification) async {
          // ignore: await_only_futures
          await prepareLocationDataAndSend(notification,
              LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
        });
        if (MixedConstants.isDedicated) {
          // ignore: unawaited_futures
          SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
      }

      ///
      positionStream = Geolocator.getPositionStream(distanceFilter: 100)
          .listen((myLocation) async {
        if (masterSwitchState) {
          await Future.forEach(eventsToShareLocationWith,
              (dynamic notification) async {
            // ignore: unawaited_futures
            prepareLocationDataAndSend(notification,
                LatLng(myLocation.latitude, myLocation.longitude));
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
      EventNotificationModel _eventNotificationModel,
      LatLng _myLocation) async {
    if (_eventNotificationModel.atsignCreator ==
        AtEventNotificationListener().currentAtSign) {
      var _event = EventNotificationModel.fromJson(jsonDecode(
          EventNotificationModel.convertEventNotificationToJson(
              _eventNotificationModel)));

      _event.lat = _myLocation.latitude;
      _event.long = _myLocation.longitude;

      await EventKeyStreamService()
          .actionOnEvent(_eventNotificationModel, ATKEY_TYPE_ENUM.CREATEEVENT);
    } else {
      var _data = EventMemberLocation(
          fromAtSign: AtEventNotificationListener().currentAtSign,
          receiver: _eventNotificationModel.atsignCreator,
          key: _eventNotificationModel.key,
          lat: _myLocation.latitude,
          long: _myLocation.longitude);

      /// TODO: check this
      var atkeyMicrosecondId =
          _eventNotificationModel.key.split('-')[1].split('@')[0];

      var atKey = newAtKey(
          5000,
          '${MixedConstants.EVENT_MEMBER_LOCATION_KEY}-$atkeyMicrosecondId',
          _eventNotificationModel.atsignCreator);

      try {
        await AtEventNotificationListener().atClientInstance.put(
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

  AtKey newAtKey(int ttr, String key, String sharedWith) {
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
      // ..metadata.ttl = MixedConstants.maxTTL
      ..metadata.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = AtEventNotificationListener().currentAtSign;
    return atKey;
  }
}
