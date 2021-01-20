import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';

class CustomStrings {
  static final CustomStrings _singleton = CustomStrings._internal();

  CustomStrings._internal();

  factory CustomStrings() {
    return _singleton;
  }
  // String getMessage(String atsign) {
  //   return '$_atsign was already paired with this device. First delete/reset this @sign from device to add.';
  // }
  String get invalidData =>
      'Received content is invalid. Please scan or upload relevant files to pair your atsign';
  String invalidCram(String atsign) =>
      'Click on \"${Strings.saveButtonTitle}"\ for pairing $atsign with the device using backupzip file. Otherwise provide a QRcode downloaded or saved from ${AppConstants.website} website';

  String pairedAtsign(String atsign) =>
      '$atsign was already paired with this device. First delete/reset this @sign from device to add.';
}
