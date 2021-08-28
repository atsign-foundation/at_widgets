class MixedConstants {
  static const String websiteURL = 'https://atsign.com/';

  // for local server
  // static const String ROOT_DOMAIN = 'vip.ve.atsign.zone';
  // for staging server
  // static const String ROOT_DOMAIN = 'root.atsign.wtf';
  // for production server
  static const String rootDomain = 'root.atsign.org';

  static const String termsCondition = 'https://atsign.com/terms-conditions/';
  static const String privacyPolicy = 'https://atsign.com/privacy-policy/';

  static const String shareLocation = 'sharelocation';
  static const String shareLocationACK = 'sharelocationacknowledged';

  static const String requestLocation = 'requestlocation';
  static const String requestLocationACK = 'requestlocationacknowledged';
  static const String deleteRequestLocationACK = 'deleterequestacklocation';

  static const bool isDedicated = true;

  static String? _map_key;
  static String setMapKey(String _key) => _map_key = _key;
  static String? get MAP_KEY => _map_key;

  static String? _api_key;
  static String setApiKey(String _key) => _api_key = _key;
  static String? get API_KEY => _api_key;
}
