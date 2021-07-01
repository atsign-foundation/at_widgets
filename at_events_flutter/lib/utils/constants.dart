class MixedConstants {
  // for local server
  // static const String ROOT_DOMAIN = 'vip.ve.atsign.zone';
  // for staging server
  // static const String ROOT_DOMAIN = 'root.atsign.wtf';
  // for production server
  static const String ROOT_DOMAIN = 'root.atsign.org';

  static const bool isDedicated = true;
  static const String CREATE_EVENT = 'createevent';

  static List<String> startTimeOptions = [
    '2 hours before the event',
    '60 minutes before the event',
    '30 minutes before the event'
  ];

  static List<String> endTimeOptions = [
    '10 mins after I reach the venue',
    'After everyone’s at the venue',
    'At the end of the day'
  ];
}
