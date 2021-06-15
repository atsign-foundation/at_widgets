import 'package:at_commons/at_commons.dart';

import 'location_notification.dart';

/// Model containing the [atKey], [atValue], [locationNotificationModel] associated with the [key].
class KeyLocationModel {
  String key;
  AtKey atKey;
  AtValue atValue;
  LocationNotificationModel locationNotificationModel;
  KeyLocationModel(
      {this.key, this.atKey, this.atValue, this.locationNotificationModel});
}
