import 'dart:convert';

import 'package:at_events_flutter/services/event_services.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';
import 'package:latlong/latlong.dart';

class EventNotificationModel {
  EventNotificationModel();
  String atsignCreator;
  bool isCancelled;
  String title;
  Venue venue;
  Event event;
  String key;
  AtGroup group;
  bool isSharing;
  bool isUpdate; //when an event data is being updated , this should be true
  EventNotificationModel.fromJson(Map<String, dynamic> data) {
    title = data['title'] ?? '';
    key = data['key'] ?? '';
    atsignCreator = data['atsignCreator'] ?? '';
    isCancelled = data['isCancelled'] == 'true' ? true : false;
    isSharing = data['isSharing'] == 'true' ? true : false;
    isUpdate = data['isUpdate'] == 'true' ? true : false;
    if (data['venue'] != null) {
      venue = Venue.fromJson(jsonDecode(data['venue']));
    }
    if (data['event'] != null) {
      event = data['event'] != null
          ? Event.fromJson(jsonDecode(data['event']))
          : null;
    }

    if (data['group'] != null) {
      data['group'] = jsonDecode(data['group']);
      group = new AtGroup(data['group']['name']);

      data['group']['members'].forEach((contact) {
        AtContact newContact = AtContact(atSign: contact['atSign']);
        newContact.tags = {};
        newContact.tags['isAccepted'] = contact['tags']['isAccepted'];
        newContact.tags['isSharing'] = contact['tags']['isSharing'];
        newContact.tags['isExited'] = contact['tags']['isExited'];
        newContact.tags['shareFrom'] = contact['tags']['shareFrom'] != null &&
                contact['tags']['shareFrom'] != 'null'
            ? contact['tags']['shareFrom']
            : -1;
        newContact.tags['shareTo'] = contact['tags']['shareTo'] != null &&
                contact['tags']['shareTo'] != 'null'
            ? contact['tags']['shareTo']
            : -1;
        newContact.tags['lat'] =
            contact['tags']['lat'] != null && contact['tags']['lat'] != 'null'
                ? contact['tags']['lat']
                : 0;
        newContact.tags['long'] =
            contact['tags']['long'] != null && contact['tags']['long'] != 'null'
                ? contact['tags']['long']
                : 0;
        group.members.add(newContact);
      });
    }
  }

  // toJson(EventNotificationModel eventNotification) {
  //   var value = json.encode({
  //     'title': eventNotification.title.toString(),
  //     'isCancelled': eventNotification.isCancelled.toString(),
  //     'isUpdate': eventNotification.isUpdate.toString(),
  //     'atsignCreator': eventNotification.atsignCreator.toString(),
  //     'key': eventNotification.key,
  //     // 'contactList': json.encode(eventNotification.contactList
  //     //     .map((e) =>
  //     //         LocationNotificationModel.convertLocationNotificationToJson(e))
  //     //     .toList()),
  //     'group': json.encode(eventNotification.group),
  //     'venue': json.encode({
  //       'latitude': eventNotification.venue.latitude.toString(),
  //       'longitude': eventNotification.venue.longitude.toString(),
  //       'label': eventNotification.venue.label
  //     }),
  //     'event': json.encode({
  //       'isRecurring': eventNotification.event.isRecurring.toString(),
  //       'date': eventNotification.event.date.toString(),
  //       'startTime': eventNotification.event.startTime.toString(),
  //       'endTime': eventNotification.event.endTime.toString(),
  //       'repeatDuration': eventNotification.event.repeatDuration.toString(),
  //       'repeatCycle': eventNotification.event.repeatCycle.toString(),
  //       'occursOn': eventNotification.event.occursOn.toString(),
  //       'endsOn': eventNotification.event.endsOn.toString(),
  //       'endEventOnDate': eventNotification.event.endEventOnDate.toString(),
  //       'endEventAfterOccurance':
  //           eventNotification.event.endEventAfterOccurance.toString()
  //     })
  //   });
  //   return value;
  // }

