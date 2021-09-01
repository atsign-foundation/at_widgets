import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_events_flutter/common_components/concurrent_event_request_dialog.dart';
import 'package:at_events_flutter/models/event_notification.dart';
// import 'package:at_events_flutter/services/sync_secondary.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

import 'event_key_stream_service.dart';

class EventService {
  EventService._();
  // ignore: prefer_final_fields
  static EventService _instance = EventService._();
  factory EventService() => _instance;
  bool isEventUpdate = false;

  EventNotificationModel? eventNotificationModel;
  late AtClientManager atClientManager;
  List<AtContact>? selectedContacts;
  List<String?> selectedContactsAtSigns = [];
  List<EventNotificationModel>? createdEvents;
  Function? onEventSaved;

  // ignore: close_sinks
  final _atEventNotificationController =
      StreamController<EventNotificationModel?>.broadcast();
  Stream<EventNotificationModel?> get eventStream =>
      _atEventNotificationController.stream;
  StreamSink<EventNotificationModel?> get eventSink =>
      _atEventNotificationController.sink;

  // ignore: always_declare_return_types
  init(AtClientManager atClientManager, bool isUpdate,
      EventNotificationModel? eventData) {
    if (eventData != null) {
      EventService().eventNotificationModel = EventNotificationModel.fromJson(
          jsonDecode(EventNotificationModel.convertEventNotificationToJson(
              eventData)));
      createContactListFromGroupMembers();
      update();
    } else {
      eventNotificationModel = EventNotificationModel();
      eventNotificationModel!.venue = Venue();
      eventNotificationModel!.event = Event();
      eventNotificationModel!.group = AtGroup('');
      selectedContacts = [];
    }
    isEventUpdate = isUpdate;
    print('isEventUpdate:$isEventUpdate');
    this.atClientManager = atClientManager;
    Future.delayed(Duration(milliseconds: 50), () {
      eventSink.add(eventNotificationModel);
    });
  }

  // ignore: always_declare_return_types
  update({EventNotificationModel? eventData}) {
    if (eventData != null) {
      eventNotificationModel = eventData;
    }
    eventSink.add(eventNotificationModel);
  }

  // ignore: always_declare_return_types
  createEvent({bool isEventOverlap = false, BuildContext? context}) async {
    var result;
    if (isEventUpdate) {
      eventNotificationModel!.isUpdate = true;
      result = await editEvent();
      return result;
    } else {
      result = await sendEventNotification();
      if (result is bool && result && isEventOverlap) {
        Navigator.of(context!).pop();
        Navigator.of(context).pop();
      }
      return result;
    }
  }

  Future<dynamic> editEvent() async {
    try {
      var atKey = getAtKey(eventNotificationModel!.key!);
      var allAtsignList = <String?>[];
      EventService().eventNotificationModel!.group!.members!.forEach((element) {
        allAtsignList.add(element.atSign);
      });

      var eventData = EventNotificationModel.convertEventNotificationToJson(
          EventService().eventNotificationModel!);
      var result = await atClientManager.atClient
          .put(atKey, eventData, isDedicated: MixedConstants.isDedicated);
      atKey.sharedWith = jsonEncode(allAtsignList);
      await SyncSecondary().callSyncSecondary(
        SyncOperation.notifyAll,
        atKey: atKey,
        notification: eventData,
        operation: OperationEnum.update,
        isDedicated: MixedConstants.isDedicated,
      );

      EventKeyStreamService()
          .mapUpdatedEventDataToWidget(eventNotificationModel!);

      /// Dont need to sync here as notifyAll is called
      if (onEventSaved != null) {
        onEventSaved!(eventNotificationModel);
      }
      return result;
    } catch (e) {
      return e;
    }
  }

  // ignore: always_declare_return_types
  sendEventNotification() async {
    try {
      var eventNotification = eventNotificationModel!;
      eventNotification.isUpdate = false;
      eventNotification.isSharing = true;

      eventNotification.key =
          'createevent-${DateTime.now().microsecondsSinceEpoch}';
      eventNotification.atsignCreator =
          atClientManager.atClient.getCurrentAtSign();
      var notification = EventNotificationModel.convertEventNotificationToJson(
          EventService().eventNotificationModel!);

      print('shared contact atsigns:$selectedContactsAtSigns');

      var atKey = AtKey()
        ..metadata = Metadata()
        ..metadata!.ttr = -1
        ..metadata!.ccd = true
        ..key = eventNotification.key
        ..sharedBy = eventNotification.atsignCreator;

      print('key: ${atKey.key}');

      var putResult = await atClientManager.atClient.put(atKey, notification,
          isDedicated:
              true); // creating a key and saving it for creator without adding any receiver atsign

      atKey.sharedWith = jsonEncode(
          [...selectedContactsAtSigns]); //adding event members in atkey

      await atClientManager.atClient.notifyAll(
        atKey,
        notification,
        OperationEnum.update,
      );

      // await SyncSecondary().callSyncSecondary(
      //   SyncOperation.notifyAll,
      //   atKey: atKey,
      //   notification: notification,
      //   operation: OperationEnum.update,
      //   isDedicated: MixedConstants.isDedicated,
      // );

      /// Dont need to sync as notifyAll is called

      await EventKeyStreamService().addDataToList(eventNotificationModel!);

      eventNotificationModel = eventNotification;
      if (onEventSaved != null) {
        onEventSaved!(eventNotification);
      }
      return putResult;
    } catch (e) {
      print('error in SendEventNotification $e');
      return e.toString();
    }
  }

