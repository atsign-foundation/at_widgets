import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/common_components/concurrent_event_request_dialog.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:at_events_flutter/utils/texts.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

class EventService {
  EventService._();
  static EventService _instance = EventService._();
  factory EventService() => _instance;
  bool isEventUpdate = false;

  EventNotificationModel eventNotificationModel;
  AtClientImpl atClientInstance;
  List<AtContact> selectedContacts;
  List<HybridNotificationModel> createdEvents;
  Function onEventSaved;

  // ignore: close_sinks
  final _atEventNotificationController =
      StreamController<EventNotificationModel>.broadcast();
  Stream<EventNotificationModel> get eventStream =>
      _atEventNotificationController.stream;
  StreamSink<EventNotificationModel> get eventSink =>
      _atEventNotificationController.sink;

  init(AtClientImpl _atClientInstance, bool isUpdate,
      EventNotificationModel eventData) {
    if (eventData != null) {
      EventService().eventNotificationModel = EventNotificationModel.fromJson(
          jsonDecode(EventNotificationModel.convertEventNotificationToJson(
              eventData)));
      createContactListFromGroupMembers();
      update();
    } else {
      eventNotificationModel = EventNotificationModel();
      eventNotificationModel.venue = Venue();
      eventNotificationModel.event = Event();
      eventNotificationModel.group = new AtGroup('');
      selectedContacts = [];
    }
    isEventUpdate = isUpdate;
    print('isEventUpdate:$isEventUpdate');
    atClientInstance = _atClientInstance;
    Future.delayed(Duration(milliseconds: 50), () {
      eventSink.add(eventNotificationModel);
    });
  }

  update({EventNotificationModel eventData}) {
    if (eventData != null) {
      eventNotificationModel = eventData;
    }
    eventSink.add(eventNotificationModel);
  }

  createEvent({bool isEventOverlap = false, BuildContext context}) async {
    var result;
    if (isEventUpdate) {
      eventNotificationModel.isUpdate = true;
      result = await editEvent();
      return result;
    } else {
      result = await sendEventNotification();
      // if (result) EventService().onEventSaved(eventNotificationModel);
      if (result && isEventOverlap) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
      return result;
    }
  }

  Future<dynamic> editEvent() async {
    try {
      AtKey atKey = AtKey.fromString(eventNotificationModel.key);
      var eventData = EventNotificationModel.convertEventNotificationToJson(
          EventService().eventNotificationModel);
      var result = await atClientInstance.put(atKey, eventData);
      if (onEventSaved != null) {
        onEventSaved(eventNotificationModel);
      }
      return result;
    } catch (e) {
      return e;
    }
  }

  sendEventNotification() async {
    EventNotificationModel eventNotification = eventNotificationModel;
    eventNotification.isUpdate = false;
    eventNotification.isSharing = true;

    eventNotification.key =
        "createevent-${DateTime.now().microsecondsSinceEpoch}";
    eventNotification.atsignCreator = atClientInstance.currentAtSign;
    var notification = EventNotificationModel.convertEventNotificationToJson(
        EventService().eventNotificationModel);

    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..key = eventNotification.key
      ..sharedWith = eventNotification.group.members.elementAt(0).atSign
      ..sharedBy = eventNotification.atsignCreator;

    print(
        'notification data:${atKey.key}, sharedWith:${eventNotification.group.members.elementAt(0).atSign} ,notify key: ${notification}');
    var result = await atClientInstance.put(atKey, notification);
    eventNotificationModel = eventNotification;
    if (onEventSaved != null) {
      // String key =
      //     '${atKey.sharedWith}:${eventNotification.key}:${atKey.sharedBy}';
      // eventNotification.key = key;
      onEventSaved(eventNotification);
    }
    print('send event:$result');
    return result;
  }

  addNewGroupMembers(List<AtContact> selectedContactList) {
    EventService().selectedContacts = [];
    EventService().eventNotificationModel.group.members = {};

    for (AtContact selectedContact in selectedContactList) {
      EventService().selectedContacts.add(selectedContact);
      AtContact newContact = getGroupMemberContact(selectedContact);
      EventService().eventNotificationModel.group.members.add(newContact);
    }
  }

  createContactListFromGroupMembers() {
    selectedContacts = [];
    for (AtContact contact
        in EventService().eventNotificationModel.group.members) {
      selectedContacts.add(contact);
    }
  }

  AtContact getGroupMemberContact(AtContact atcontact) {
    AtContact newContact = AtContact(atSign: atcontact.atSign);
    newContact.tags = {};
    newContact.tags['isAccepted'] = false;
    newContact.tags['isSharing'] = true;
    newContact.tags['isExited'] = false;
    newContact.tags['lat'] = 0;
    newContact.tags['long'] = 0;
    newContact.tags['shareFrom'] = -1;
    newContact.tags['shareTo'] = -1;
    return newContact;
  }

