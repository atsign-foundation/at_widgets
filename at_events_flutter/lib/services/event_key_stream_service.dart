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
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_events_flutter/utils/constants.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

import 'contact_service.dart';

class EventKeyStreamService {
  EventKeyStreamService._();
  static final EventKeyStreamService _instance = EventKeyStreamService._();
  factory EventKeyStreamService() => _instance;

  AtClientImpl? atClientInstance;
  AtContactsImpl? atContactImpl;
  AtContact? loggedInUserDetails;
  List<EventKeyLocationModel> allEventNotifications = <EventKeyLocationModel>[],
      allPastEventNotifications = <EventKeyLocationModel>[];
  String? currentAtSign;
  List<AtContact> contactList = <AtContact>[];

  StreamController<List<EventKeyLocationModel>> atNotificationsController =
      StreamController<List<EventKeyLocationModel>>.broadcast();
  Stream<List<EventKeyLocationModel>> get atNotificationsStream => atNotificationsController.stream;
  StreamSink<List<EventKeyLocationModel>> get atNotificationsSink => atNotificationsController.sink;

  Function(List<EventKeyLocationModel>)? streamAlternative;
  Future<void> dispose() async {
    await atNotificationsController.close();
  }

  Future<void> init(AtClientImpl clientInstance, {Function(List<EventKeyLocationModel>)? streamAlternative}) async {
    loggedInUserDetails = null;
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance!.currentAtSign;
    allEventNotifications = <EventKeyLocationModel>[];
    allPastEventNotifications = <EventKeyLocationModel>[];
    this.streamAlternative = streamAlternative;

    atNotificationsController = StreamController<List<EventKeyLocationModel>>.broadcast();
    await getAllEventNotifications();

    loggedInUserDetails = await getAtSignDetails(currentAtSign);
    await getAllContactDetails(currentAtSign!);
  }

  Future<void> getAllContactDetails(String currentAtSign) async {
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
    contactList = await atContactImpl!.listContacts();
  }

  /// adds all 'createevent' notifications to [atNotificationsSink]
  Future<void> getAllEventNotifications() async {
    await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);

    List<String> response = await atClientInstance!.getKeys(
      regex: 'createevent-',
    );

    if (response.isEmpty) {
      EventLocationShare().init();
      notifyListeners();
      return;
    }

    for (String key in response) {
      EventKeyLocationModel eventKeyLocationModel = EventKeyLocationModel(key: key);
      allEventNotifications.add(eventKeyLocationModel);
    }

    for (EventKeyLocationModel notification in allEventNotifications) {
      AtKey atKey = EventService().getAtKey(notification.key!);
      notification.atKey = atKey;
    }

    // TODO
    // filterBlockedContactsforEvents();

