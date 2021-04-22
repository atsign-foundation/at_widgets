import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/common_components/concurrent_event_request_dialog.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/models/hybrid_notifiation_model.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_lookup/at_lookup.dart';

class EventService {
  EventService._();
  static final EventService _instance = EventService._();
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

  void init({bool isUpdate, EventNotificationModel eventData, rootDomain}) {
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
      eventNotificationModel.group = AtGroup('');
      selectedContacts = [];
    }
    isEventUpdate = isUpdate;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      eventSink.add(eventNotificationModel);
    });
  }

  void initializeAtContactImpl(
      AtClientImpl _atClientInstance, String rootDomain) {
    atClientInstance = _atClientInstance;
    currentAtSign = atClientInstance.currentAtSign;
    this.rootDomain = rootDomain;
    startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    var privateKey = await getPrivateKey(currentAtSign);
    atClientInstance.startMonitor(privateKey, _notificationCallback);
    print('Monitor started');
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
      removeDeletedEventFromList(notificationKey);
      return;
    }

    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError((e) {
      print('error in decrypting: $e');
    });
    print('decrypted message:$decryptedMessage');
    if (atKey.toString().contains('createevent')) {
      var eventData =
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
      var msg = EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('event acknowledge received:${msg.group} , ${msg.title}');
      createEventAcknowledged(msg, fromAtSign, atKey);
    }
  }

  void createEventAcknowledged(EventNotificationModel acknowledgedEvent,
      String fromAtSign, String key) async {
    String regexKey, eventId = key.split('eventacknowledged-')[1].split('@')[0];
    AtKey atKey;
    var presentEventData = await getEventDetails('createevent-$eventId');

    presentEventData.group.members.forEach((presentGroupMember) {
      acknowledgedEvent.group.members.forEach((acknowledgedGroupMember) {
        if (acknowledgedGroupMember.atSign[0] != '@') {
          acknowledgedGroupMember.atSign = '@' + acknowledgedGroupMember.atSign;
        }

        if (presentGroupMember.atSign[0] != '@') {
          presentGroupMember.atSign = '@' + presentGroupMember.atSign;
        }

        if (acknowledgedGroupMember.atSign == presentGroupMember.atSign &&
            acknowledgedGroupMember.atSign == fromAtSign) {
          presentGroupMember.tags = acknowledgedGroupMember.tags;
        }
      });
    });
    presentEventData.isUpdate = true;

    regexKey = await getRegexKeyFromKey('createevent-$eventId');
    if (regexKey != null) {
      atKey = getAtKey(regexKey);
    } else {
      return;
    }

    var notification =
        EventNotificationModel.convertEventNotificationToJson(presentEventData);
    var result = await atClientInstance.put(atKey, notification);
    if (result != null && result) {
      onUpdatedEventReceived(presentEventData);
    }
  }

  void removeDeletedEventFromList(String regexKey) {
    var key = regexKey.split('createevent-')[1].split('@')[0];

    EventService()
        .allEvents
        .removeWhere((element) => element.key.contains(key));

    EventService().eventListSink.add(EventService().allEvents);
  }

  void addNewEventInEventList(EventNotificationModel newEvent) {
    if (EventService().allEvents == null) EventService().allEvents = [];
    EventService().allEvents.add(newEvent);
    EventService().eventListSink.add(EventService().allEvents);
  }

  void onUpdatedEventReceived(EventNotificationModel newEvent) {
    var eventIndex = EventService()
        .allEvents
        .indexWhere((element) => element.key.contains(newEvent.key));

    if (eventIndex > -1) {
      EventService().allEvents[eventIndex] = newEvent;
      EventService().eventListSink.add(EventService().allEvents);
    }
  }

  void update({EventNotificationModel eventData}) {
    if (eventData != null) {
      eventNotificationModel = eventData;
    }
    eventSink.add(eventNotificationModel);
  }

  Future createEvent(
      {bool isEventOverlap = false, BuildContext context}) async {
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

  Future<bool> sendEventNotification() async {
    var eventNotification = eventNotificationModel;
    eventNotification.isUpdate = false;
    eventNotification.isSharing = true;

    eventNotification.key =
        'createevent-${DateTime.now().microsecondsSinceEpoch}';
    eventNotification.atsignCreator = atClientInstance.currentAtSign;
    var notification = EventNotificationModel.convertEventNotificationToJson(
        EventService().eventNotificationModel);

    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ccd = true
      ..metadata.ttr = -1
      ..key = eventNotification.key
      ..sharedWith = eventNotification.group.members.elementAt(0).atSign
      ..sharedBy = eventNotification.atsignCreator;

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

  void addNewGroupMembers(List<AtContact> selectedContactList) {
    EventService().selectedContacts = [];
    EventService().eventNotificationModel.group.members = {};

    for (var selectedContact in selectedContactList) {
      EventService().selectedContacts.add(selectedContact);
      var newContact = getGroupMemberContact(selectedContact);
      EventService().eventNotificationModel.group.members.add(newContact);
    }
  }

  void createContactListFromGroupMembers() {
    selectedContacts = [];
    for (var contact in EventService().eventNotificationModel.group.members) {
      selectedContacts.add(contact);
    }
  }

  AtContact getGroupMemberContact(AtContact atcontact) {
    var newContact = AtContact(atSign: atcontact.atSign);
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

  void removeSelectedContact(int index) {
    if (eventNotificationModel.group.members.length > index &&
        selectedContacts.length > index) {
      eventNotificationModel.group.members.removeWhere(
          (element) => element.atSign == selectedContacts[index].atSign);
      selectedContacts.removeAt(index);
    }
  }

  bool showConcurrentEventDialog(List<HybridNotificationModel> createdEvents,
      EventNotificationModel newEvent, BuildContext context) {
    if (!isEventUpdate && createdEvents != null && createdEvents.isNotEmpty) {
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
      } else {
        return isOverlapData[0];
      }
    } else {
      return false;
    }
  }

  dynamic isEventTimeSlotOverlap(List<HybridNotificationModel> hybridEvents,
      EventNotificationModel newEvent) {
    var isOverlap = false;
    var overlapEvent = EventNotificationModel();

    hybridEvents.forEach((element) {
      if (!element.eventNotificationModel.event.isRecurring) {
        if (dateToString(element.eventNotificationModel.event.date) ==
            dateToString(newEvent.event.date)) {
          var event = element.eventNotificationModel.event;
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

  Future sendEventAcknowledgement(EventNotificationModel acknowledgedEvent,
      {bool isAccepted, bool isSharing, bool isExited}) async {
    var eventData = EventNotificationModel.fromJson(jsonDecode(
        EventNotificationModel.convertEventNotificationToJson(
            acknowledgedEvent)));
    String atkeyMicrosecondId,
        currentAtsign = EventService().atClientInstance.currentAtSign;
    atkeyMicrosecondId = eventData.key.split('createevent-')[1].split('@')[0];

    eventData.group.members.forEach((member) {
      if (member.atSign[0] != '@') member.atSign = '@' + member.atSign;
      if (currentAtsign[0] != '@') currentAtsign = '@' + currentAtsign;

      if (member.atSign == currentAtsign) {
        member.tags['isAccepted'] = isAccepted ?? member.tags['isAccepted'];
        member.tags['isSharing'] = isSharing ?? member.tags['isSharing'];
        member.tags['isExited'] = isExited ?? member.tags['isExited'];
      }
    });

    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..metadata.ccd = true
      ..sharedWith = eventData.atsignCreator
      ..sharedBy = currentAtsign;
    atKey.key = 'eventacknowledged-$atkeyMicrosecondId';
    eventData.key = atKey.key;

    var notification =
        EventNotificationModel.convertEventNotificationToJson(eventData);

    var result = await EventService().atClientInstance.put(atKey, notification);
    return result;
  }

  Future<bool> checkAtsign(String atsign) async {
    if (atsign == null) {
      return false;
    } else if (!atsign.contains('@')) {
      atsign = '@' + atsign;
    }
    var checkPresence =
        await AtLookupImpl.findSecondary(atsign, rootDomain, 64);
    return checkPresence != null;
  }

  dynamic createEventFormValidation() {
    var eventData = EventService().eventNotificationModel;
    if (eventData.group.members == null || eventData.group.members.isEmpty) {
      return 'add contacts';
    } else if (eventData.title == null || eventData.title.trim().isEmpty) {
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
    }
    if (eventData.event.endDate == null) {
      return 'add event date';
    }
    if (eventData.event.startTime == null) {
      return 'add event start time';
    }
    if (eventData.event.endTime == null) {
      return 'add event end time';
    }
    // for time
    if (!isEventUpdate) {
      if (eventData.event.startTime.difference(DateTime.now()).inMinutes < 0) {
        return 'Start Time cannot be in past';
      }
    }

    if (eventData.event.endTime.difference(DateTime.now()).inMinutes < 0) {
      return 'End Time cannot be in past';
    }

    if (eventData.event.endTime
            .difference(eventData.event.startTime)
            .inMinutes <
        0) {
      print('valdation eventData.event.startTime ${eventData.event.startTime}');
      print('valdation eventData.event.endTime ${eventData.event.endTime}');

      return 'Start time cannot be after End time';
    }

    if (eventData.event.endTime == eventData.event.startTime) {
      return 'Start time and End time cannot be same';
    }
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

  AtKey getAtKey(String regexKey) {
    var atKey = AtKey.fromString(regexKey);
    atKey.metadata.ttr = -1;
    return atKey;
  }
}
