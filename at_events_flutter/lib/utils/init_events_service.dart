import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:flutter/cupertino.dart';

void initialiseEventService(AtClientImpl atClientInstance,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  EventService().initializeAtContactImpl(atClientInstance, rootDomain);
}

Future<bool> createEvent(EventNotificationModel eventData) async {
  if (eventData == null) {
    throw Exception('Event cannot be null');
  }
  if (eventData.atsignCreator == null ||
      eventData.atsignCreator.trim().isEmpty) {
    throw Exception('Event creator cannot be empty');
  }

  if (eventData.group.members.isEmpty) {
    throw Exception('No members found');
  }

  eventData.key = 'createevent-${DateTime.now().microsecondsSinceEpoch}';

  try {
    var atKey = AtKey()
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
    var atKey = EventService().getAtKey(regexKey);
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
  print('eventData to delete:$eventData');

  if (eventData.atsignCreator != currentAtsign) {
    throw Exception('Only creator can delete the event');
  }

  try {
    var atKey = EventService().getAtKey(regexKey);
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
    var atkey = EventService().getAtKey(regexKey);
    var atvalue =
        await EventService().atClientInstance.get(atkey).catchError((e) {
      print('error in get ${e.errorCode} ${e.errorMessage}');
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
  var regexList = await EventService().atClientInstance.getKeys(
        regex: 'createevent-',
      );

  if (regexList.isEmpty) {
    EventService().allEvents = allEvents;
    EventService().eventListSink.add(allEvents);
    return [];
  }

  try {
    for (var i = 0; i < regexList.length; i++) {
      var atkey = EventService().getAtKey(regexList[i]);
      var atValue = await EventService().atClientInstance.get(atkey);
      print('event atvalue: ${atValue}');
      if (atValue.value != null) {
        var event = EventNotificationModel.fromJson(jsonDecode(atValue.value));
        print('event : ${event.title}');
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
    return null;
  }
}

Future<List<String>> getRegexKeys() async {
  var regexList = await EventService().atClientInstance.getKeys(
        regex: 'createevent-',
      );

  return regexList ?? [];
}

Future<EventNotificationModel> getValue(String key) async {
  try {
    EventNotificationModel event;
    var atKey = EventService().getAtKey(key);
    var atValue = await EventService().atClientInstance.get(atKey);
    if (atValue.value != null) {
      event = EventNotificationModel.fromJson(jsonDecode(atValue.value));
    }

    return event;
  } catch (e) {
    print('$e');
    return null;
  }
}

Future<String> getRegexKeyFromKey(String key) async {
  String regexKey;
  var allRegex = await getRegexKeys();
  var index = allRegex.indexWhere((element) => element.contains(key));
  if (index > -1) {
    regexKey = allRegex[index];
    return regexKey;
  } else {
    return null;
  }
}
