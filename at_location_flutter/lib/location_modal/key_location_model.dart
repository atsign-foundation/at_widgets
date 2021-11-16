import 'location_notification.dart';

/// Model containing the [atKey], [atValue], [locationNotificationModel], [haveResponded] associated with the [key].
class KeyLocationModel {
  LocationNotificationModel? locationNotificationModel;
  bool? haveResponded;

  KeyLocationModel(
      {this.locationNotificationModel, this.haveResponded = false});
}
