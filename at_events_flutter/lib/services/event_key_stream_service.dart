import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_member_location.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/services/event_location_share.dart';
// import 'package:at_events_flutter/services/sync_secondary.dart';
import 'package:at_events_flutter/utils/constants.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

import 'contact_service.dart';

class EventKeyStreamService {
  EventKeyStreamService._();
  static final EventKeyStreamService _instance = EventKeyStreamService._();
  factory EventKeyStreamService() => _instance;

  late AtClientManager atClientManager;
  AtContactsImpl? atContactImpl;
  AtContact? loggedInUserDetails;
  List<EventKeyLocationModel> allEventNotifications = [],
      allPastEventNotifications = [];
  String? currentAtSign;
  List<AtContact> contactList = [];

  // ignore: close_sinks
  StreamController atNotificationsController =
      StreamController<List<EventKeyLocationModel>>.broadcast();
  Stream<List<EventKeyLocationModel>> get atNotificationsStream =>
      atNotificationsController.stream as Stream<List<EventKeyLocationModel>>;
  StreamSink<List<EventKeyLocationModel>> get atNotificationsSink =>
      atNotificationsController.sink as StreamSink<List<EventKeyLocationModel>>;

  Function(List<EventKeyLocationModel>)? streamAlternative;

  void init({Function(List<EventKeyLocationModel>)? streamAlternative}) async {
    loggedInUserDetails = null;
    atClientManager = AtClientManager.getInstance();
    currentAtSign = atClientManager.atClient.getCurrentAtSign();
    allEventNotifications = [];
    allPastEventNotifications = [];
    this.streamAlternative = streamAlternative;

    atNotificationsController =
        StreamController<List<EventKeyLocationModel>>.broadcast();
    getAllEventNotifications();

    loggedInUserDetails = await getAtSignDetails(currentAtSign);
    getAllContactDetails(currentAtSign!);
  }

  void getAllContactDetails(String currentAtSign) async {
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
    contactList = await atContactImpl!.listContacts();
  }

  /// adds all 'createevent' notifications to [atNotificationsSink]
  void getAllEventNotifications() async {
    AtClientManager.getInstance().syncService.sync();

    var response = await atClientManager.atClient.getKeys(
      regex: 'createevent-',
    );

    if (response.isEmpty) {
      EventLocationShare().init();
      notifyListeners();
      return;
    }

    response.forEach((key) {
      var eventKeyLocationModel = EventKeyLocationModel(key: key);
      allEventNotifications.add(eventKeyLocationModel);
    });

    allEventNotifications.forEach((notification) {
      var atKey = EventService().getAtKey(notification.key!);
      notification.atKey = atKey;
    });

    // TODO
    // filterBlockedContactsforEvents();

    for (var i = 0; i < allEventNotifications.length; i++) {
      AtValue? value = await (getAtValue(allEventNotifications[i].atKey!));
      if (value != null) {
        allEventNotifications[i].atValue = value;
      }
    }

    convertJsonToEventModel();
    filterPastEventsFromList();

    await checkForPendingEvents();

    notifyListeners();

    EventLocationShare().init();

    // ignore: unawaited_futures
    updateEventDataAccordingToAcknowledgedData();
  }

  void convertJsonToEventModel() {
    var tempRemoveEventArray = <EventKeyLocationModel>[];

    for (var i = 0; i < allEventNotifications.length; i++) {
      try {
        // ignore: unrelated_type_equality_checks
        if (allEventNotifications[i].atValue != 'null' &&
            allEventNotifications[i].atValue != null) {
          var event = EventNotificationModel.fromJson(
              jsonDecode(allEventNotifications[i].atValue!.value));

          // ignore: unnecessary_null_comparison
          if (event != null && event.group!.members!.isNotEmpty) {
            event.key = allEventNotifications[i].key;

            allEventNotifications[i].eventNotificationModel = event;
          }
        } else {
          tempRemoveEventArray.add(allEventNotifications[i]);
        }
      } catch (e) {
        tempRemoveEventArray.add(allEventNotifications[i]);
      }
    }

    allEventNotifications
        .removeWhere((element) => tempRemoveEventArray.contains(element));
  }

  /// Removes past notifications and notification where data is null.
  void filterPastEventsFromList() {
    for (var i = 0; i < allEventNotifications.length; i++) {
      if (allEventNotifications[i]
              .eventNotificationModel!
              .event!
              .endTime!
              .difference(DateTime.now())
              .inMinutes <
          0) allPastEventNotifications.add(allEventNotifications[i]);
    }

    allEventNotifications
        .removeWhere((element) => allPastEventNotifications.contains(element));
  }

