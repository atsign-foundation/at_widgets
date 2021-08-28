import 'package:at_contact/src/model/at_contact.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/notification_dialog/event_notification_dialog.dart';
import 'package:flutter/material.dart';

import 'at_event_notification_listener.dart';

class HomeEventService {
  HomeEventService._();
  static final HomeEventService _instance = HomeEventService._();
  factory HomeEventService() => _instance;

  bool isActionRequired(EventNotificationModel event) {
    if (event.isCancelled!) return true;

    bool isRequired = true;
    String? currentAtsign = AtEventNotificationListener().atClientInstance!.currentAtSign;

    if (event.group!.members!.isEmpty) return true;

    for (AtContact member in event.group!.members!) {
      if (member.atSign![0] != '@') member.atSign = '@' + member.atSign!;
      if (currentAtsign![0] != '@') currentAtsign = '@' + currentAtsign;

      if ((member.tags!['isAccepted'] != null && member.tags!['isAccepted'] == true) &&
          member.tags!['isExited'] == false &&
          member.atSign!.toLowerCase() == currentAtsign.toLowerCase()) {
        isRequired = false;
      }
    }

    if (event.atsignCreator == currentAtsign) isRequired = false;

    return isRequired;
  }

  String getActionString(EventNotificationModel event, bool haveResponded) {
    if (event.isCancelled!) return 'Cancelled';
    String label = 'Action required';
    String? currentAtsign = AtEventNotificationListener().atClientInstance!.currentAtSign;

    if (event.group!.members!.isEmpty) return '';

    for (AtContact member in event.group!.members!) {
      if (member.atSign![0] != '@') member.atSign = '@' + member.atSign!;
      if (currentAtsign![0] != '@') currentAtsign = '@' + currentAtsign;

      if (member.tags!['isExited'] != null &&
          member.tags!['isExited'] == true &&
          member.atSign!.toLowerCase() == currentAtsign.toLowerCase()) {
        label = 'Request declined';
      } else if (member.tags!['isExited'] != null &&
          member.tags!['isExited'] == false &&
          member.tags!['isAccepted'] != null &&
          member.tags!['isAccepted'] == false &&
          member.atSign!.toLowerCase() == currentAtsign.toLowerCase() &&
          haveResponded) {
        label = 'Pending request';
      }
    }

    return label;
  }

  String getSubTitle(EventNotificationModel _event) {
    return _event.event != null
        ? _event.event!.date != null
            ? 'Event on ${dateToString(_event.event!.date!)}'
            : ''
        : '';
  }

  String? getSemiTitle(EventNotificationModel _event, bool _haveResponded) {
    return _event.group != null
        ? (isActionRequired(_event))
            ? getActionString(_event, _haveResponded)
            : null
        : 'Action required';
  }

  bool calculateShowRetry(EventKeyLocationModel _eventKeyModel) {
    if ((_eventKeyModel.eventNotificationModel!.group != null) &&
        (isActionRequired(_eventKeyModel.eventNotificationModel!)) &&
        (_eventKeyModel.haveResponded)) {
      if (getActionString(_eventKeyModel.eventNotificationModel!, _eventKeyModel.haveResponded) == 'Pending request') {
        return true;
      }
      return false;
    }
    return false;
  }

  Future<EventNotificationDialog?>? onEventModelTap(
      EventNotificationModel eventNotificationModel, bool haveResponded) async {
    if (isActionRequired(eventNotificationModel) && !eventNotificationModel.isCancelled!) {
      if (haveResponded) {
        return null;
      }
      return showDialog<EventNotificationDialog>(
        context: AtEventNotificationListener().navKey!.currentContext!,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return EventNotificationDialog(eventData: eventNotificationModel);
        },
      );
    }

    eventNotificationModel.isUpdate = true;

    /// Move to map screen
    await EventsMapScreenData().moveToEventScreen(eventNotificationModel);
  }
}
