import 'dart:convert';

class BugReport {
  String? time;
  String? atSign;
  String? authorAtSign;
  String? errorDetail;

  BugReport({
    this.time,
    this.atSign,
    this.authorAtSign,
    this.errorDetail,
  });

  BugReport copyWith({String? time, String? atSign, String? errorDetail}) {
    return BugReport(
        time: time ?? this.time,
        atSign: atSign ?? this.atSign,
        authorAtSign: authorAtSign ?? this.authorAtSign,
        errorDetail: errorDetail ?? this.errorDetail);
  }

  factory BugReport.fromMap(Map<String, dynamic>? map) {
    if (map == null) return BugReport();

    return BugReport(
        time: map['time'],
        atSign: map['atSign'],
        authorAtSign: map['authorAtSign'],
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
      'authorAtSign':authorAtSign,
      'errorDetail': errorDetail,
    };
  }

  String toJson() => json.encode(toMap());

  factory BugReport.fromJson(String source) =>
      BugReport.fromMap(json.decode(source));

  @override
  String toString() =>
      'BugReport(time: $time, atSign: $atSign, authorAtSign: $authorAtSign,errorDetail: $errorDetail)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is BugReport &&
        o.time == time &&
        o.atSign == atSign &&
        o.authorAtSign == authorAtSign &&
        o.errorDetail == errorDetail;
  }

  @override
  int get hashCode => time.hashCode ^ atSign.hashCode ^ errorDetail.hashCode;
}
