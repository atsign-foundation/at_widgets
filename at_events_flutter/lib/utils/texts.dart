class AllText {
  AllText._();
  static AllText _instance = AllText._();
  factory AllText() => _instance;

  // ignore: non_constant_identifier_names
  String APP_NAME = '@location';

  // ignore: non_constant_identifier_names
  String CANCEL = 'Cancel';

  // ignore: non_constant_identifier_names
  String CLOSE = 'Close';
  // ignore: non_constant_identifier_names
  String URL(int x, int y, int z) {
    return 'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
  }

  // notification
  // ignore: non_constant_identifier_names
  String MSG_NOTIFY = 'msgNotify';
  // ignore: non_constant_identifier_names
  String LOCATION_NOTIFY = 'locationotify';
  // ignore: non_constant_identifier_names
  String EVENT_NOTIFY = 'eventnotify';
}
