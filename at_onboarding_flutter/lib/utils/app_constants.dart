import 'package:at_client_mobile/at_client_mobile.dart';

class AppConstants {
  static String _rootDomain = 'root.atsign.org';
  static dynamic contentType = 'application/json';
  static String getFreeAtsign = 'get-free-atsign';
  static String authWithAtsign = 'login/atsign';
  static String validationWithAtsign = 'login/atsign/validate';
  static String registerPerson = 'register-person';
  static String validatePerson = 'validate-person';
  static String? website;
  static String apiEndPoint = 'my.atsign.wtf';
  static String apiPath = '/api/app/v2/';
  static String package = 'at_onboarding_flutter';
  static String encryptKeys = '_encrypt_keys';
  static String backupFileExtension = '.atKeys';
  static String backupZipExtension = '_atKeys.zip';
  static int responseTimeLimit = 30;
  static String contactAddress = 'support@atsign.com';

  static get serverDomain => _rootDomain;

  static set rootDomain(String? domain) {
    _rootDomain = domain ?? 'root.atsign.org';
    if (_rootDomain == 'root.atsign.org') {
      website = 'https://atsign.com';
      apiEndPoint = 'my.atsign.com';
    } else {
      website = 'https://atsign.wtf';
      apiEndPoint = 'my.atsign.wtf';
    }
  }

  static String? _apiKey;
  static String setApiKey(String _key) => _apiKey = _key;
  static String? get apiKey => _apiKey;
}

extension customMessages on OnboardingStatus {
  String get message {
    switch (this) {
      case (OnboardingStatus.ACTIVATE):
        return 'Your atsign got reactivated. Please activate with the new QRCode available on ${AppConstants.serverDomain} website.';
      case (OnboardingStatus.ENCRYPTION_PRIVATE_KEY_NOT_FOUND):
      case (OnboardingStatus.ENCRYPTION_PUBLIC_KEY_NOT_FOUND):
      case (OnboardingStatus.PKAM_PRIVATE_KEY_NOT_FOUND):
      case (OnboardingStatus.PKAM_PUBLIC_KEY_NOT_FOUND):
        return 'Fatal error occurred. Please contact support@atsign.com';
      case (OnboardingStatus.RESTORE):
        return 'Please restore it with the available backup zip file as the local keys were missing.';
      default:
        return '';
    }
  }
}
