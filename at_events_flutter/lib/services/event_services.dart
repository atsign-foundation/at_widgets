import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/common_components/concurrent_event_request_dialog.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
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
  String currentAtSign, rootDomain;
  List<EventNotificationModel> allEvents = [];

  // ignore: close_sinks
  final _atEventNotificationController =
      StreamController<EventNotificationModel>.broadcast();
  Stream<EventNotificationModel> get eventStream =>
      _atEventNotificationController.stream;
  StreamSink<EventNotificationModel> get eventSink =>
      _atEventNotificationController.sink;

  // ignore: close_sinks
  final eventListController =
      StreamController<List<EventNotificationModel>>.broadcast();
  Stream<List<EventNotificationModel>> get eventListStream =>
      eventListController.stream;
  StreamSink<List<EventNotificationModel>> get eventListSink =>
      eventListController.sink;

  init(AtClientImpl _atClientInstance,
      {bool isUpdate, EventNotificationModel eventData, rootDomain}) {
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
    atClientInstance = _atClientInstance;
    currentAtSign = atClientInstance.currentAtSign;
    Future.delayed(Duration(milliseconds: 50), () {
      eventSink.add(eventNotificationModel);
    });

    if (rootDomain != null) this.rootDomain = rootDomain;
    startMonitor();
  }

  initializeAtContactImpl(AtClientImpl _atClientInstance) {
    atClientInstance = _atClientInstance;
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    String privateKey = await getPrivateKey(currentAtSign);
    atClientInstance.startMonitor(privateKey, _notificationCallback);
    print("Monitor started");
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientInstance.getPrivateKey(atsign);
  }

  void _notificationCallback(dynamic response) async {
    print('fnCallBack called in event service');
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var operation = responseJson['operation'];
    print('_notificationCallback opeartion $operation');
    if ((operation == 'delete') &&
        atKey.toString().toLowerCase().contains('createevent')) {
      // print('$notificationKey deleted');
      // print('atKey deleted:${atKey}');
      removeDeletedEventFromList(notificationKey);
      return;
    }

    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError((e) =>
            print("error in decrypting: ${e.errorCode} ${e.errorMessage}"));
    if (atKey.toString().contains('createevent')) {
      EventNotificationModel eventData =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (eventData.isUpdate != null && eventData.isUpdate == false) {
        // new event received
        // show dialog
        // add in event list
        addNewEventInEventList(eventData);
      } else if (eventData.isUpdate) {
        // event updated received
        // update event list
        onUpdatedEventReceived(eventData);
      }
    } else if (atKey.toString().contains('eventacknowledged')) {
      EventNotificationModel msg =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('event acknowledge received:${msg.group} , ${msg.title}');
      createEventAcknowledged(msg, fromAtSign);
    }
  }

  createEventAcknowledged(
      EventNotificationModel acknowledgedEvent, String fromAtSign) async {
    print('event ack:${acknowledgedEvent.key}');
    String regexKey,
        eventId =
            acknowledgedEvent.key.split('eventacknowledged-')[1].split('@')[0];
    AtKey atKey;
    EventNotificationModel presentEventData =
        await getEventDetails('createevent-$eventId');
    print(
        'present event data:${presentEventData.title}, key:${presentEventData.key}');

    presentEventData.group.members.forEach((presentGroupMember) {
      acknowledgedEvent.group.members.forEach((acknowledgedGroupMember) {
        if (acknowledgedGroupMember.atSign == presentGroupMember.atSign &&
            acknowledgedGroupMember.atSign == fromAtSign) {
          presentGroupMember.tags = acknowledgedGroupMember.tags;
        }
      });
    });
    presentEventData.isUpdate = true;

    print(
        'present event data after update:${presentEventData.title}, key:${presentEventData.key}');

    regexKey = await getRegexKeyFromKey('createevent-$eventId');
    if (regexKey != null) {
      atKey = AtKey.fromString(regexKey);
    } else {
      print('event key not found....');
    }

    var notification =
        EventNotificationModel.convertEventNotificationToJson(presentEventData);
    var result = await atClientInstance.put(atKey, notification);
    print('event updated:${result}');
  }

  removeDeletedEventFromList(String regexKey) {
    String key = regexKey.split('createevent-')[1].split('@')[0];

    EventService()
        .allEvents
        .removeWhere((element) => element.key.contains(key));
    print('removeDeletedEventFromList after: ${EventService().allEvents}');
    EventService().eventListSink.add(EventService().allEvents);
  }

  addNewEventInEventList(EventNotificationModel newEvent) {
    if (EventService().allEvents == null) EventService().allEvents = [];
    EventService().allEvents.add(newEvent);
    EventService().eventListSink.add(EventService().allEvents);
  }

  onUpdatedEventReceived(EventNotificationModel newEvent) {
    int eventIndex = EventService()
        .allEvents
        .indexWhere((element) => element.key.contains(newEvent.key));

    if (eventIndex > -1) {
      EventService().allEvents[eventIndex] = newEvent;
      EventService().eventListSink.add(EventService().allEvents);
    }
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
      // AtKey atKey = AtKey.fromString(eventNotificationModel.key);
      // var eventData = EventNotificationModel.convertEventNotificationToJson(
      //     EventService().eventNotificationModel);
      // var result = await atClientInstance.put(atKey, eventData);
      // if (onEventSaved != null) {
      //   onEventSaved(eventNotificationModel);
      // }
      // return result;
      var result =
          await updateEvent(eventNotificationModel, eventNotificationModel.key);
      if (onEventSaved != null && result) {
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
      ..metadata.ccd = true
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
