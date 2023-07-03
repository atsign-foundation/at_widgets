/// A class which is used to store the location data.
///
/// [lat] is the latitude of the location.
/// [long] is the longitude of the location.
/// [displayName] is the name of the location.
/// [state] is the state of the location.
/// [city] is the city of the location.
/// [postalCode] is the postal code of the location.

class LocationModal {
  String? lat, long;
  String? displayName, state, city, postalCode;

  LocationModal({
    this.lat,
    this.long,
    this.displayName,
    this.state,
    this.city,
    this.postalCode,
  });

  LocationModal.fromJson(Map<dynamic, dynamic> ad) {
    lat = ad['position'][0].toString(); // 0th index is latitude
    long = ad['position'][1].toString(); // 1st index is longitude
    displayName = ad['title'].toString();
    displayName = '''${(displayName ?? '')},
${ad['vicinity'].toString().replaceAll('<br/>', ' ')}
    ''';
    city = (ad['vicinity'] ?? '').replaceAll('<br/>', ' '); // [vicinity] gives entire address
  }
}
