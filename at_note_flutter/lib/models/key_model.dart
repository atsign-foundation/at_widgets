import 'dart:convert';

class Key {
  String? value;
  String? sharedBy;
  bool? isBinary;

  Key({
    this.value,
    this.sharedBy,
    this.isBinary,
  });

  Key copyWith({String? value, String? sharedBy, bool? isBinary}) {
    return Key(
      value: value ?? this.value,
      sharedBy: sharedBy ?? this.sharedBy,
      isBinary: isBinary ?? this.isBinary,
    );
  }

  factory Key.fromMap(Map<String, dynamic> map) {
    return Key(
      value: map['value'],
      sharedBy: map['sharedBy'],
      isBinary: map['isBinary'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'sharedBy': sharedBy,
      'isBinary': isBinary,
    };
  }

  String toJson() => json.encode(toMap());

  factory Key.fromJson(String source) => Key.fromMap(json.decode(source));

  @override
  String toString() =>
      'Key(value: $value, sharedBy: $sharedBy, isBinary: $isBinary)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Key &&
        o.value == value &&
        o.sharedBy == sharedBy &&
        o.isBinary == isBinary;
  }

  @override
  int get hashCode =>
      value.hashCode ^ sharedBy.hashCode ^ isBinary.hashCode;
}
