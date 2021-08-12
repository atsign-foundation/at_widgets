import 'dart:convert';

class BugReport {
  int? time;
  String? atSign;
  String? screen;

  BugReport({
    this.time,
    this.atSign,
    this.screen,
  });

  BugReport copyWith(
      {int? time, String? atSign, String? screen}) {
    return BugReport(
        time: time ?? this.time,
        atSign: atSign ?? this.atSign,
        screen: screen ?? this.screen);
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'atSign': atSign,
      'screen': screen,
    };
  }

  factory BugReport.fromMap(Map<String, dynamic>? map) {
    if (map == null) return BugReport();

    return BugReport(
        time: map['time'],
        atSign: map['atSign'],
        screen: map['screen']);
  }

  String toJson() => json.encode(toMap());

  factory BugReport.fromJson(String source) =>
      BugReport.fromMap(json.decode(source));

  @override
  String toString() =>
      'BugReport(time: $time, atSign: $atSign, screen: $screen)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is BugReport &&
        o.time == time &&
        o.atSign == atSign &&
        o.screen == screen;
  }

  @override
  int get hashCode =>
      time.hashCode ^ atSign.hashCode ^ screen.hashCode;
}
