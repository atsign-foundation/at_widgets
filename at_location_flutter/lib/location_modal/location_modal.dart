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
    lat = ad['position']['lat'].toString();
    long = ad['position']['lng'].toString();
    displayName = ad['address']['label'].toString();
    state = ad['address']['state'] ?? '';
    city = ad['address']['city'] ?? '';
    postalCode = ad['address']['postalCode'] ?? '';
  }
}
