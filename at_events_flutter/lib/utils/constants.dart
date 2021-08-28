class MixedConstants {
  // for local server
  // static const String rootDomain = 'vip.ve.atsign.zone';
  // for staging server
  // static const String rootDomain = 'root.atsign.wtf';
  // for production server
  static const String rootDomain = 'root.atsign.org';

  static const bool isDedicated = true;
  static const String createEvent = 'createevent';

  static const String eventMemberLocationKey = 'updateeventlocation';

  static List<String> startTimeOptions = <String>[
    '2 hours before the event',
    '60 minutes before the event',
    '30 minutes before the event'
  ];

  static List<String> endTimeOptions = <String>[
    '10 mins after I reach the venue',
    'After everyone’s at the venue',
    'At the end of the day'
  ];

  static String? _map_key;
  static String setMapKey(String _key) => _map_key = _key;
  static String? get MAP_KEY => _map_key;

  static String? _api_key;
  static String setApiKey(String _key) => _api_key = _key;
  static String? get API_KEY => _api_key;
}
