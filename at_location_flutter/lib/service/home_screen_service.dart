import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/screens/map_screen/map_screen.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:flutter/material.dart';

import 'at_location_notification_listener.dart';

class HomeScreenService {
  HomeScreenService._();
  static final HomeScreenService _instance = HomeScreenService._();
  factory HomeScreenService() => _instance;

  void onLocationModelTap(LocationNotificationModel locationNotificationModel, bool haveResponded) {
    String? currentAtsign = AtLocationNotificationListener().currentAtSign;

    if (locationNotificationModel.key!.contains(MixedConstants.shareLocation)) {
      locationNotificationModel.atsignCreator != currentAtsign
          // ignore: unnecessary_statements
          ? (locationNotificationModel.isAccepted
              ? navigatorPushToMap(locationNotificationModel)
              : (locationNotificationModel.isExited
                  ? AtLocationNotificationListener()
                      .showMyDialog(locationNotificationModel.atsignCreator, locationNotificationModel)
                  : (haveResponded
                      ? null
                      : AtLocationNotificationListener()
                          .showMyDialog(locationNotificationModel.atsignCreator, locationNotificationModel))))
          : navigatorPushToMap(locationNotificationModel);
    } else if (locationNotificationModel.key!.contains(MixedConstants.requestLocation)) {
      locationNotificationModel.atsignCreator == currentAtsign
          // ignore: unnecessary_statements
          ? (locationNotificationModel.isAccepted
              ? navigatorPushToMap(locationNotificationModel)
              : (locationNotificationModel.isExited
                  ? AtLocationNotificationListener()
                      .showMyDialog(locationNotificationModel.atsignCreator, locationNotificationModel)
                  : (haveResponded
                      ? null
                      : AtLocationNotificationListener()
                          .showMyDialog(locationNotificationModel.atsignCreator, locationNotificationModel))))
          // ignore: unnecessary_statements
          : (locationNotificationModel.isAccepted ? navigatorPushToMap(locationNotificationModel) : null);
    }
  }

  void navigatorPushToMap(LocationNotificationModel locationNotificationModel) {
    Navigator.push(
      AtLocationNotificationListener().navKey.currentContext!,
      MaterialPageRoute<MapScreen>(
          builder: (BuildContext context) => MapScreen(
                currentAtSign: AtLocationNotificationListener().currentAtSign,
                userListenerKeyword: locationNotificationModel,
              )),
    );
  }
}

String getSubTitle(LocationNotificationModel locationNotificationModel) {
  DateTime? to;
  String time;
  to = locationNotificationModel.to;
  if (to != null) {
    time = 'until ${timeOfDayToString(TimeOfDay.fromDateTime(locationNotificationModel.to!))} today';
  } else {
    time = '';
  }
  if (locationNotificationModel.key!.contains(MixedConstants.shareLocation)) {
    return locationNotificationModel.atsignCreator == AtLocationNotificationListener().currentAtSign
        ? 'Can see my location $time'
        : 'Can see their location $time';
  } else {
    return locationNotificationModel.isAccepted
        ? (locationNotificationModel.atsignCreator == AtLocationNotificationListener().currentAtSign
            ? 'Sharing my location $time'
            : 'Sharing their location $time')
        : (locationNotificationModel.atsignCreator == AtLocationNotificationListener().currentAtSign
            ? 'Request Location received'
            : 'Request Location sent');
  }
}

String? getSemiTitle(LocationNotificationModel locationNotificationModel, bool haveResponded) {
  if (locationNotificationModel.key!.contains(MixedConstants.shareLocation)) {
    return locationNotificationModel.atsignCreator != AtLocationNotificationListener().currentAtSign
        ? (locationNotificationModel.isAccepted
            ? null
            : locationNotificationModel.isExited
                ? 'Received Share location rejected'
                : (haveResponded ? 'Pending request' : 'Action required'))
        : (locationNotificationModel.isAccepted
            ? null
            : locationNotificationModel.isExited
                ? 'Sent Share location rejected'
                : 'Awaiting response');
  } else {
    return locationNotificationModel.atsignCreator == AtLocationNotificationListener().currentAtSign
        ? (!locationNotificationModel.isExited
            ? (locationNotificationModel.isAccepted ? null : (haveResponded ? 'Pending request' : 'Action required'))
            : 'Request rejected')
        : (!locationNotificationModel.isExited
            ? (locationNotificationModel.isAccepted ? null : 'Awaiting response')
            : 'Request rejected');
  }
}

String? getTitle(LocationNotificationModel locationNotificationModel) {
  if (locationNotificationModel.key!.contains(MixedConstants.shareLocation)) {
    return locationNotificationModel.atsignCreator == AtLocationNotificationListener().currentAtSign
        ? locationNotificationModel.receiver
        : locationNotificationModel.atsignCreator;
  } else {
    return locationNotificationModel.atsignCreator == AtLocationNotificationListener().currentAtSign
        ? locationNotificationModel.receiver
        : locationNotificationModel.atsignCreator;
  }
}

bool calculateShowRetry(KeyLocationModel keyLocationModel) {
  if (keyLocationModel.locationNotificationModel!.key!.contains('sharelocation')) {
    if ((keyLocationModel.locationNotificationModel!.atsignCreator != AtLocationNotificationListener().currentAtSign) &&
        (!keyLocationModel.locationNotificationModel!.isAccepted) &&
        (!keyLocationModel.locationNotificationModel!.isExited) &&
        (keyLocationModel.haveResponded!)) return true;

    return false;
  } else {
    if ((keyLocationModel.locationNotificationModel!.atsignCreator == AtLocationNotificationListener().currentAtSign) &&
        (!keyLocationModel.locationNotificationModel!.isAccepted) &&
        (!keyLocationModel.locationNotificationModel!.isExited) &&
        (keyLocationModel.haveResponded!)) return true;

    return false;
  }
}

String timeOfDayToString(TimeOfDay time) {
  int minute = time.minute;
  if (minute < 10) return '${time.hour}: 0${time.minute}';

  return '${time.hour}: ${time.minute}';
}