  removeSelectedContact(int index) {
    if (eventNotificationModel.group.members.length > index &&
        selectedContacts.length > index) {
      eventNotificationModel.group.members.removeWhere(
          (element) => element.atSign == selectedContacts[index].atSign);
      selectedContacts.removeAt(index);
    }
  }

  bool showConcurrentEventDialog(List<HybridNotificationModel> createdEvents,
      EventNotificationModel newEvent, BuildContext context) {
    if (!isEventUpdate && createdEvents != null && createdEvents.length > 0) {
      var isOverlapData =
          isEventTimeSlotOverlap(createdEvents, eventNotificationModel);
      if (isOverlapData[0]) {
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return ConcurrentEventRequest(concurrentEvent: isOverlapData[1]);
            });

        return isOverlapData[0];
      } else
        return isOverlapData[0];
    } else
      return false;
  }

  dynamic isEventTimeSlotOverlap(List<HybridNotificationModel> hybridEvents,
      EventNotificationModel newEvent) {
    bool isOverlap = false;
    EventNotificationModel overlapEvent = EventNotificationModel();

    hybridEvents.forEach((element) {
      if (!element.eventNotificationModel.event.isRecurring) {
        if (dateToString(element.eventNotificationModel.event.date) ==
            dateToString(newEvent.event.date)) {
          Event event = element.eventNotificationModel.event;
          if (event.startTime.hour >= newEvent.event.startTime.hour &&
              event.startTime.hour <= newEvent.event.endTime.hour) {
            isOverlap = true;
            overlapEvent = element.eventNotificationModel;
          }
          if (event.startTime.hour <= newEvent.event.startTime.hour &&
              event.endTime.hour >= newEvent.event.endTime.hour) {
            isOverlap = true;
            overlapEvent = element.eventNotificationModel;
          }
          if (event.endTime.hour >= newEvent.event.startTime.hour &&
              event.endTime.hour <= newEvent.event.endTime.hour) {
            isOverlap = true;
            overlapEvent = element.eventNotificationModel;
          }
        }
      }
    });
    return [isOverlap, overlapEvent];
  }

  dynamic createEventFormValidation() {
    EventNotificationModel eventData = EventService().eventNotificationModel;
    if (eventData.group.members == null || eventData.group.members.length < 1) {
      return 'add contacts';
    } else if (eventData.title == null || eventData.title.trim().length < 1) {
      return 'add title';
    } else if (eventData.venue == null ||
        eventData.venue.label == null ||
        eventData.venue.latitude == null ||
        eventData.venue.longitude == null) {
      return 'add venue';
    } else if (eventData.event.isRecurring == null) {
      return 'select event type';
    } else if (eventData.event.isRecurring == false &&
        checForOneDayEventFormValidation(eventData) is String) {
      return checForOneDayEventFormValidation(eventData);
    } else if (eventData.event.isRecurring == true &&
        checForRecurringeDayEventFormValidation(eventData) is String) {
      return checForRecurringeDayEventFormValidation(eventData);
    } else {
      return true;
    }
  }

  dynamic checForOneDayEventFormValidation(EventNotificationModel eventData) {
    if (eventData.event.date == null) {
      return 'add event date';
    } else if (eventData.event.startTime == null) {
      return 'add event start time';
    } else if (eventData.event.endTime == null) {
      return 'add event end time';
    } else
      return true;
  }

  dynamic checForRecurringeDayEventFormValidation(
      EventNotificationModel eventData) {
    if (eventData.event.repeatDuration == null) {
      return 'add repeat cycle';
    }
    if (eventData.event.repeatCycle == null) {
      return 'add repeat cycle category';
    } else if (eventData.event.repeatCycle == RepeatCycle.WEEK &&
        eventData.event.occursOn == null) {
      return 'select event day';
    } else if (eventData.event.repeatCycle == RepeatCycle.MONTH &&
        eventData.event.date == null) {
      return 'select event date';
    } else if (eventData.event.startTime == null) {
      return 'add event start time';
    } else if (eventData.event.endTime == null) {
      return 'add event end time';
    } else if (eventData.event.endsOn == null) {
      return 'add event ending details';
    } else if (eventData.event.endsOn == EndsOn.ON &&
        eventData.event.endEventOnDate == null) {
      return 'add end event date';
    } else if (eventData.event.endsOn == EndsOn.AFTER &&
        eventData.event.endEventAfterOccurance == null) {
      return 'add event occurance';
    }
  }
}
