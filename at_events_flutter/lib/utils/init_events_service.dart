// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:at_common_flutter/services/size_config.dart';
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
///
/// [initLocation] if true, then location service will be initialised by the events package
/// if it is already initialsed outside this package, then pass [false],
/// make sure to not initialise the location package more than once.
Future<void> initialiseEventService(GlobalKey<NavigatorState> navKeyFromMainApp,
    {required String mapKey,
    required String apiKey,
    rootDomain = 'root.atsign.wtf',
    rootPort = 64,
    dynamic Function(List<EventKeyLocationModel>)? streamAlternative,
    bool initLocation = true}) async {
  /// initialise keys
  MixedConstants.setApiKey(apiKey);
  MixedConstants.setMapKey(mapKey);

  SizeConfig().init(navKeyFromMainApp.currentState!.context);

  if (initLocation) {
    await initializeLocationService(navKeyFromMainApp,
        apiKey: MixedConstants.API_KEY!,
        mapKey: MixedConstants.MAP_KEY!,
        isEventInUse: true);
  }

  /// To have eta in events
  AtLocationFlutterPlugin(
    const [],
    calculateETA: true,
  );

  AtEventNotificationListener().init(navKeyFromMainApp, rootDomain);

  EventKeyStreamService().init(streamAlternative: streamAlternative);
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
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = -1
      ..key = eventData.key
      ..sharedWith = eventData.group!.members!.elementAt(0).atSign
      ..sharedBy = eventData.atsignCreator;
    var eventJson =
        EventNotificationModel.convertEventNotificationToJson(eventData);
    var result =
        await EventService().atClientManager.atClient.put(atKey, eventJson);
    return result;
  } catch (e) {
    print('error in creating event:$e');
    return false;
  }
}

Future<bool> deleteEvent(String key) async {
  String? regexKey, currentAtsign;
  EventNotificationModel? eventData;
  currentAtsign = EventService().atClientManager.atClient.getCurrentAtSign();
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
    var atKey = EventService().getAtKey(regexKey);
    var result = await EventService().atClientManager.atClient.delete(atKey);
    // ignore: unnecessary_null_comparison
    if (result != null && result) {}
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
    var atkey = EventService().getAtKey(regexKey);
    var atvalue = await EventService()
        .atClientManager
        .atClient
        .get(atkey)
        .catchError((e) {
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
  var allEvents = <EventNotificationModel>[];
  var regexList = await EventService().atClientManager.atClient.getKeys(
        regex: 'createevent-',
      );

  if (regexList.isEmpty) {
    return [];
  }

  try {
    for (var i = 0; i < regexList.length; i++) {
      var atkey = EventService().getAtKey(regexList[i]);
      var atValue = await EventService().atClientManager.atClient.get(atkey);
      if (atValue.value != null) {
        var event = EventNotificationModel.fromJson(jsonDecode(atValue.value));
        allEvents.add(event);
      }
    }

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {});
    return allEvents;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<List<String>> getRegexKeys() async {
  var regexList = await EventService().atClientManager.atClient.getKeys(
        regex: 'createevent-',
      );

  return regexList;
}

Future<EventNotificationModel?> getValue(String key) async {
  try {
    EventNotificationModel? event;
    var atKey = EventService().getAtKey(key);
    var atValue = await EventService().atClientManager.atClient.get(atKey);
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
  var allRegex = await getRegexKeys();
  var index = allRegex.indexWhere((element) => element.contains(key));
  if (index > -1) {
    regexKey = allRegex[index];
    return regexKey;
  } else {
    return null;
  }
}
