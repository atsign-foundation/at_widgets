import 'package:at_onboarding_flutter/utils/app_constants.dart';

class Strings {
  //atsign texts
  static const String enterAtsignTitle = 'Enter your @sign to pair';
  static const String atsignHintText = 'alice';
  static const String submitButton = 'Submit';

  //atsignStatus texts
  static String atsignNotFound =
      'Your @sign is not registered yet. Try with the registered one or get a new @sign at ${AppConstants.website} website';
  static String atsignNull =
      'Your @sign and the server is unreachable. Please check your dashboard on ${AppConstants.website} website for the @sign status or contact support@atsign.com';
  static const String scanQr = '';

  //Qrscan texts
  static const String scanQrMessage = 'Just scan the QR code displayed at ';
  static const String pairAtsignTitle = 'Pair your @sign';
  static const String uploadQRTitle = 'Upload activation QR code';
  static const String recurr_server_check =
      'Trying to reach server to perform authentication. Click to stop rigorous server check';
  static const String stopButtonTitle = 'stop';
  //backuzip file save texts
  static const String backupKeyDescription =
      'Upload your backup key file from stored location which was generated during the pairing process of your @sign.';
  static const String uploadZipTitle = 'Upload backup key file';
  static const String saveBackupKeyTitle = 'Save your Backup key file';
  static const String saveImportantTitle = 'IMPORTANT!';
  static const String saveBackupDescription =
      'Please save your private key. For security reasons, it\'s highly recommended to save it in GDrive/iCloudDrive.';
  static const String saveButtonTitle = 'SAVE';
  static const String declaration = 'Yes I\'ve saved my backupkey file';
  static const String coninueButtonTitle = 'CONTINUE';

  //custom dialog texts
  static const String errorTitle = 'Error';
  static const String closeTitle = 'Close';
  static const String mailUrlquery = 'subject=Issue from @persona app';
  static const String mailUrlScheme = 'mailto';

  static String backupFileName(String atsign) {
    return atsign + '_encrypt_keys.atKeys';
  }
}