  /// Updates any received notification with [haveResponded] true, if already responded.
  Future<void> checkForPendingEvents() async {
    allEventNotifications.forEach((notification) async {
      notification.eventNotificationModel!.group!.members!
          .forEach((member) async {
        if ((member.atSign == currentAtSign) &&
            (member.tags!['isAccepted'] == false) &&
            (member.tags!['isExited'] == false)) {
          var atkeyMicrosecondId =
              notification.key!.split('createevent-')[1].split('@')[0];
          var acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';
          var allRegexResponses =
              await atClientManager.atClient.getKeys(regex: acknowledgedKeyId);
          // ignore: unnecessary_null_comparison
          if ((allRegexResponses != null) && (allRegexResponses.isNotEmpty)) {
            notification.haveResponded = true;
          }
        }
      });
    });
  }

  /// Checks for any missed notifications and updates respective notification
  Future<void> updateEventDataAccordingToAcknowledgedData() async {
    var allRegexResponses = [], allEventUserLocationResponses = [];
    for (var i = 0; i < allEventNotifications.length; i++) {
      allRegexResponses = [];
      allEventUserLocationResponses = [];
      var eventUserLocation = <EventUserLocation>[];
      var atkeyMicrosecondId =
          allEventNotifications[i].key!.split('createevent-')[1].split('@')[0];

      /// For location update
      var updateEventLocationKeyId = 'updateeventlocation-$atkeyMicrosecondId';

      allEventUserLocationResponses = await atClientManager.atClient
          .getKeys(regex: updateEventLocationKeyId);

      if (allEventUserLocationResponses.isNotEmpty) {
        for (var j = 0; j < allEventUserLocationResponses.length; j++) {
          if (allEventUserLocationResponses[j] != null &&
              !allEventNotifications[i].key!.contains('cached')) {
            var eventData =
                await geteventData(allEventUserLocationResponses[j]);

            if (eventData != null) {
              eventUserLocation.add(eventData);
            }
          }
        }
      }

      ///

      var acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';
      allRegexResponses =
          await atClientManager.atClient.getKeys(regex: acknowledgedKeyId);

      if (allRegexResponses.isNotEmpty) {
        for (var j = 0; j < allRegexResponses.length; j++) {
          if (allRegexResponses[j] != null &&
              !allEventNotifications[i].key!.contains('cached')) {
            var acknowledgedAtKey =
                EventService().getAtKey(allRegexResponses[j]);
            var createEventAtKey =
                EventService().getAtKey(allEventNotifications[i].key!);

            var result = await atClientManager.atClient
                .get(acknowledgedAtKey)
                // ignore: return_of_invalid_type_from_catch_error
                .catchError((e) => print('error in get $e'));

            // ignore: unnecessary_null_comparison
            if ((result == null) || (result.value == null)) {
              continue;
            }

            var acknowledgedEvent =
                EventNotificationModel.fromJson(jsonDecode(result.value));
            EventNotificationModel? storedEvent = EventNotificationModel();

            storedEvent = allEventNotifications[i].eventNotificationModel;

            /// Update acknowledgedEvent location with updated latlng

            acknowledgedEvent.group!.members!.forEach((member) {
              var indexWhere = eventUserLocation
                  .indexWhere((e) => e.atsign == member.atSign);

              if (acknowledgedAtKey.sharedBy![0] != '@') {
                acknowledgedAtKey.sharedBy = '@' + acknowledgedAtKey.sharedBy!;
              }

              if (indexWhere > -1 &&
                  eventUserLocation[indexWhere].atsign ==
                      acknowledgedAtKey.sharedBy) {
                member.tags!['lat'] =
                    eventUserLocation[indexWhere].latLng.latitude;
                member.tags!['long'] =
                    eventUserLocation[indexWhere].latLng.longitude;
              }
            });

            ///

            if (!compareEvents(storedEvent!, acknowledgedEvent)) {
              storedEvent.isUpdate = true;

              storedEvent.group!.members!.forEach((groupMember) {
                acknowledgedEvent.group!.members!.forEach((element) {
                  if (groupMember.atSign!.toLowerCase() ==
                          element.atSign!.toLowerCase() &&
                      groupMember.atSign!
                          .contains(acknowledgedAtKey.sharedBy!)) {
                    groupMember.tags = element.tags;
                  }
                });
              });

              var allAtsignList = <String?>[];
              storedEvent.group!.members!.forEach((element) {
                allAtsignList.add(element.atSign);
              });

              /// To let other puts complete
              // await Future.delayed(Duration(seconds: 5));
              var updateResult =
                  await updateEvent(storedEvent, createEventAtKey);

              createEventAtKey.sharedWith = jsonEncode(allAtsignList);

              await atClientManager.atClient.notifyAll(
                createEventAtKey,
                EventNotificationModel.convertEventNotificationToJson(
                    storedEvent),
                OperationEnum.update,
              );

              if (updateResult is bool && updateResult == true) {
                mapUpdatedEventDataToWidget(storedEvent);
              }
            }
          }
        }
      }
    }
  }

