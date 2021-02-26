import 'package:at_commons/at_commons.dart';

import 'location_notification.dart';

class KeyLocationModel {
  String key;
  AtKey atKey;
  AtValue atValue;
  LocationNotificationModel locationNotificationModel;
  KeyLocationModel(
      {this.key, this.atKey, this.atValue, this.locationNotificationModel});
}
