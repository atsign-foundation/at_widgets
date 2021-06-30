import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';

import 'contact_service.dart';

class EventKeyStreamService {
  EventKeyStreamService._();
  static final EventKeyStreamService _instance = EventKeyStreamService._();
  factory EventKeyStreamService() => _instance;

  AtClientImpl atClientInstance;
  AtContactsImpl atContactImpl;
  AtContact loggedInUserDetails;
  List<EventKeyLocationModel> allLocationNotifications = [];
  String currentAtSign;
  List<AtContact> contactList = [];

  // ignore: close_sinks
  StreamController atNotificationsController =
      StreamController<List<EventKeyLocationModel>>.broadcast();
  Stream<List<EventKeyLocationModel>> get atNotificationsStream =>
      atNotificationsController.stream as Stream<List<EventKeyLocationModel>>;
  StreamSink<List<EventKeyLocationModel>> get atNotificationsSink =>
      atNotificationsController.sink as StreamSink<List<EventKeyLocationModel>>;

  Function(List<EventKeyLocationModel>) streamAlternative;

  void init(AtClientImpl clientInstance,
      {Function(List<EventKeyLocationModel>) streamAlternative}) async {
    loggedInUserDetails = null;
    atClientInstance = clientInstance;
    currentAtSign = atClientInstance.currentAtSign;
    allLocationNotifications = [];
    this.streamAlternative = streamAlternative;

    atNotificationsController =
        StreamController<List<EventKeyLocationModel>>.broadcast();
    getAllEventNotifications();

    loggedInUserDetails = await getAtSignDetails(currentAtSign);
    getAllContactDetails(currentAtSign);
  }

  void getAllContactDetails(String currentAtSign) async {
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
    contactList = await atContactImpl.listContacts();
  }

  void getAllEventNotifications() {}
}