  // getContactList(var element) {
  //   var element2 = jsonDecode(element);
  //   LocationNotificationModel obj = LocationNotificationModel(
  //       atsign: element2['atsign'] != null && element2['atsign'] != 'null'
  //           ? element2['atsign']
  //           : null,
  //       lat: element2['lat'] != null && element2['lat'] != 'null'
  //           ? double.parse(element2['lat'])
  //           : null,
  //       long: element2['long'] != null && element2['long'] != 'null'
  //           ? double.parse(element2['long'])
  //           : null,
  //       isAccepted: element2['isAccepted'] == 'true' ? true : false,
  //       isSharing: element2['isSharing'] == 'true' ? true : false,
  //       isExited: element2['isExited'] == 'true' ? true : false);
  //   return obj;
  // }

  static String convertEventNotificationToJson(
      EventNotificationModel eventNotification) {
    var notification = json.encode({
      'title': eventNotification.title != null
          ? eventNotification.title.toString()
          : '',
      'isCancelled': eventNotification.isCancelled.toString(),
      'isSharing': eventNotification.isSharing.toString(),
      'isUpdate': eventNotification.isUpdate.toString(),
      'atsignCreator': eventNotification.atsignCreator.toString(),
      'key': '${eventNotification.key}',
      'group': json.encode(eventNotification.group),
      'venue': json.encode({
        'latitude': eventNotification.venue.latitude.toString(),
        'longitude': eventNotification.venue.longitude.toString(),
        'label': eventNotification.venue.label
      }),
      'event': json.encode({
        'isRecurring': eventNotification.event.isRecurring.toString(),
        'date': eventNotification.event.date.toString(),
        'startTime': eventNotification.event.startTime.toString(),
        'endTime': eventNotification.event.endTime.toString(),
        'repeatDuration': eventNotification.event.repeatDuration.toString(),
        'repeatCycle': eventNotification.event.repeatCycle.toString(),
        'occursOn': eventNotification.event.occursOn.toString(),
        'endsOn': eventNotification.event.endsOn.toString(),
        'endEventOnDate': eventNotification.event.endEventOnDate.toString(),
        'endEventAfterOccurance':
            eventNotification.event.endEventAfterOccurance.toString()
      })
    });
    return notification;
  }
}

class Venue {
  Venue();
  double latitude, longitude;
  String label;
  Venue.fromJson(Map<String, dynamic> data)
      : latitude =
            data['latitude'] != 'null' ? double.parse(data['latitude']) : 0,
        longitude =
            data['longitude'] != 'null' ? double.parse(data['longitude']) : 0,
        label = data['label'] != 'null' ? data['label'] : '';
}

class Event {
  Event();
  bool isRecurring;
  DateTime date;
  TimeOfDay startTime, endTime; //one day event
  int repeatDuration;
  RepeatCycle repeatCycle;
  Week occursOn;
  EndsOn endsOn;
  DateTime endEventOnDate;
  int endEventAfterOccurance;
  Event.fromJson(Map<String, dynamic> data) {
    data['startTime'] = data['startTime'] != 'null'
        ? data['startTime'].substring(10, 15)
        : null;
    data['endTime'] =
        data['endTime'] != 'null' ? data['endTime'].substring(10, 15) : null;
    startTime = data['startTime'] != null
        ? TimeOfDay(
            hour: int.parse(data['startTime'].split(":")[0]),
            minute: int.parse(data['startTime'].split(":")[1]))
        : null;
    endTime = data['endTime'] != null
        ? TimeOfDay(
            hour: int.parse(data['endTime'].split(":")[0]),
            minute: int.parse(data['endTime'].split(":")[1]))
        : null;
    isRecurring = data['isRecurring'] == 'true' ? true : false;
    if (!isRecurring) {
      date = data['date'] != 'null' ? DateTime.parse(data['date']) : null;
    } else {
      repeatDuration = data['repeatDuration'] != 'null'
          ? int.parse(data['repeatDuration'])
          : null;
      repeatCycle = (data['repeatCycle'] == RepeatCycle.WEEK.toString()
          ? RepeatCycle.WEEK
          : (data['repeatCycle'] == RepeatCycle.MONTH.toString()
              ? RepeatCycle.MONTH
              : null));
      switch (repeatCycle) {
        case RepeatCycle.WEEK:
          occursOn = (data['occursOn'] == Week.SUNDAY.toString()
              ? Week.SUNDAY
              : (data['occursOn'] == Week.MONDAY.toString()
                  ? Week.MONDAY
                  : (data['occursOn'] == Week.TUESDAY.toString()
                      ? Week.TUESDAY
                      : (data['occursOn'] == Week.WEDNESDAY.toString()
                          ? Week.WEDNESDAY
                          : (data['occursOn'] == Week.THURSDAY.toString()
                              ? Week.THURSDAY
                              : (data['occursOn'] == Week.FRIDAY.toString()
                                  ? Week.FRIDAY
                                  : (data['occursOn'] ==
                                          Week.SATURDAY.toString()
                                      ? Week.SATURDAY
                                      : null)))))));
          break;
        case RepeatCycle.MONTH:
          date = data['date'] != 'null' ? DateTime.parse(data['date']) : null;
          break;
      }
      endsOn = (data['endsOn'] == EndsOn.NEVER.toString()
          ? EndsOn.NEVER
          : (data['endsOn'] == EndsOn.ON.toString()
              ? EndsOn.ON
              : (data['endsOn'] == EndsOn.AFTER.toString()
                  ? EndsOn.AFTER
                  : null)));
      switch (endsOn) {
        case EndsOn.ON:
          endEventOnDate = data['endEventOnDate'] != 'null'
              ? DateTime.parse(data['endEventOnDate'])
              : null;
          break;
        case EndsOn.AFTER:
          endEventAfterOccurance = data['endEventAfterOccurance'] != 'null'
              ? int.parse(data['endEventAfterOccurance'])
              : null;
          break;
        case EndsOn.NEVER:
          // endEventOn = null;
          break;
      }
    }
  }
}

