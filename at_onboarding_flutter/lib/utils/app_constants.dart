class AppConstants {
  static String _rootDomain = 'root.atsign.org';
  static String website;
  static String package = 'at_onboarding_flutter';
  static String encryptKeys = '_encrypt_keys';
  static String backupFileExtension = '.atKeys';
  static String backupZipExtension = '_atKeys.zip';

  static get serverDomain => _rootDomain;

  static set rootDomain(String domain) {
    _rootDomain = domain;
    website =
        _rootDomain == 'root.atsign.org' ? 'www.atsign.com' : 'www.atsign.wtf';
  }
}
