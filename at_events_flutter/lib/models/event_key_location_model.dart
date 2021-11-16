import 'event_notification.dart';

/// Model containing the [eventNotificationModel] & [haveResponded].
class EventKeyLocationModel {
  EventNotificationModel? eventNotificationModel;
  bool haveResponded;
  EventKeyLocationModel(
      {this.eventNotificationModel, this.haveResponded = false});
}
