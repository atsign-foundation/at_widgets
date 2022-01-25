import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/notification_dialog/event_notification_dialog.dart';
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:flutter/material.dart';

import 'at_event_notification_listener.dart';

class HomeEventService {
  HomeEventService._();
  static final HomeEventService _instance = HomeEventService._();
  factory HomeEventService() => _instance;

  bool isActionRequired(EventNotificationModel event) {
    if (isEventCancelled(event)) return true;

    /// for creator it can only be cancelled state
    if (compareAtSign(event.atsignCreator!,
        AtClientManager.getInstance().atClient.getCurrentAtSign()!)) {
      return false;
    }

    var _eventInfo = getMyEventInfo(event);

    if (_eventInfo == null) {
      return true;
    }

    if (_eventInfo.isExited) {
      return true;
    }

    if (!_eventInfo.isAccepted) {
      return true;
    } else {
      return false;
    }
  }

  String getActionString(EventNotificationModel event, bool haveResponded) {
    if (isEventCancelled(event)) return 'Cancelled';

    /// for creator it can only be cancelled state
    if (compareAtSign(event.atsignCreator!,
        AtClientManager.getInstance().atClient.getCurrentAtSign()!)) {
      return '';
    }

    var _eventInfo = getMyEventInfo(event);

    if (_eventInfo == null) {
      return 'Action required';
    }

    if (_eventInfo.isExited) {
      return 'Request declined';
    }

    if (!_eventInfo.isAccepted) {
      return 'Action required';
    } else {
      return '';
    }
  }

  String getSubTitle(EventNotificationModel _event) {
    return _event.event != null
        ? _event.event!.date != null
            ? 'Event on ${dateToString(_event.event!.date!)}'
            : ''
        : '';
  }

  String? getSemiTitle(EventNotificationModel _event, bool _haveResponded) {
    return (isActionRequired(_event))
        ? getActionString(_event, _haveResponded)
        : null;
  }

  bool calculateShowRetry(EventKeyLocationModel _eventKeyModel) {
    if ((_eventKeyModel.eventNotificationModel!.group != null) &&
        (isActionRequired(_eventKeyModel.eventNotificationModel!)) &&
        (_eventKeyModel.haveResponded)) {
      if (getActionString(_eventKeyModel.eventNotificationModel!,
              _eventKeyModel.haveResponded) ==
          'Pending request') {
        return true;
      }
      return false;
    }
    return false;
  }

  // ignore: always_declare_return_types
  onEventModelTap(
      EventNotificationModel eventNotificationModel, bool haveResponded) {
    if (isActionRequired(eventNotificationModel) &&
        !isEventCancelled(eventNotificationModel)) {
      if (haveResponded) {
        eventNotificationModel.isUpdate = true;
        EventsMapScreenData().moveToEventScreen(eventNotificationModel);
        return null;
      }
      return showDialog<void>(
        context: AtEventNotificationListener().navKey!.currentContext!,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return EventNotificationDialog(eventData: eventNotificationModel);
        },
      );
    }

    eventNotificationModel.isUpdate = true;

    /// Move to map screen
    EventsMapScreenData().moveToEventScreen(eventNotificationModel);
  }

  /// will return for event's for which i am member
  EventInfo? getMyEventInfo(EventNotificationModel _event) {
    String _id = trimAtsignsFromKey(_event.key!);
    String? _atsign;

    if (!compareAtSign(_event.atsignCreator!,
        AtClientManager.getInstance().atClient.getCurrentAtSign()!)) {
      _atsign = _event.atsignCreator;
    }

    if (_atsign == null && _event.group!.members!.isNotEmpty) {
      Set<AtContact>? groupMembers = _event.group!.members!;

      for (var member in groupMembers) {
        if (!compareAtSign(member.atSign!,
            AtClientManager.getInstance().atClient.getCurrentAtSign()!)) {
          _atsign = member.atSign;
          break;
        }
      }
    }

    if (SendLocationNotification().allAtsignsLocationData[_atsign] != null) {
      if (SendLocationNotification()
              .allAtsignsLocationData[_atsign]!
              .locationSharingFor[_id] !=
          null) {
        var _locationSharingFor = SendLocationNotification()
            .allAtsignsLocationData[_atsign]!
            .locationSharingFor[_id]!;

        return EventInfo(
            isSharing: _locationSharingFor.isSharing,
            isExited: _locationSharingFor.isExited,
            isAccepted: _locationSharingFor.isAccepted);
      }
    }

    for (var key in SendLocationNotification().allAtsignsLocationData.entries) {
      if (SendLocationNotification()
              .allAtsignsLocationData[key.key]!
              .locationSharingFor[_id] !=
          null) {
        var _locationSharingFor = SendLocationNotification()
            .allAtsignsLocationData[key.key]!
            .locationSharingFor[_id]!;

        return EventInfo(
            isSharing: _locationSharingFor.isSharing,
            isExited: _locationSharingFor.isExited,
            isAccepted: _locationSharingFor.isAccepted);
      }
    }
  }

  /// will return for event's for which i am creator
  EventInfo? getOtherMemberEventInfo(String _id, String _atsign) {
    _id = trimAtsignsFromKey(_id);

    // for (var key in MasterLocationService().locationReceivedData.entries) {
    if ((MasterLocationService().locationReceivedData[_atsign] != null) &&
        (MasterLocationService()
                .locationReceivedData[_atsign]!
                .locationSharingFor[_id] !=
            null)) {
      var _locationSharingFor = MasterLocationService()
          .locationReceivedData[_atsign]!
          .locationSharingFor[_id]!;

      return EventInfo(
          isSharing: _locationSharingFor.isSharing,
          isExited: _locationSharingFor.isExited,
          isAccepted: _locationSharingFor.isAccepted);
    }
    // }
  }

  bool isEventCancelled(EventNotificationModel _event) {
    EventInfo? _creatorInfo;
    if (compareAtSign(_event.atsignCreator!,
        AtClientManager.getInstance().atClient.getCurrentAtSign()!)) {
      _creatorInfo = getMyEventInfo(_event);
    } else {
      _creatorInfo =
          getOtherMemberEventInfo(_event.key!, _event.atsignCreator!);
    }

    if (_creatorInfo != null) {
      return _creatorInfo.isExited;
    } else {
      return _event.isCancelled!;
    }
  }
}