  /// Adds new [EventKeyLocationModel] data for new received notification
  Future<dynamic> addDataToList(EventNotificationModel eventNotificationModel,
      {String? receivedkey}) async {
    /// with rSDK we can get previous notification, this will restrict us to add one notification twice
    for (var _eventNotification in allEventNotifications) {
      if (_eventNotification.eventNotificationModel!.key ==
          eventNotificationModel.key) {
        return;
      }
    }

    String newLocationDataKeyId;
    String? key;
    newLocationDataKeyId =
        eventNotificationModel.key!.split('createevent-')[1].split('@')[0];

    if (receivedkey != null) {
      key = receivedkey;
    } else {
      var keys = <String>[];
      keys = await atClientManager.atClient.getKeys(
        regex: 'createevent-',
      );

      keys.forEach((regex) {
        if (regex.contains('$newLocationDataKeyId')) {
          key = regex;
        }
      });

      print('key $key');

      if (key == null) {
        return;
      }
    }

    var tempEventKeyLocationModel = EventKeyLocationModel(key: key);
    // eventNotificationModel.key = key;
    tempEventKeyLocationModel.atKey = EventService().getAtKey(key!);
    tempEventKeyLocationModel.atValue =
        await getAtValue(tempEventKeyLocationModel.atKey!);
    tempEventKeyLocationModel.eventNotificationModel = eventNotificationModel;
    allEventNotifications.add(tempEventKeyLocationModel);

    notifyListeners();

    checkLocationSharingForEventData(
        tempEventKeyLocationModel.eventNotificationModel!);

    return tempEventKeyLocationModel;
  }

  /// Updates any [EventKeyLocationModel] data for updated data
  void mapUpdatedEventDataToWidget(EventNotificationModel eventData,
      {Map<dynamic, dynamic>? tags,
      String? tagOfAtsign,
      bool updateLatLng = false,
      bool updateOnlyCreator = false}) {
    String neweventDataKeyId;
    neweventDataKeyId = eventData.key!
        .split('${MixedConstants.CREATE_EVENT}-')[1]
        .split('@')[0];

    for (var i = 0; i < allEventNotifications.length; i++) {
      if (allEventNotifications[i].key!.contains(neweventDataKeyId)) {
        /// if we want to update everything
        // allEventNotifications[i].eventNotificationModel = eventData;

        /// For events send tags of group members if we have and update only them
        if (updateOnlyCreator) {
          /// So that creator doesnt update group details
          eventData.group =
              allEventNotifications[i].eventNotificationModel!.group;
        }

        if ((tags != null) && (tagOfAtsign != null)) {
          allEventNotifications[i]
              .eventNotificationModel!
              .group!
              .members!
              .where((element) => element.atSign == tagOfAtsign)
              .forEach((element) {
            if (updateLatLng) {
              element.tags!['lat'] = tags['lat'];
              element.tags!['long'] = tags['long'];
            } else {
              element.tags = tags;
            }
          });
        } else {
          allEventNotifications[i].eventNotificationModel = eventData;
        }

        allEventNotifications[i].eventNotificationModel!.key =
            allEventNotifications[i].key;

        // LocationService().updateEventWithNewData(
        //     allHybridNotifications[i].eventNotificationModel);

        checkLocationSharingForEventData(
            allEventNotifications[i].eventNotificationModel!);
      }
    }
    notifyListeners();
  }

