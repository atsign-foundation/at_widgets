import 'dart:convert';
import 'dart:typed_data';

import 'item_model.dart';

class Note {
  int? time;
  String? atSign;
  String? title;
  List<Item>? items;
  Uint8List? image;

  Note({
    this.time,
    this.atSign,
    this.title,
    this.items,
    this.image,
  });

  Note copyWith({int? time, String? atSign, String? message}) {
    return Note(
      time: time ?? this.time,
      atSign: atSign ?? this.atSign,
      title: title ?? this.title,
      items: items ?? this.items,
      image: image ?? this.image,
    );
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      time: map['time'],
      atSign: map['atSign'],
      title: map['title'],
      items: map['items'] != null
          ? (map['items'] as List)
              ?.map((e) => Item.fromJson(e as String))
              ?.toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'atSign': atSign,
      'title': title,
      'items': items,
    };
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  @override
  String toString() =>
      'Note(time: $time, atSign: $atSign, title: $title, items: $items)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Note &&
        o.time == time &&
        o.atSign == atSign &&
        o.title == title &&
        o.items == items;
  }

  @override
  int get hashCode =>
      time.hashCode ^ atSign.hashCode ^ title.hashCode ^ items.hashCode;
}
