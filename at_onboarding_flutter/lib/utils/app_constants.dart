import 'package:at_client_mobile/at_client_mobile.dart';

class AppConstants {
  static String _rootDomain = 'root.atsign.org';
  static String website;
  static String package = 'at_onboarding_flutter';
  static String encryptKeys = '_encrypt_keys';
  static String backupFileExtension = '.atKeys';
  static String backupZipExtension = '_atKeys.zip';
  static int responseTimeLimit = 30;
  static String contactAddress = 'support@atsign.com';

  static get serverDomain => _rootDomain;

  static set rootDomain(String domain) {
    _rootDomain = domain ?? 'root.atsign.org';
    website =
        _rootDomain == 'root.atsign.org' ? 'www.atsign.com' : 'www.atsign.wtf';
  }
}

extension customMessages on OnboardingStatus {
  String get message {
    switch (this) {
      case (OnboardingStatus.ACTIVATE):
        return 'Your atsign got reactivated. Please activate with the new QRCode available on ${AppConstants.serverDomain} website.';
        break;
      case (OnboardingStatus.ENCRYPTION_PRIVATE_KEY_NOT_FOUND):
      case (OnboardingStatus.ENCRYPTION_PUBLIC_KEY_NOT_FOUND):
      case (OnboardingStatus.PKAM_PRIVATE_KEY_NOT_FOUND):
      case (OnboardingStatus.PKAM_PUBLIC_KEY_NOT_FOUND):
        return 'Fatal error occurred. Please contact support@atsign.com';
        break;
      case (OnboardingStatus.RESTORE):
        return 'Please restore it with the available backup zip file as the local keys were missing.';
        break;
      default:
        return '';
        break;
    }
  }
}
