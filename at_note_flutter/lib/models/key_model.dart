import 'dart:convert';

class KeyModel {
  String? value;
  String? sharedBy;
  bool? isBinary;

  KeyModel({
    this.value,
    this.sharedBy,
    this.isBinary,
  });

  KeyModel copyWith({String? value, String? sharedBy, bool? isBinary}) {
    return KeyModel(
      value: value ?? this.value,
      sharedBy: sharedBy ?? this.sharedBy,
      isBinary: isBinary ?? this.isBinary,
    );
  }

  factory KeyModel.fromMap(Map<String, dynamic> map) {
    return KeyModel(
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

  factory KeyModel.fromJson(String source) => KeyModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'Key(value: $value, sharedBy: $sharedBy, isBinary: $isBinary)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is KeyModel &&
        o.value == value &&
        o.sharedBy == sharedBy &&
        o.isBinary == isBinary;
  }

  @override
  int get hashCode =>
      value.hashCode ^ sharedBy.hashCode ^ isBinary.hashCode;
}
