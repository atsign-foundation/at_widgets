import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:flutter/cupertino.dart';

initialiseEventService(AtClientImpl atClientInstance,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  EventService().initializeAtContactImpl(atClientInstance, rootDomain);
}

Future<bool> createEvent(EventNotificationModel eventData) async {
  if (eventData == null) {
    throw Exception('Event cannot be null');
  }
  if (eventData.atsignCreator == null ||
      eventData.atsignCreator.trim().length == 0) {
    throw Exception('Event creator cannot be empty');
  }

  if (eventData.group.members.length < 1) {
    throw Exception('No members found');
  }

  eventData.key = "createevent-${DateTime.now().microsecondsSinceEpoch}";

  try {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..key = eventData.key
      ..sharedWith = eventData.group.members.elementAt(0).atSign
      ..sharedBy = eventData.atsignCreator;
    var eventJson =
        EventNotificationModel.convertEventNotificationToJson(eventData);
    var result = await EventService().atClientInstance.put(atKey, eventJson);
    return result;
  } catch (e) {
    print('error in creating event:$e');
    return false;
  }
}

Future<bool> updateEvent(EventNotificationModel eventData, String key) async {
  String regexKey;
  EventNotificationModel currentEventData;
  regexKey = await getRegexKeyFromKey(key);
  if (regexKey == null) {
    throw Exception('Event key not found');
  }
  currentEventData = await getValue(regexKey);
  eventData.atsignCreator = currentEventData.atsignCreator;

  try {
    AtKey atKey = EventService().getAtKey(regexKey);
    var eventJson =
        EventNotificationModel.convertEventNotificationToJson(eventData);
    var result = await EventService().atClientInstance.put(atKey, eventJson);
    return result;
  } catch (e) {
    print('error in creating event:$e');
    return false;
  }
}

Future<bool> deleteEvent(String key) async {
  String regexKey, currentAtsign;
  EventNotificationModel eventData;
  currentAtsign = EventService().atClientInstance.currentAtSign;
  regexKey = await getRegexKeyFromKey(key);
  if (regexKey == null) {
    throw Exception('Event key not found');
  }
  eventData = await getValue(regexKey);
  print('eventData to delete:${eventData}');

  if (eventData.atsignCreator != currentAtsign)
    throw Exception('Only creator can delete the event');

  try {
    AtKey atKey = EventService().getAtKey(regexKey);
    var result = await EventService().atClientInstance.delete(atKey);
    if (result != null && result) {
      EventService().allEvents.removeWhere((element) => element.key == key);
      EventService().eventListSink.add(EventService().allEvents);
    }
    return result;
  } catch (e) {
    return false;
  }
}

Future<EventNotificationModel> getEventDetails(String key) async {
  EventNotificationModel eventData;
  String regexKey;
  regexKey = await getRegexKeyFromKey(key);
  if (regexKey == null) {
    throw Exception('Event key not found');
  }
  try {
    AtKey atkey = EventService().getAtKey(regexKey);
    AtValue atvalue =
        await EventService().atClientInstance.get(atkey).catchError((e) {
      print("error in get ${e.errorCode} ${e.errorMessage}");
      return null;
    });
    eventData = EventNotificationModel.fromJson(jsonDecode(atvalue.value));
    return eventData;
  } catch (e) {
    return null;
  }
}

Future<List<EventNotificationModel>> getEvents() async {
  List<EventNotificationModel> allEvents = [];
  List<String> regexList = await EventService().atClientInstance.getKeys(
        regex: 'createevent-',
      );

  if (regexList.length == 0) {
    EventService().allEvents = allEvents;
    EventService().eventListSink.add(allEvents);
    return [];
  }

  try {
    for (int i = 0; i < regexList.length; i++) {
      AtKey atkey = EventService().getAtKey(regexList[i]);
      AtValue atValue = await EventService().atClientInstance.get(atkey);
      if (atValue.value != null) {
        EventNotificationModel event =
            EventNotificationModel.fromJson(jsonDecode(atValue.value));
        allEvents.add(event);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      EventService().allEvents = allEvents;
      EventService().eventListSink.add(allEvents);
    });
    return allEvents;
  } catch (e) {
    print(e);
  }
}

Future<List<String>> getRegexKeys() async {
  List<String> regexList = await EventService().atClientInstance.getKeys(
        regex: 'createevent-',
      );

  return regexList ?? [];
}

Future<EventNotificationModel> getValue(String key) async {
  try {
    EventNotificationModel event;
    AtKey atKey = EventService().getAtKey(key);
    AtValue atValue = await EventService().atClientInstance.get(atKey);
    if (atValue.value != null)
      event = EventNotificationModel.fromJson(jsonDecode(atValue.value));

    return event;
  } catch (e) {
    print('$e');
    return null;
  }
}

Future<String> getRegexKeyFromKey(String key) async {
  String regexKey;
  List<String> allRegex = await getRegexKeys();
  int index = allRegex.indexWhere((element) => element.contains(key));
  if (index > -1) {
    regexKey = allRegex[index];
    return regexKey;
  } else {
    return null;
  }
}
