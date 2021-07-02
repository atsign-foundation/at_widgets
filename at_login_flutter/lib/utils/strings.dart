import 'package:at_server_status/at_server_status.dart';

class Strings {
  // UI Strings
  static const String dashboardTitle = 'Dashboard';
  static const String letsGo = "Let's Go";
  static const String atLogin = 'AtLogin';
  static const String loginAllowed = 'Allow';
  static const String loginDenied = 'Deny';
  static const String atsignNotPaired = ' has not been paired with the device yet. Would you like to add it?';
  static const String atServerNotAvailable = 'The @server is not currently available.';
  static const String badQr = 'Scanning the QR code did not get any data';
  static const String pairAtsign = 'Pair @sign';
  static const String notPairAtsign = 'Cancel Login';
  static const String allowLogin = 'Allow';
  static const String denyLogin = 'Deny';
  static const String backButton = 'Back';
  static const String loginHistory = 'Login History';
  static const String search = 'Filter @signs';
  static const String error = 'Error';
  static const String close = 'Close';
  static const String atsign = '@';
  static const String package = 'at_login_flutter';
  static const String noLoginsAllowed = 'No Login History!';
  static const String noLoginsDenied = 'No Login History!';
  static const String invalidAtsign = 'Invalid Atsign';

  //public content
  static const String publicContentAppbarTitle = 'Public Content';
  static String directoryUrl;
  static String rootdomain;

  static const List<String> publicDataKeys = [
    'firstname.persona',
    'lastname.persona',
    'image.persona'
  ];

  //qrscan texts
  static const String enterAtsignButton = 'Type the @sign';
  static const String enterAtsignTitle = 'Enter the @sign';
  static const String atsignHintText = 'alice';
  static const String qrTitle = 'Login with @sign';
  static const String qrscanDescription = 'Scan the QR code to login.';
  static const String loginRequest = 'Recieved login request';
  static const String submitButton = 'Submit';
  static const String invalidAtsignMessage =
      'Please provide or scan a valid @sign to follow';
  // static const String atsignStatusMessage = 'This @sing is unreachable. P'
  static String getAtSignStatusMessage(AtSignStatus status) {
    status ??= AtSignStatus.error;
    switch (status) {
      case AtSignStatus.unavailable:
      case AtSignStatus.notFound:
        return 'This @sign is not registered yet. Please try with the registered one.';
        break;
      case AtSignStatus.error:
        return 'The @sign server is unreachable. Please try again';
        break;
      default:
        return 'Unknown status. Please try again later.';
        break;
    }
  }

  //error dialog texts
  static const String errorTitle = 'Error';
  static const String closeButton = 'Close';

  //loading texts
  static const String loadingDescription =
      'Please wait while loading your data';
}
