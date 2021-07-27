import 'package:at_commons/at_commons.dart';

import 'event_notification.dart';

/// Model containing the [atKey], [atValue], [eventNotificationModel] associated with the [key].
class EventKeyLocationModel {
  String? key;
  AtKey? atKey;
  AtValue? atValue;
  EventNotificationModel? eventNotificationModel;
  bool haveResponded;
  EventKeyLocationModel(
      {this.key, this.atKey, this.atValue, this.eventNotificationModel, this.haveResponded = false});
}
