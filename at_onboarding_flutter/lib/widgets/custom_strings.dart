import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';

class CustomStrings {
  static final CustomStrings _singleton = CustomStrings._internal();

  CustomStrings._internal();

  factory CustomStrings() {
    return _singleton;
  }
  String get invalidData =>
      'Received content is invalid. Please scan or upload relevant files to pair your atsign';
  String invalidCram(String atsign) =>
      'Click on \"${Strings.saveButtonTitle}"\ for pairing $atsign with the device using backupzip file. Otherwise provide a QRcode downloaded or saved from ${AppConstants.website} website';

  String pairedAtsign(String atsign) =>
      '$atsign was already paired with this device. First delete/reset this @sign from device to add.';

  String atsignMismatch(String givenAtsign, {bool isQr = false}) {
    if (isQr) {
      return '@sign mismatches. Please provide the QRcode of $givenAtsign @sign to pair';
    } else {
      return '@sign mismatches. Please provide the backup key file of $givenAtsign @sign to pair';
    }
  }
}