  // ignore: always_declare_return_types
  addNewGroupMembers(List<AtContact> selectedContactList) {
    EventService().selectedContacts = [];
    EventService().selectedContactsAtSigns = [];
    EventService().eventNotificationModel!.group!.members = {};

    for (var selectedContact in selectedContactList) {
      EventService().selectedContacts!.add(selectedContact);
      var newContact = getGroupMemberContact(selectedContact);
      EventService().eventNotificationModel!.group!.members!.add(newContact);
      selectedContactsAtSigns.add(newContact.atSign);
    }
  }

  // ignore: always_declare_return_types
  addNewContactAndGroupMembers(List<GroupContactsModel?> selectedList) {
    EventService().selectedContacts = [];
    EventService().selectedContactsAtSigns = [];
    EventService().eventNotificationModel!.group!.members = {};

    selectedList.forEach((element) {
      if (element!.contact != null) {
        var newContact = getGroupMemberContact(element.contact!);
        // EventService().eventNotificationModel!.group!.members!.add(newContact);
        // EventService().selectedContacts!.add(newContact);
        // selectedContactsAtSigns.add(newContact.atSign);
        addContactToList(newContact);
      } else if (element.group != null) {
        element.group!.members!.forEach((groupMember) {
          var newContact = getGroupMemberContact(groupMember);
          // EventService()
          //     .eventNotificationModel!
          //     .group!
          //     .members!
          //     .add(newContact);
          // EventService().selectedContacts!.add(newContact);
          // selectedContactsAtSigns.add(newContact.atSign);
          addContactToList(newContact);
        });
      }
    });
  }

  void addContactToList(AtContact _selectedContact) {
    var _containsContact = false;

    // to prevent one contact from getting added again
    EventService().selectedContacts!.forEach((_contact) {
      if (_selectedContact.atSign == _contact.atSign) {
        _containsContact = true;
      }
    });

    if (!_containsContact) {
      EventService()
          .eventNotificationModel!
          .group!
          .members!
          .add(_selectedContact);
      EventService().selectedContacts!.add(_selectedContact);
      selectedContactsAtSigns.add(_selectedContact.atSign);
    }
  }

  // ignore: always_declare_return_types
  createContactListFromGroupMembers() {
    selectedContacts = [];
    for (var contact
        in EventService().eventNotificationModel!.group!.members!) {
      selectedContacts!.add(contact);
    }
  }

  AtContact getGroupMemberContact(AtContact atcontact) {
    var newContact = AtContact(atSign: atcontact.atSign);
    newContact.tags = {};
    newContact.tags!['isAccepted'] = false;
    newContact.tags!['isSharing'] = true;
    newContact.tags!['isExited'] = false;
    newContact.tags!['lat'] = null;
    newContact.tags!['long'] = null;
    newContact.tags!['shareFrom'] = -1;
    newContact.tags!['shareTo'] = -1;
    return newContact;
  }

  // ignore: always_declare_return_types
  removeSelectedContact(int index) {
    if (eventNotificationModel!.group!.members!.length > index &&
        selectedContacts!.length > index) {
      eventNotificationModel!.group!.members!.removeWhere(
          (element) => element.atSign == selectedContacts![index].atSign);
      selectedContacts!.removeAt(index);
      selectedContactsAtSigns.removeAt(index);
    }
  }

