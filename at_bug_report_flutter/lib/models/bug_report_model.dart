import 'dart:convert';

class BugReport {
  String? time;
  String? atSign;
  String? errorDetail;

  BugReport({
    this.time,
    this.atSign,
    this.errorDetail,
  });

  BugReport copyWith(
      {String? time, String? atSign, String? errorDetail}) {
    return BugReport(
        time: time ?? this.time,
        atSign: atSign ?? this.atSign,
        errorDetail: errorDetail ?? this.errorDetail);
  }

  factory BugReport.fromMap(Map<String, dynamic>? map) {
    if (map == null) return BugReport();

    return BugReport(
        time: map['time'],
        atSign: map['atSign'],
        errorDetail: map['errorDetail']);
  }

  // Map<String, dynamic> toJson() => <String, dynamic> {
  //   'time': time,
  //   'atSign': atSign,
  //   'screen': screen,
  // };

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'atSign': atSign,
      'errorDetail': errorDetail,
    };
  }

  String toJson() => json.encode(toMap());

  factory BugReport.fromJson(String source) =>
      BugReport.fromMap(json.decode(source));

  @override
  String toString() =>
      'BugReport(time: $time, atSign: $atSign, errorDetail: $errorDetail)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is BugReport &&
        o.time == time &&
        o.atSign == atSign &&
        o.errorDetail == errorDetail;
  }
  @override
  int get hashCode =>
      time.hashCode ^ atSign.hashCode ^ errorDetail.hashCode;
}