    for (int i = 0; i < allEventNotifications.length; i++) {
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
    List<EventKeyLocationModel> tempRemoveEventArray = <EventKeyLocationModel>[];

    for (int i = 0; i < allEventNotifications.length; i++) {
      try {
        // ignore: unrelated_type_equality_checks
        if (allEventNotifications[i].atValue != 'null' && allEventNotifications[i].atValue != null) {
          EventNotificationModel event =
              EventNotificationModel.fromJson(jsonDecode(allEventNotifications[i].atValue!.value));

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

    allEventNotifications.removeWhere((EventKeyLocationModel element) => tempRemoveEventArray.contains(element));
  }

  /// Removes past notifications and notification where data is null.
  void filterPastEventsFromList() {
    for (int i = 0; i < allEventNotifications.length; i++) {
      if (allEventNotifications[i].eventNotificationModel!.event!.endTime!.difference(DateTime.now()).inMinutes < 0) {
        allPastEventNotifications.add(allEventNotifications[i]);
      }
    }

    allEventNotifications.removeWhere((EventKeyLocationModel element) => allPastEventNotifications.contains(element));
  }

  /// Updates any received notification with [haveResponded] true, if already responded.
  Future<void> checkForPendingEvents() async {
    for (EventKeyLocationModel notification in allEventNotifications) {
      for (AtContact member in notification.eventNotificationModel!.group!.members!) {
        if ((member.atSign == currentAtSign) &&
            (member.tags!['isAccepted'] == false) &&
            (member.tags!['isExited'] == false)) {
          String atkeyMicrosecondId = notification.key!.split('createevent-')[1].split('@')[0];
          String acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';
          List<String> allRegexResponses = await atClientInstance!.getKeys(regex: acknowledgedKeyId);
          if ((allRegexResponses.isNotEmpty) && (allRegexResponses.isNotEmpty)) {
            notification.haveResponded = true;
          }
        }
      }
    }
  }

  /// Checks for any missed notifications and updates respective notification
  Future<void> updateEventDataAccordingToAcknowledgedData() async {
    // var allEventKey = await atClientInstance.getKeys(
    //   regex: 'createevent-',
    // );

    // if (allEventKey.isEmpty) {
    //   return;
    // }

    List<String> allRegexResponses = <String>[], allEventUserLocationResponses = <String>[];
    for (int i = 0; i < allEventNotifications.length; i++) {
      allRegexResponses.clear();
      allEventUserLocationResponses.clear();
      List<EventUserLocation> eventUserLocation = <EventUserLocation>[];
      String atkeyMicrosecondId = allEventNotifications[i].key!.split('createevent-')[1].split('@')[0];

      /// For location update
      String updateEventLocationKeyId = 'updateeventlocation-$atkeyMicrosecondId';

      allEventUserLocationResponses = await atClientInstance!.getKeys(regex: updateEventLocationKeyId);

      if (allEventUserLocationResponses.isNotEmpty) {
        for (int j = 0; j < allEventUserLocationResponses.length; j++) {
          if (allEventUserLocationResponses[j].isNotEmpty && !allEventNotifications[i].key!.contains('cached')) {
            EventUserLocation? eventData = await geteventData(allEventUserLocationResponses[j]);

            if (eventData != null) {
              eventUserLocation.add(eventData);
            }
          }
        }
      }

      ///

      String acknowledgedKeyId = 'eventacknowledged-$atkeyMicrosecondId';
      allRegexResponses = await atClientInstance!.getKeys(regex: acknowledgedKeyId);

      if (allRegexResponses.isNotEmpty) {
        for (int j = 0; j < allRegexResponses.length; j++) {
          if (allRegexResponses[j].isNotEmpty && !allEventNotifications[i].key!.contains('cached')) {
            AtKey acknowledgedAtKey = EventService().getAtKey(allRegexResponses[j]);
            AtKey createEventAtKey = EventService().getAtKey(allEventNotifications[i].key!);

            AtValue result = await atClientInstance!.get(acknowledgedAtKey).catchError((dynamic e) {
              print('error in get $e');
            });

            // ignore: unnecessary_null_comparison
            if ((result == null) || (result.value == null)) {
              continue;
            }

            EventNotificationModel acknowledgedEvent = EventNotificationModel.fromJson(jsonDecode(result.value));
            EventNotificationModel? storedEvent = EventNotificationModel();

            storedEvent = allEventNotifications[i].eventNotificationModel;

            /// Update acknowledgedEvent location with updated latlng

            for (AtContact member in acknowledgedEvent.group!.members!) {
              int indexWhere = eventUserLocation.indexWhere((EventUserLocation e) => e.atsign == member.atSign);

              if (acknowledgedAtKey.sharedBy![0] != '@') {
                acknowledgedAtKey.sharedBy = '@' + acknowledgedAtKey.sharedBy!;
              }

              if (indexWhere > -1 && eventUserLocation[indexWhere].atsign == acknowledgedAtKey.sharedBy) {
                member.tags!['lat'] = eventUserLocation[indexWhere].latLng.latitude;
                member.tags!['long'] = eventUserLocation[indexWhere].latLng.longitude;
              }
            }

            ///

            if (!compareEvents(storedEvent!, acknowledgedEvent)) {
              storedEvent.isUpdate = true;

              for (AtContact groupMember in storedEvent.group!.members!) {
                for (AtContact element in acknowledgedEvent.group!.members!) {
                  if (groupMember.atSign!.toLowerCase() == element.atSign!.toLowerCase() &&
                      groupMember.atSign!.contains(acknowledgedAtKey.sharedBy!)) {
                    groupMember.tags = element.tags;
                  }
                }
              }

              List<String?> allAtsignList = <String?>[];
              for (AtContact element in storedEvent.group!.members!) {
                allAtsignList.add(element.atSign);
              }

              /// To let other puts complete
              // await Future.delayed(Duration(seconds: 5));
              bool updateResult = await updateEvent(storedEvent, createEventAtKey);

              createEventAtKey.sharedWith = jsonEncode(allAtsignList);

              await SyncSecondary().callSyncSecondary(SyncOperation.notifyAll,
                  atKey: createEventAtKey,
                  notification: EventNotificationModel.convertEventNotificationToJson(storedEvent),
                  operation: OperationEnum.update,
                  isDedicated: MixedConstants.isDedicated);

              if (updateResult is bool && updateResult == true) {
                mapUpdatedEventDataToWidget(storedEvent);
              }
            }
            // }
            // }
          }
        }
      }
    }
  }

  /// Adds new [EventKeyLocationModel] data for new received notification
  Future<EventKeyLocationModel?> addDataToList(EventNotificationModel eventNotificationModel) async {
    String newLocationDataKeyId;
    String? key;
    newLocationDataKeyId = eventNotificationModel.key!.split('createevent-')[1].split('@')[0];

    List<String> keys = <String>[];
    keys = await atClientInstance!.getKeys(
      regex: 'createevent-',
    );

    for (String regex in keys) {
      if (regex.contains(newLocationDataKeyId)) {
        key = regex;
      }
    }

    print('key $key');

    if (key == null) {
      return null;
    }

    EventKeyLocationModel tempEventKeyLocationModel = EventKeyLocationModel(key: key);
    // eventNotificationModel.key = key;
    tempEventKeyLocationModel.atKey = EventService().getAtKey(key);
    tempEventKeyLocationModel.atValue = await getAtValue(tempEventKeyLocationModel.atKey!);
    tempEventKeyLocationModel.eventNotificationModel = eventNotificationModel;
    allEventNotifications.add(tempEventKeyLocationModel);

    notifyListeners();

    // if ((tempHyridNotificationModel.locationNotificationModel!.isSharing)) {
    //   if (tempHyridNotificationModel.locationNotificationModel!.atsignCreator ==
    //       currentAtSign) {
    //     // ignore: unawaited_futures
    //     SendLocationNotification()
    //         .addMember(tempHyridNotificationModel.locationNotificationModel);
    //   }
    // }
    checkLocationSharingForEventData(tempEventKeyLocationModel.eventNotificationModel!);

    return tempEventKeyLocationModel;
  }

  /// Updates any [EventKeyLocationModel] data for updated data
  void mapUpdatedEventDataToWidget(EventNotificationModel eventData,
      {Map<dynamic, dynamic>? tags, String? tagOfAtsign, bool updateLatLng = false, bool updateOnlyCreator = false}) {
    String neweventDataKeyId;
    neweventDataKeyId = eventData.key!.split('${MixedConstants.createEvent}-')[1].split('@')[0];

    for (int i = 0; i < allEventNotifications.length; i++) {
      if (allEventNotifications[i].key!.contains(neweventDataKeyId)) {
        /// if we want to update everything
        // allEventNotifications[i].eventNotificationModel = eventData;

        /// For events send tags of group members if we have and update only them
        if (updateOnlyCreator) {
          /// So that creator doesnt update group details
          eventData.group = allEventNotifications[i].eventNotificationModel!.group;
        }

        if ((tags != null) && (tagOfAtsign != null)) {
          for (AtContact element in allEventNotifications[i]
              .eventNotificationModel!
              .group!
              .members!
              .where((AtContact element) => element.atSign == tagOfAtsign)) {
            if (updateLatLng) {
              element.tags!['lat'] = tags['lat'];
              element.tags!['long'] = tags['long'];
            } else {
              element.tags = tags;
            }
          }
        } else {
          allEventNotifications[i].eventNotificationModel = eventData;
        }

        allEventNotifications[i].eventNotificationModel!.key = allEventNotifications[i].key;

        // LocationService().updateEventWithNewData(
        //     allHybridNotifications[i].eventNotificationModel);

        checkLocationSharingForEventData(allEventNotifications[i].eventNotificationModel!);
      }
    }
    notifyListeners();

    // if ((eventData.isSharing) && (eventData.isAccepted)) {
    //   if (eventData.atsignCreator == currentAtSign) {
    //     SendLocationNotification().addMember(eventData);
    //   }
    // } else {
    //   SendLocationNotification().removeMember(eventData.key);
    // }
  }

  /// Checks current status of [currentAtSign] in an event and updates [EventLocationShare] location sending list.
  void checkLocationSharingForEventData(EventNotificationModel eventNotificationModel) {
    if ((eventNotificationModel.atsignCreator == currentAtSign)) {
      if (eventNotificationModel.isSharing!) {
        // ignore: unawaited_futures
        EventLocationShare().addMember(eventNotificationModel);
      } else {
        EventLocationShare().removeMember(eventNotificationModel.key);
      }
    } else {
      AtContact? currentGroupMember;
      for (int i = 0; i < eventNotificationModel.group!.members!.length; i++) {
        if (eventNotificationModel.group!.members!.elementAt(i).atSign == currentAtSign) {
          currentGroupMember = eventNotificationModel.group!.members!.elementAt(i);
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

  Future<bool> updateEvent(EventNotificationModel eventData, AtKey key) async {
    try {
      String notification = EventNotificationModel.convertEventNotificationToJson(eventData);

      bool result = await atClientInstance!.put(key, notification, isDedicated: MixedConstants.isDedicated);
      if (result is bool) {
        if (result) {
          if (MixedConstants.isDedicated) {
            await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
          }
        }
        print('event acknowledged:$result');
      }
      return result;
    } catch (e) {
      print('error in updating notification:$e');
      return false;
    }
  }

  /// Processes any kind of update in an event and notifies creator/members
  Future<bool> actionOnEvent(EventNotificationModel event, ATKEY_TYPE_ENUM keyType,
      {bool? isAccepted, bool? isSharing, bool? isExited, bool? isCancelled}) async {
    EventNotificationModel eventData =
        EventNotificationModel.fromJson(jsonDecode(EventNotificationModel.convertEventNotificationToJson(event)));

    try {
      String atkeyMicrosecondId = eventData.key!.split('createevent-')[1].split('@')[0];

      String currentAtsign = AtEventNotificationListener().atClientInstance!.currentAtSign!;

      eventData.isUpdate = true;
      if (eventData.atsignCreator!.toLowerCase() == currentAtsign.toLowerCase()) {
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
        for (AtContact member in eventData.group!.members!) {
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
        }
      }

      AtKey key = formAtKey(keyType, atkeyMicrosecondId, eventData.atsignCreator, currentAtsign, event)!;

      // TODO : Check whther key is correct
      print('key $key');

      String notification = EventNotificationModel.convertEventNotificationToJson(eventData);
      bool result = await atClientInstance!.put(key, notification, isDedicated: MixedConstants.isDedicated);

      if (MixedConstants.isDedicated) {
        await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
      }
      // if key type is createevent, we have to notify all members
      if (keyType == ATKEY_TYPE_ENUM.CREATEEVENT) {
        mapUpdatedEventDataToWidget(eventData);

        List<String?> allAtsignList = <String?>[];
        for (AtContact element in eventData.group!.members!) {
          allAtsignList.add(element.atSign);
        }

        key.sharedWith = jsonEncode(allAtsignList);
        await SyncSecondary().callSyncSecondary(
          SyncOperation.notifyAll,
          atKey: key,
          notification: notification,
          operation: OperationEnum.update,
          isDedicated: MixedConstants.isDedicated,
        );
      } else {
        ///  update pending status if receiver, add more if checks like already responded
        if (result) {
          updatePendingStatus(eventData);
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
  Future<void> updateLocationData(EventMemberLocation locationData, String? atKey, String? fromAtSign) async {
    try {
      String eventId = locationData.key!.split('-')[1].split('@')[0];

      EventNotificationModel? presentEventData;

      for (int i = 0; i < allEventNotifications.length; i++) {
        if (allEventNotifications[i].key!.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(jsonDecode(
              EventNotificationModel.convertEventNotificationToJson(allEventNotifications[i].eventNotificationModel!)));
          // print(
          //     'presentEventData ${EventNotificationModel.convertEventNotificationToJson(presentEventData)}');
          break;
        }
      }

      if (presentEventData == null) {
        return;
      }

      for (int i = 0; i < presentEventData.group!.members!.length; i++) {
        AtContact presentGroupMember = presentEventData.group!.members!.elementAt(i);
        if (presentGroupMember.atSign![0] != '@') {
          presentGroupMember.atSign = '@' + presentGroupMember.atSign!;
        }

        if (fromAtSign![0] != '@') fromAtSign = '@' + fromAtSign;

        if (presentGroupMember.atSign!.toLowerCase() == fromAtSign.toLowerCase()) {
          presentGroupMember.tags!['lat'] = locationData.lat;
          presentGroupMember.tags!['long'] = locationData.long;

          break;
        }

        // print('presentGroupMember ${presentGroupMember.tags}');
      }

      presentEventData.isUpdate = true;

      List<String?> allAtsignList = <String?>[];

      for (AtContact element in presentEventData.group!.members!) {
        allAtsignList.add(element.atSign);
      }

      String notification = EventNotificationModel.convertEventNotificationToJson(presentEventData);

      AtKey key = EventService().getAtKey(presentEventData.key!);

      bool result = await atClientInstance!.put(key, notification, isDedicated: MixedConstants.isDedicated);

      key.sharedWith = jsonEncode(allAtsignList);

      await SyncSecondary().callSyncSecondary(
        SyncOperation.notifyAll,
        atKey: key,
        notification: notification,
        operation: OperationEnum.update,
        isDedicated: MixedConstants.isDedicated,
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
  Future<void> createEventAcknowledge(EventNotificationModel acknowledgedEvent, String? atKey, String? fromAtSign) async {
    try {
      String eventId = acknowledgedEvent.key!.split('createevent-')[1].split('@')[0];

      if ((atClientInstance!.preference != null) && (atClientInstance!.preference!.namespace != null)) {
        eventId = eventId.replaceAll('.${atClientInstance!.preference!.namespace!}', '');
      }

      late EventNotificationModel presentEventData;
      for(EventKeyLocationModel element in allEventNotifications) {
        if (element.key!.contains('createevent-$eventId')) {
          presentEventData = EventNotificationModel.fromJson(
              jsonDecode(EventNotificationModel.convertEventNotificationToJson(element.eventNotificationModel!)));
        }
      }

      /// Old approach
      List<String> response = await atClientInstance!.getKeys(
        regex: 'createevent-$eventId',
      );

      AtKey key = EventService().getAtKey(response[0]);

      /// New approach

      // var key = EventService().getAtKey(presentEventData.key);

      Map<dynamic, dynamic>? tags;

      for(AtContact presentGroupMember in presentEventData.group!.members!) {
        for(AtContact acknowledgedGroupMember in acknowledgedEvent.group!.members!) {
          if (acknowledgedGroupMember.atSign![0] != '@') {
            acknowledgedGroupMember.atSign = '@' + acknowledgedGroupMember.atSign!;
          }

          if (presentGroupMember.atSign![0] != '@') {
            presentGroupMember.atSign = '@' + presentGroupMember.atSign!;
          }

          if (fromAtSign![0] != '@') fromAtSign = '@' + fromAtSign;

          // print(
          //     'acknowledgedGroupMember.atSign ${acknowledgedGroupMember.atSign}, presentGroupMember.atSign ${presentGroupMember.atSign}, fromAtSign $fromAtSign');

          if (acknowledgedGroupMember.atSign!.toLowerCase() == presentGroupMember.atSign!.toLowerCase() &&
              acknowledgedGroupMember.atSign!.toLowerCase() == fromAtSign.toLowerCase()) {
            // print(
            //     'acknowledgedGroupMember.tags ${acknowledgedGroupMember.tags}');
            presentGroupMember.tags = acknowledgedGroupMember.tags;
            tags = presentGroupMember.tags;
          }
        }
        // print('presentGroupMember.tags ${presentGroupMember.tags}');
      }

      presentEventData.isUpdate = true;
      List<String?> allAtsignList = <String?>[];
      for(AtContact element in presentEventData.group!.members!) {
        allAtsignList.add(element.atSign);
      }

      String notification = EventNotificationModel.convertEventNotificationToJson(presentEventData);

      // print('notification $notification');

      bool result = await atClientInstance!.put(key, notification, isDedicated: MixedConstants.isDedicated);

      key.sharedWith = jsonEncode(allAtsignList);

      await SyncSecondary().callSyncSecondary(
        SyncOperation.notifyAll,
        atKey: key,
        notification: notification,
        operation: OperationEnum.update,
        isDedicated: MixedConstants.isDedicated,
      );

      /// Dont sync as notifyAll is called

      if (result is bool && result) {
        //   mapUpdatedDataToWidget(
        //       convertEventToHybrid(NotificationType.Event,
        //           eventNotificationModel: presentEventData),
        //       tags: tags,
        //       tagOfAtsign: fromAtSign);

        mapUpdatedEventDataToWidget(presentEventData, tags: tags, tagOfAtsign: fromAtSign);
        // print('acknowledgement for $fromAtSign completed');
      }
    } catch (e) {
      print('error in event acknowledgement: $e');
    }
  }

  void updatePendingStatus(EventNotificationModel notificationModel) {
    for (int i = 0; i < allEventNotifications.length; i++) {
      if (allEventNotifications[i].eventNotificationModel!.key == notificationModel.key) {
        allEventNotifications[i].haveResponded = true;
      }
    }
  }

  // ignore: missing_return
  AtKey? formAtKey(ATKEY_TYPE_ENUM keyType, String atkeyMicrosecondId, String? sharedWith, String sharedBy,
      EventNotificationModel eventData) {
    switch (keyType) {
      case ATKEY_TYPE_ENUM.CREATEEVENT:
        AtKey? atKey;

        for (EventKeyLocationModel event in allEventNotifications) {
          if (event.eventNotificationModel!.key == eventData.key) {
            atKey = EventService().getAtKey(event.key!);
          }
        }
        return atKey;

      case ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT:
        AtKey key = AtKey()
          ..metadata = Metadata()
          ..metadata!.ttr = -1
          ..metadata!.ccd = true
          ..sharedWith = sharedWith
          ..sharedBy = sharedBy;

        key.key = 'eventacknowledged-$atkeyMicrosecondId';
        return key;
    }
  }

  Future<EventUserLocation?> geteventData(String regex) async {
    AtKey acknowledgedAtKey = EventService().getAtKey(regex);

    AtValue? result = await atClientInstance!.get(acknowledgedAtKey).catchError((dynamic e) {
      print('error in get $e');
    });

    if ((result.toString() == 'null') || (result.value == null)) {
      return null;
    }

    EventMemberLocation eventData = EventMemberLocation.fromJson(jsonDecode(result.value));
    EventUserLocation obj = EventUserLocation(eventData.fromAtSign, eventData.getLatLng);

    return obj;
  }

  bool compareEvents(EventNotificationModel eventOne, EventNotificationModel eventTwo) {
    bool isDataSame = true;

    for (AtContact groupOneMember in eventOne.group!.members!) {
      for (AtContact groupTwoMember in eventTwo.group!.members!) {
        if (groupOneMember.atSign == groupTwoMember.atSign) {
          if (groupOneMember.tags!['isAccepted'] != groupTwoMember.tags!['isAccepted'] ||
              groupOneMember.tags!['isSharing'] != groupTwoMember.tags!['isSharing'] ||
              groupOneMember.tags!['isExited'] != groupTwoMember.tags!['isExited'] ||
              groupOneMember.tags!['lat'] != groupTwoMember.tags!['lat'] ||
              groupOneMember.tags!['long'] != groupTwoMember.tags!['long']) {
            isDataSame = false;
          }
        }
      }
    }

    return isDataSame;
  }

  Future<AtValue?> getAtValue(AtKey key) async {
    try {
      AtValue atvalue = await atClientInstance!
          .get(key)
          // ignore: return_of_invalid_type_from_catch_error
          .catchError((dynamic e) => print('error in in key_stream_service get $e'));

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
    // allEventNotifications.forEach((element) {
    //   print(
    //       'element.atKey: ${element.atKey}, ${element.atValue}, , ${element.key}, ');
    //   print('element.key: ${element.key}, ');
    //   print('element.atValue: ${element.atValue}');
    //   print(
    //       'element.eventNotificationModel: ${element.eventNotificationModel}');
    // });
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
