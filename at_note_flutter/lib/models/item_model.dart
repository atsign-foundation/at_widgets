import 'dart:convert';

class Item {
  int? time;
  String? type;
  String? value;
  String? showType;

  Item({
    this.time,
    this.type,
    this.value,
    this.showType = 'base64',
  });

  Item copyWith({int? time, String? atSign, String? message}) {
    return Item(
      time: time ?? this.time,
      type: type ?? this.type,
      value: value ?? this.value,
      showType: showType ?? this.showType,
    );
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      time: map['time'],
      type: map['type'],
      value: map['value'],
      showType: map['showType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'type': type,
      'value': value,
      'showType': showType,
    };
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));

  @override
  String toString() =>
      'Item(time: $time, type: $type, value: $value, showType: $showType)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Item &&
        o.time == time &&
        o.type == type &&
        o.value == value &&
        o.showType == showType;
  }

  @override
  int get hashCode =>
      time.hashCode ^ type.hashCode ^ value.hashCode ^ showType.hashCode;
}