enum RepeatCycle { WEEK, MONTH }
enum Week { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY }
enum EndsOn { NEVER, ON, AFTER }

Week getWeekEnum(String weekday) {
  switch (weekday) {
    case 'Monday':
      return Week.MONDAY;
    case 'Tuesday':
      return Week.TUESDAY;
    case 'Wednesday':
      return Week.WEDNESDAY;
    case 'Thursday':
      return Week.THURSDAY;
    case 'Friday':
      return Week.FRIDAY;
    case 'Saturday':
      return Week.SATURDAY;
    case 'Sunday':
      return Week.SUNDAY;
  }
}

String getWeekString(Week weekday) {
  switch (weekday) {
    case Week.MONDAY:
      return 'Monday';
    case Week.TUESDAY:
      return 'Tuesday';
    case Week.WEDNESDAY:
      return 'Wednesday';
    case Week.THURSDAY:
      return 'Thursday';
    case Week.FRIDAY:
      return 'Friday';
    case Week.SATURDAY:
      return 'Saturday';
    case Week.SUNDAY:
      return 'Sunday';
  }
}

String timeOfDayToString(TimeOfDay time) {
  String hhmm = '${time.hour}:${time.minute}';
  return hhmm;
}

String dateToString(DateTime date) {
  String dateString = '${date.day}/${date.month}/${date.year}';
  return dateString;
}

List<String> get repeatOccuranceOptions => ['Week', 'Month'];
List<String> get occursOnWeekOptions => [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

enum ATKEY_TYPE_ENUM { CREATEEVENT, ACKNOWLEDGEEVENT }

Map<String, dynamic> get monthsList => {
      '1': {'month': 'jan', 'days': 31, 'count': 1},
      '2': {'month': 'feb', 'days': 28, 'count': 2},
      '3': {'month': 'mar', 'days': 31, 'count': 3},
      '4': {'month': 'apr', 'days': 30, 'count': 4},
      '5': {'month': 'may', 'days': 31, 'count': 5},
      '6': {'month': 'jun', 'days': 30, 'count': 6},
      '7': {'month': 'jul', 'days': 31, 'count': 7},
      '8': {'month': 'aug', 'days': 31, 'count': 8},
      '9': {'month': 'sept', 'days': 30, 'count': 9},
      '10': {'month': 'oct', 'days': 31, 'count': 10},
      '11': {'month': 'nov', 'days': 30, 'count': 11},
      '12': {'month': 'dec', 'days': 31, 'count': 12},
    };