  /// Checks current status of [currentAtSign] in an event and updates [EventLocationShare] location sending list.
  void checkLocationSharingForEventData(
      EventNotificationModel eventNotificationModel) {
    if ((eventNotificationModel.atsignCreator == currentAtSign)) {
      if (eventNotificationModel.isSharing!) {
        // ignore: unawaited_futures
        EventLocationShare().addMember(eventNotificationModel);
      } else {
        EventLocationShare().removeMember(eventNotificationModel.key);
      }
    } else {
      AtContact? currentGroupMember;
      for (var i = 0; i < eventNotificationModel.group!.members!.length; i++) {
        if (eventNotificationModel.group!.members!.elementAt(i).atSign ==
            currentAtSign) {
          currentGroupMember =
              eventNotificationModel.group!.members!.elementAt(i);
          break;
        }
      }

      if (currentGroupMember != null &&
          currentGroupMember.tags!['isAccepted'] == true &&
          currentGroupMember.tags!['isSharing'] == true &&
          currentGroupMember.tags!['isExited'] == false) {
        // ignore: unawaited_futures
        EventLocationShare().addMember(eventNotificationModel);
      } else {
        EventLocationShare().removeMember(eventNotificationModel.key);
      }
    }
  }

  Future<dynamic> updateEvent(
      EventNotificationModel eventData, AtKey key) async {
    try {
      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);

      var result = await atClientManager.atClient.put(
        key,
        notification,
      );
      if (result is bool) {
        if (result) {}
        print('event acknowledged:$result');
        return result;
        // ignore: unnecessary_null_comparison
      } else if (result != null) {
        return result.toString();
      } else {
        return result;
      }
    } catch (e) {
      print('error in updating notification:$e');
      return false;
    }
  }

  /// Processes any kind of update in an event and notifies creator/members
  Future<bool> actionOnEvent(
      EventNotificationModel event, ATKEY_TYPE_ENUM keyType,
      {bool? isAccepted,
      bool? isSharing,
      bool? isExited,
      bool? isCancelled}) async {
    var eventData = EventNotificationModel.fromJson(jsonDecode(
        EventNotificationModel.convertEventNotificationToJson(event)));

    try {
      var atkeyMicrosecondId =
          eventData.key!.split('createevent-')[1].split('@')[0];

      var currentAtsign = AtEventNotificationListener()
          .atClientManager
          .atClient
          .getCurrentAtSign()!;

      eventData.isUpdate = true;
      if (eventData.atsignCreator!.toLowerCase() ==
          currentAtsign.toLowerCase()) {
        eventData.isSharing =
            // ignore: prefer_if_null_operators
            isSharing != null ? isSharing : eventData.isSharing;
        if (isSharing == false) {
          eventData.lat = null;
          eventData.long = null;
        }

        if (isCancelled == true) {
          eventData.isCancelled = true;
        }
      } else {
        eventData.group!.members!.forEach((member) {
          if (member.atSign![0] != '@') member.atSign = '@' + member.atSign!;
          if (currentAtsign[0] != '@') currentAtsign = '@' + currentAtsign;
          if (member.atSign!.toLowerCase() == currentAtsign.toLowerCase()) {
            member.tags!['isAccepted'] =
                // ignore: prefer_if_null_operators
                isAccepted != null ? isAccepted : member.tags!['isAccepted'];
            member.tags!['isSharing'] =
                // ignore: prefer_if_null_operators
                isSharing != null ? isSharing : member.tags!['isSharing'];
            member.tags!['isExited'] =
                // ignore: prefer_if_null_operators
                isExited != null ? isExited : member.tags!['isExited'];

            if (isSharing == false || isExited == true) {
              member.tags!['lat'] = null;
              member.tags!['long'] = null;
            }

            if (isExited == true) {
              member.tags!['isAccepted'] = false;
              member.tags!['isSharing'] = false;
            }
          }
        });
      }

      var key = formAtKey(keyType, atkeyMicrosecondId, eventData.atsignCreator,
          currentAtsign, event)!;

      print('key $key');

      var notification =
          EventNotificationModel.convertEventNotificationToJson(eventData);
      var result = await atClientManager.atClient.put(
        key,
        notification,
      );

      // if key type is createevent, we have to notify all members
      if (keyType == ATKEY_TYPE_ENUM.CREATEEVENT) {
        mapUpdatedEventDataToWidget(eventData);

        var allAtsignList = <String?>[];
        eventData.group!.members!.forEach((element) {
          allAtsignList.add(element.atSign);
        });

        key.sharedWith = jsonEncode(allAtsignList);

        await atClientManager.atClient.notifyAll(
          key,
          notification,
          OperationEnum.update,
        );
      } else {
        ///  update pending status if receiver, add more if checks like already responded
        if (result) {
          updatePendingStatus(eventData);
        } else {
          print('Ack failed');
        }
        notifyListeners();
      }

      return result;
    } catch (e) {
      print('error in updating event $e');
      return false;
    }
  }

  /// Updates event data with received [locationData] of [fromAtSign]
  void updateLocationData(
      EventMemberLocation locationData, String? fromAtSign) async {
    try {
      var eventId = locationData.key!.split('-')[1].split('@')[0];

      EventNotificationModel? presentEventData;

      for (var i = 0; i < allEventNotifications.length; i++) {
        if (allEventNotifications[i].key!.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(jsonDecode(
              EventNotificationModel.convertEventNotificationToJson(
                  allEventNotifications[i].eventNotificationModel!)));
          break;
        }
      }

      if (presentEventData == null) {
        return;
      }

      for (var i = 0; i < presentEventData.group!.members!.length; i++) {
        var presentGroupMember = presentEventData.group!.members!.elementAt(i);
        if (presentGroupMember.atSign![0] != '@') {
          presentGroupMember.atSign = '@' + presentGroupMember.atSign!;
        }

        if (fromAtSign![0] != '@') fromAtSign = '@' + fromAtSign;

        if (presentGroupMember.atSign!.toLowerCase() ==
            fromAtSign.toLowerCase()) {
          presentGroupMember.tags!['lat'] = locationData.lat;
          presentGroupMember.tags!['long'] = locationData.long;

          break;
        }
      }

      presentEventData.isUpdate = true;

      var allAtsignList = <String?>[];
      presentEventData.group!.members!.forEach((element) {
        allAtsignList.add(element.atSign);
      });

      var notification = EventNotificationModel.convertEventNotificationToJson(
          presentEventData);

      var key = EventService().getAtKey(presentEventData.key!);

      var result = await atClientManager.atClient.put(
        key,
        notification,
      );

      key.sharedWith = jsonEncode(allAtsignList);

      await atClientManager.atClient.notifyAll(
        key,
        notification,
        OperationEnum.update,
      );

      /// Dont sync as notifyAll is called

      if (result is bool && result) {
        mapUpdatedEventDataToWidget(presentEventData);
      }
    } catch (e) {
      print('error in event acknowledgement: $e');
    }
  }

  /// Updates data of members of an event
  // ignore: always_declare_return_types
  createEventAcknowledge(
      EventNotificationModel acknowledgedEvent, String? fromAtSign) async {
    try {
      var eventId =
          acknowledgedEvent.key!.split('createevent-')[1].split('@')[0];

      if ((atClientManager.atClient.getPreferences() != null) &&
          (atClientManager.atClient.getPreferences()!.namespace != null)) {
        eventId = eventId.replaceAll(
            '.${atClientManager.atClient.getPreferences()!.namespace!}', '');
      }

      late EventNotificationModel presentEventData;
      allEventNotifications.forEach((element) {
        if (element.key!.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(jsonDecode(
              EventNotificationModel.convertEventNotificationToJson(
                  element.eventNotificationModel!)));
        }
      });

      /// Old approach
      var response = await atClientManager.atClient.getKeys(
        regex: 'createevent-$eventId',
      );

      var key = EventService().getAtKey(response[0]);

      /// New approach

      // var key = EventService().getAtKey(presentEventData.key);

      Map<dynamic, dynamic>? tags;

      presentEventData.group!.members!.forEach((presentGroupMember) {
        acknowledgedEvent.group!.members!.forEach((acknowledgedGroupMember) {
          if (acknowledgedGroupMember.atSign![0] != '@') {
            acknowledgedGroupMember.atSign =
                '@' + acknowledgedGroupMember.atSign!;
          }

          if (presentGroupMember.atSign![0] != '@') {
            presentGroupMember.atSign = '@' + presentGroupMember.atSign!;
          }

          if (fromAtSign![0] != '@') fromAtSign = '@' + fromAtSign!;

          if (acknowledgedGroupMember.atSign!.toLowerCase() ==
                  presentGroupMember.atSign!.toLowerCase() &&
              acknowledgedGroupMember.atSign!.toLowerCase() ==
                  fromAtSign!.toLowerCase()) {
            presentGroupMember.tags = acknowledgedGroupMember.tags;
            tags = presentGroupMember.tags;
          }
        });
      });

      presentEventData.isUpdate = true;
      var allAtsignList = <String?>[];
      presentEventData.group!.members!.forEach((element) {
        allAtsignList.add(element.atSign);
      });

      var notification = EventNotificationModel.convertEventNotificationToJson(
          presentEventData);

      var result = await atClientManager.atClient.put(
        key,
        notification,
      );

      key.sharedWith = jsonEncode(allAtsignList);

      await atClientManager.atClient.notifyAll(
        key,
        notification,
        OperationEnum.update,
      );

      /// Dont sync as notifyAll is called

      if (result is bool && result) {
        mapUpdatedEventDataToWidget(presentEventData,
            tags: tags, tagOfAtsign: fromAtSign);
      }
    } catch (e) {
      print('error in event acknowledgement: $e');
    }
  }

  void updatePendingStatus(EventNotificationModel notificationModel) async {
    for (var i = 0; i < allEventNotifications.length; i++) {
      if (allEventNotifications[i]
          .eventNotificationModel!
          .key!
          .contains(notificationModel.key!)) {
        print('${notificationModel.key} updated haveResponded');
        allEventNotifications[i].haveResponded = true;
      }
    }
  }

  // ignore: missing_return
  AtKey? formAtKey(ATKEY_TYPE_ENUM keyType, String atkeyMicrosecondId,
      String? sharedWith, String sharedBy, EventNotificationModel eventData) {
    switch (keyType) {
      case ATKEY_TYPE_ENUM.CREATEEVENT:
        AtKey? atKey;

        allEventNotifications.forEach((event) {
          if (event.eventNotificationModel!.key == eventData.key) {
            atKey = EventService().getAtKey(event.key!);
          }
        });
        return atKey;

      case ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT:
        var key = AtKey()
          ..metadata = Metadata()
          ..metadata!.ttr = -1
          ..metadata!.ccd = true
          ..sharedWith = sharedWith
          ..sharedBy = sharedBy;

        key.key = 'eventacknowledged-$atkeyMicrosecondId';
        return key;
    }
  }

  Future<dynamic> geteventData(String regex) async {
    var acknowledgedAtKey = EventService().getAtKey(regex);

    var result = await atClientManager.atClient
        .get(acknowledgedAtKey)
        // ignore: return_of_invalid_type_from_catch_error
        .catchError((e) => print('error in get $e'));

    // ignore: unnecessary_null_comparison
    if ((result == null) || (result.value == null)) {
      return;
    }

    var eventData = EventMemberLocation.fromJson(jsonDecode(result.value));
    var obj = EventUserLocation(eventData.fromAtSign, eventData.getLatLng);

    return obj;
  }

  bool compareEvents(
      EventNotificationModel eventOne, EventNotificationModel eventTwo) {
    var isDataSame = true;

    eventOne.group!.members!.forEach((groupOneMember) {
      eventTwo.group!.members!.forEach((groupTwoMember) {
        if (groupOneMember.atSign == groupTwoMember.atSign) {
          if (groupOneMember.tags!['isAccepted'] !=
                  groupTwoMember.tags!['isAccepted'] ||
              groupOneMember.tags!['isSharing'] !=
                  groupTwoMember.tags!['isSharing'] ||
              groupOneMember.tags!['isExited'] !=
                  groupTwoMember.tags!['isExited'] ||
              groupOneMember.tags!['lat'] != groupTwoMember.tags!['lat'] ||
              groupOneMember.tags!['long'] != groupTwoMember.tags!['long']) {
            isDataSame = false;
          }
        }
      });
    });

    return isDataSame;
  }

  Future<dynamic> getAtValue(AtKey key) async {
    try {
      var atvalue = await atClientManager.atClient
          .get(key)
          // ignore: return_of_invalid_type_from_catch_error
          .catchError((e) => print('error in in key_stream_service get $e'));

      // ignore: unnecessary_null_comparison
      if (atvalue != null) {
        return atvalue;
      } else {
        return null;
      }
    } catch (e) {
      print('error in key_stream_service getAtValue:$e');
      return null;
    }
  }

  void notifyListeners() {
    print('allEventNotifications');
    if (streamAlternative != null) {
      streamAlternative!(allEventNotifications);
    }

    EventsMapScreenData().updateEventdataFromList(allEventNotifications);
    atNotificationsSink.add(allEventNotifications);
  }
}

class EventUserLocation {
  String? atsign;
  LatLng latLng;

  EventUserLocation(this.atsign, this.latLng);
}
