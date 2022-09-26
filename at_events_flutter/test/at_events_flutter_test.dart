import 'package:at_client/at_client.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAtClient extends Mock implements AtClient {
  @override
  Future<bool> put(AtKey key, dynamic value, {bool isDedicated = false}) async {
    return true;
  }

  @override
  Future<bool> delete(AtKey key, {bool isDedicated = false}) async {
    return true;
  }

  @override
  Future<List<String>> getKeys(
      {String? regex,
      String? sharedBy,
      String? sharedWith,
      bool showHiddenKeys = false}) async {
    return ["@83apedistinct", "@45expected"];
  }

  @override
  String? getCurrentAtSign() {
    return "@83apedistinct";
  }
}

class MockAtClientManager with Mock implements AtClientManager {
  @override
  AtClient get atClient => MockAtClient();
}

void main() {
  EventNotificationModel model = EventNotificationModel();
  AtGroup group = AtGroup("group");
  Venue venue = Venue();
  venue.latitude = 20.8;
  venue.longitude = 20.8;
  venue.label = "label";
  Event event = Event();
  event.isRecurring = false;
  event.date = DateTime.parse("2024-02-27");
  event.endDate = DateTime.parse("2024-03-27");
  event.startTime = DateTime.parse("2024-02-27");
  event.endTime = DateTime.parse("2024-03-27");
  event.repeatDuration = 1;
  event.repeatCycle = RepeatCycle.MONTH;
  event.endsOn = EndsOn.ON;
  event.endEventOnDate = DateTime.parse("2024-03-27");
  event.endEventAfterOccurance = 1;
  group.members = {AtContact(atSign: "@83apedistinct")};
  model.group = group;
  model.key = "xyz-@83apedistinct-createevent-@45expected";
  model.venue = venue;
  model.event = event;
  model.title = "title";

  const channel = MethodChannel('at_events_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test("create_event", () async {
    EventService().eventNotificationModel = model;
    EventService().isEventUpdate = true;
    EventService().atClientManager = MockAtClientManager();

    var res = await EventService().createEvent();
    expect(res, true);
  });

  test("edit_event", () async {
    EventService().eventNotificationModel = model;
    EventService().atClientManager = MockAtClientManager();

    var res = await EventService().editEvent();
    expect(res, true);
  });

  test("add_new_group_members", () async {
    EventService().eventNotificationModel = model;

    await EventService()
        .addNewGroupMembers([AtContact(atSign: "@83apedistinct")]);
    expect(EventService().selectedContactsAtSigns.length, 1);
  });

  test("add_new_contact_and_group_members", () async {
    EventService().eventNotificationModel = model;

    GroupContactsModel groupContactsModel = GroupContactsModel().copyWith(
      contact: AtContact(atSign: "@83apedistinct"),
      group: group,
      contactType: ContactsType.CONTACT,
    );

    await EventService().addNewContactAndGroupMembers([groupContactsModel]);
    expect(EventService().selectedContactsAtSigns.length, 1);
  });

  test("add_contacts_to_list", () async {
    EventService().eventNotificationModel = model;

    EventService().addContactToList(AtContact(atSign: "@83apedistinct"));
    expect(EventService().selectedContactsAtSigns.length, 1);
  });

  test("create_contact_list_from_group_memebers", () async {
    EventService().eventNotificationModel = model;

    EventService().createContactListFromGroupMembers();
    expect(EventService().selectedContactsAtSigns.length, 1);
  });

  test("get_group_member_contact", () async {
    EventService().eventNotificationModel = model;

    var res = EventService()
        .getGroupMemberContact(AtContact(atSign: "@83apedistinct"));
    expect(res, isA<AtContact>());
  });

  test("is_event_time_slot_overlap", () async {
    EventService().eventNotificationModel = model;

    var res = EventService().isEventTimeSlotOverlap([model], model);
    expect(res[0], true);
  });

  test("create_event_form_validation", () async {
    EventService().eventNotificationModel = model;

    var res = EventService().createEventFormValidation();
    expect(res, true);
  });

  test("check_for_one_day_event_form_validation", () async {
    EventService().eventNotificationModel = model;

    var res = EventService().checForOneDayEventFormValidation(model);
    expect(res, true);
  });

  test("check_for_recurring_day_event_form_validation", () async {
    EventService().eventNotificationModel = model;

    var res = EventService().checForRecurringeDayEventFormValidation(model);
    expect(res, null);
  });

  test("remove_selected_contact", () async {
    EventService().eventNotificationModel = model;

    EventService().selectedContacts = [AtContact(atSign: "@83apedistinct")];
    EventService().selectedContactsAtSigns = ["@83apedistinct"];

    EventService().removeSelectedContact(0);
    expect(EventService().selectedContactsAtSigns.length, 0);
  });
}
