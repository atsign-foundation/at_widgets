import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Function to initialise the package. Should be mandatorily called before accessing package functionalities.
///
/// [mapKey] is needed to access maps.
///
/// [apiKey] is needed to calculate ETA.
///
/// Steps to get [mapKey]/[apiKey] available in README.
///
/// [showDialogBox] if false dialog box wont be shown.
///
/// [streamAlternative] a function which will return updated lists of [KeyLocationModel]
void initializeLocationService(AtClient atClientImpl, String currentAtSign,
    GlobalKey<NavigatorState> navKey,
    {required String mapKey,
    required String apiKey,
    bool showDialogBox = false,
    String rootDomain = MixedConstants.ROOT_DOMAIN,
    Function? getAtValue,
    Function(List<KeyLocationModel>)? streamAlternative}) async {
  /// initialise keys
  MixedConstants.setApiKey(apiKey);
  MixedConstants.setMapKey(mapKey);

  try {
    /// So that we have the permission status beforehand & later we dont get
    /// PlatformException(PermissionHandler.PermissionManager) => Multiple Permissions exception
    await Geolocator.requestPermission();
  } catch (e) {
    print('Error in initializeLocationService $e');
  }

  AtLocationNotificationListener().init(
      atClientImpl, currentAtSign, navKey, rootDomain, showDialogBox,
      newGetAtValueFromMainApp: getAtValue);
  KeyStreamService().init(AtLocationNotificationListener().atClientInstance,
      streamAlternative: streamAlternative);
}

/// returns a Stream of 'KeyLocationModel' having all the shared and request location keys.
Stream getAllNotification() {
  return KeyStreamService().atNotificationsStream;
}

/// sends a share location notification to the [atsign], with a 'ttl' of [minutes].
/// before calling this [atsign] should be checked if valid or not.
Future<bool?> sendShareLocationNotification(String atsign, int? minutes) async {
  var result = await SharingLocationService()
      .sendShareLocationEvent(atsign, false, minutes: minutes);
  return result;
}

/// sends a request location notification to the [atsign].
/// before calling this [atsign] should be checked if valid or not.
Future<bool?> sendRequestLocationNotification(String atsign) async {
  var result = await RequestLocationService().sendRequestLocationEvent(atsign);
  return result;
}

/// deletes the location notification of the logged in atsign being shared with [locationNotificationModel].receiver
Future<bool> deleteLocationData(
    LocationNotificationModel locationNotificationModel) async {
  var result =
      await SendLocationNotification().sendNull(locationNotificationModel);
  return result;
}

/// deletes all the location notifications of the logged in atsign being shared with any atsign
void deleteAllLocationData() {
  SendLocationNotification().deleteAllLocationKey();
}

/// returns the 'AtKey' of the [regexKey]
AtKey getAtKey(String regexKey) {
  var atKey = AtKey.fromString(regexKey);
  atKey.metadata!.ttr = -1;
  return atKey;
}
