/// Model containing the [displayName], [state], [city], [suburb], [neighbourhood], [road] associated with the [lat],[long].
class LocationModal {
  String? lat, long;
  String? displayName, state, city, suburb, neighbourhood, road;

  LocationModal(
      {this.lat,
      this.long,
      this.displayName,
      this.state,
      this.city,
      this.suburb,
      this.neighbourhood,
      this.road});

  LocationModal.fromJson(Map<dynamic, dynamic> ad) {
    lat = ad['lat'];
    long = ad['lon'];
    displayName = ad['display_name'];
    state = ad['address']['state'] ?? '';
    city = ad['address']['city'] ?? '';
    suburb = ad['address']['suburb'] ?? '';
    neighbourhood = ad['address']['neighbourhood'] ?? '';
    road = ad['address']['road'] ?? '';
  }

  Map<dynamic, dynamic> toJson() {
    // ignore: omit_local_variable_types
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['lat'] = lat;
    data['long'] = long;
    data['displayName'] = displayName;
    data['state'] = state;
    data['city'] = city;
    data['suburb'] = suburb;
    data['neighbourhood'] = neighbourhood;
    data['road'] = road;
    return data;
  }
}