  bool? showConcurrentEventDialog(List<EventNotificationModel>? createdEvents,
      EventNotificationModel? newEvent, BuildContext context) {
    // ignore: prefer_is_empty
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
      } else {
        return isOverlapData[0];
      }
    } else {
      return false;
    }
  }

  dynamic isEventTimeSlotOverlap(List<EventNotificationModel?> hybridEvents,
      EventNotificationModel? newEvent) {
    var isOverlap = false;
    EventNotificationModel? overlapEvent = EventNotificationModel();

    for (var element in hybridEvents) {
      if (!element!.event!.isRecurring!) {
        if (dateToString(element.event!.date!) ==
            dateToString(newEvent!.event!.date!)) {
          var event = element.event!;
          if (event.startTime!.hour >= newEvent.event!.startTime!.hour &&
              event.startTime!.hour <= newEvent.event!.endTime!.hour) {
            isOverlap = true;
            overlapEvent = element;
            return [isOverlap, overlapEvent];
          }
          if (event.startTime!.hour <= newEvent.event!.startTime!.hour &&
              event.endTime!.hour >= newEvent.event!.endTime!.hour) {
            isOverlap = true;
            overlapEvent = element;
            return [isOverlap, overlapEvent];
          }
          if (event.endTime!.hour >= newEvent.event!.startTime!.hour &&
              event.endTime!.hour <= newEvent.event!.endTime!.hour) {
            isOverlap = true;
            overlapEvent = element;
          }
        }
      }
    }

    return [isOverlap, overlapEvent];
  }

  dynamic createEventFormValidation() {
    var eventData = EventService().eventNotificationModel!;
    if (eventData.group!.members == null ||
        // ignore: prefer_is_empty
        eventData.group!.members!.length < 1) {
      return 'Add contacts';
      // ignore: prefer_is_empty
    } else if (eventData.title == null || eventData.title!.trim().length < 1) {
      return 'Add title';
    } else if (eventData.venue == null ||
        eventData.venue!.label == null ||
        eventData.venue!.latitude == null ||
        eventData.venue!.longitude == null) {
      return 'Add venue';
    } else if (eventData.event!.isRecurring == null) {
      return 'Select Timings';
    } else if (eventData.event!.isRecurring == false &&
        checForOneDayEventFormValidation(eventData) is String) {
      return checForOneDayEventFormValidation(eventData);
    } else if (eventData.event!.isRecurring == true &&
        checForRecurringeDayEventFormValidation(eventData) is String) {
      return checForRecurringeDayEventFormValidation(eventData);
    } else {
      return true;
    }
  }

  dynamic checForOneDayEventFormValidation(EventNotificationModel eventData) {
    if (eventData.event!.date == null) {
      return 'add event date';
    }
    if (eventData.event!.endDate == null) {
      return 'add event date';
    }
    if (eventData.event!.startTime == null) {
      return 'add event start time';
    }
    if (eventData.event!.endTime == null) {
      return 'add event end time';
    }
    if (!isEventUpdate) {
      if (eventData.event!.startTime!.difference(DateTime.now()).inMinutes <
          0) {
        return 'Start Time cannot be in past';
      }
    }

    if (eventData.event!.endTime!.difference(DateTime.now()).inMinutes < 0) {
      return 'End Time cannot be in past';
    }

    if (eventData.event!.endTime!
            .difference(eventData.event!.startTime!)
            .inMinutes <
        0) {
      return 'Start time cannot be after End time';
    }

    if (eventData.event!.endTime == eventData.event!.startTime) {
      return 'Start time and End time cannot be same';
    }
    return true;
  }

  dynamic checForRecurringeDayEventFormValidation(
      EventNotificationModel eventData) {
    if (eventData.event!.repeatDuration == null) {
      return 'add repeat cycle';
    }
    if (eventData.event!.repeatCycle == null) {
      return 'add repeat cycle category';
    } else if (eventData.event!.repeatCycle == RepeatCycle.WEEK &&
        eventData.event!.occursOn == null) {
      return 'select event day';
    } else if (eventData.event!.repeatCycle == RepeatCycle.MONTH &&
        eventData.event!.date == null) {
      return 'select event date';
    } else if (eventData.event!.startTime == null) {
      return 'add event start time';
    } else if (eventData.event!.endTime == null) {
      return 'add event end time';
    } else if (eventData.event!.endsOn == null) {
      return 'add event ending details';
    } else if (eventData.event!.endsOn == EndsOn.ON &&
        eventData.event!.endEventOnDate == null) {
      return 'add end event date';
    } else if (eventData.event!.endsOn == EndsOn.AFTER &&
        eventData.event!.endEventAfterOccurance == null) {
      return 'add event occurance';
    }
  }

  AtKey getAtKey(String regexKey) {
    var atKey = AtKey.fromString(regexKey);
    atKey.metadata!.ttr = -1;
    // atKey.metadata.ttl = MixedConstants.maxTTL; // 7 days
    atKey.metadata!.ccd = true;
    return atKey;
  }

  Future<bool> checkAtsign(String receiver) async {
    // ignore: unnecessary_null_comparison
    if (receiver == null) {
      return false;
    } else if (!receiver.contains('@')) {
      receiver = '@' + receiver;
    }
    var checkPresence = await AtLookupImpl.findSecondary(
        receiver, MixedConstants.ROOT_DOMAIN, 64);
    return checkPresence != null;
  }
}
