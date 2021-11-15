class LocationDataModel {
  /// [locationSharingFor] accepts id as key and [LocationSharingFor] as data.
  late Map<String, LocationSharingFor> locationSharingFor;
  late double lat, long;
  late DateTime lastUpdatedAt;
  late String sender, receiver;
}

class LocationSharingFor {
  late DateTime from, to;
  // late LocationSharingType locationSharingType;
}

// enum LocationSharingType { Event, P2P }

/// string-> atsign
/// for sending and receiving location
Map<String, LocationDataModel>? locationReceivedData;
