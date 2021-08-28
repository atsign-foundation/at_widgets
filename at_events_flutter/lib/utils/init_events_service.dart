import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:flutter/cupertino.dart';

/// Function to initialise the package. Should be mandatorily called before accessing package functionalities.
///
/// [mapKey] is needed to access maps.
///
/// [apiKey] is needed to calculate ETA.
///
/// Steps to get [mapKey]/[apiKey] available in README.
///
/// [initLocation] pass this as false if location package is initialised outside, so it is not initialised more than once.
///
/// [streamAlternative] a function which will return updated lists of [EventKeyLocationModel]
void initialiseEventService(
    AtClientImpl atClientInstance, GlobalKey<NavigatorState> navKeyFromMainApp,
    {required String mapKey,
    required String apiKey,
    String rootDomain = 'root.atsign.wtf',
    int rootPort = 64,
    dynamic Function(List<EventKeyLocationModel>)? streamAlternative,
    bool initLocation = true}) {
  /// initialise keys
  MixedConstants.setApiKey(apiKey);
  MixedConstants.setMapKey(mapKey);

  if (initLocation) {
    initializeLocationService(
        atClientInstance, atClientInstance.currentAtSign!, navKeyFromMainApp,
        apiKey: MixedConstants.API_KEY!, mapKey: MixedConstants.MAP_KEY!);
  }

  /// To have eta in events
  AtLocationFlutterPlugin(
    <String?>[],
    calculateETA: true,
  );

  AtEventNotificationListener().init(atClientInstance,
      atClientInstance.currentAtSign!, navKeyFromMainApp, rootDomain);

  EventKeyStreamService()
      .init(atClientInstance, streamAlternative: streamAlternative);
}

Future<bool> createEvent(EventNotificationModel eventData) async {
  // ignore: unnecessary_null_comparison
  if (eventData == null) {
    throw Exception('Event cannot be null');
  }
  if (eventData.atsignCreator == null ||
      eventData.atsignCreator!.trim().isEmpty) {
    throw Exception('Event creator cannot be empty');
  }

  if (eventData.group!.members!.isEmpty) {
    throw Exception('No members found');
  }

  eventData.key = 'createevent-${DateTime.now().microsecondsSinceEpoch}';

  try {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = -1
      ..key = eventData.key
      ..sharedWith = eventData.group!.members!.elementAt(0).atSign
      ..sharedBy = eventData.atsignCreator;
    String eventJson =
        EventNotificationModel.convertEventNotificationToJson(eventData);
    bool result = await EventService().atClientInstance!.put(atKey, eventJson);
    return result;
  } catch (e) {
    print('error in creating event:$e');
    return false;
  }
}

// Future<bool> updateEvent(EventNotificationModel eventData, String key) async {
//   String regexKey;
//   EventNotificationModel currentEventData;
//   regexKey = await getRegexKeyFromKey(key);
//   if (regexKey == null) {
//     throw Exception('Event key not found');
//   }
//   currentEventData = await getValue(regexKey);
//   eventData.atsignCreator = currentEventData.atsignCreator;

//   try {
//     var atKey = EventService().getAtKey(regexKey);
//     var eventJson =
//         EventNotificationModel.convertEventNotificationToJson(eventData);
//     var result = await EventService().atClientInstance.put(atKey, eventJson);
//     return result;
//   } catch (e) {
//     print('error in creating event:$e');
//     return false;
//   }
// }

Future<bool> deleteEvent(String key) async {
  String? regexKey, currentAtsign;
  EventNotificationModel? eventData;
  currentAtsign = EventService().atClientInstance!.currentAtSign;
  regexKey = await getRegexKeyFromKey(key);
  if (regexKey == null) {
    throw Exception('Event key not found');
  }
  eventData = await getValue(regexKey);
  print('eventData to delete:$eventData');

  if (eventData!.atsignCreator != currentAtsign) {
    throw Exception('Only creator can delete the event');
  }

  try {
    AtKey atKey = EventService().getAtKey(regexKey);
    bool result = await EventService().atClientInstance!.delete(atKey);
    // ignore: unnecessary_null_comparison
    if (result != null && result) {
      // EventService().allEvents.removeWhere((element) => element.key == key);
      // EventService().eventListSink.add(EventService().allEvents);
    }
    return result;
  } catch (e) {
    return false;
  }
}

Future<EventNotificationModel?> getEventDetails(String key) async {
  EventNotificationModel eventData;
  String? regexKey;
  regexKey = await getRegexKeyFromKey(key);
  if (regexKey == null) {
    throw Exception('Event key not found');
  }
  try {
    AtKey atkey = EventService().getAtKey(regexKey);
    AtValue atvalue =
        await EventService().atClientInstance!.get(atkey).catchError((dynamic e) {
      print('error in get ${e.errorCode} ${e.errorMessage}');
      // ignore: invalid_return_type_for_catch_error
      return null;
    });
    eventData = EventNotificationModel.fromJson(jsonDecode(atvalue.value));
    return eventData;
  } catch (e) {
    return null;
  }
}

Future<List<EventNotificationModel>?> getEvents() async {
  List<EventNotificationModel> allEvents = <EventNotificationModel>[];
  List<String> regexList = await EventService().atClientInstance!.getKeys(
        regex: 'createevent-',
      );

  if (regexList.isEmpty) {
    // EventService().allEvents = allEvents;
    // EventService().eventListSink.add(allEvents);
    return <EventNotificationModel>[];
  }

  try {
    for (int i = 0; i < regexList.length; i++) {
      AtKey atkey = EventService().getAtKey(regexList[i]);
      AtValue atValue = await EventService().atClientInstance!.get(atkey);
      if (atValue.value != null) {
        EventNotificationModel event = EventNotificationModel.fromJson(jsonDecode(atValue.value));
        allEvents.add(event);
      }
    }

    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      // EventService().allEvents = allEvents;
      // EventService().eventListSink.add(allEvents);
    });
    return allEvents;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<List<String>> getRegexKeys() async {
  List<String> regexList = await EventService().atClientInstance!.getKeys(
        regex: 'createevent-',
      );

  return regexList;
}

Future<EventNotificationModel?> getValue(String key) async {
  try {
    EventNotificationModel? event;
    AtKey atKey = EventService().getAtKey(key);
    AtValue atValue = await EventService().atClientInstance!.get(atKey);
    if (atValue.value != null) {
      event = EventNotificationModel.fromJson(jsonDecode(atValue.value));
    }

    return event;
  } catch (e) {
    print('$e');
    return null;
  }
}

Future<String?> getRegexKeyFromKey(String key) async {
  String regexKey;
  List<String> allRegex = await getRegexKeys();
  int index = allRegex.indexWhere((String element) => element.contains(key));
  if (index > -1) {
    regexKey = allRegex[index];
    return regexKey;
  } else {
    return null;
  }
}
