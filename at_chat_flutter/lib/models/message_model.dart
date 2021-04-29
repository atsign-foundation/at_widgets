import 'dart:convert';

enum MessageType { INCOMING, OUTGOING }

class Message {
  int? time;
  String? message;
  MessageType? type;
  String? sender;
  Message({this.time, this.message, this.type, this.sender});

  Message copyWith(
      {int? time, String? message, MessageType? type, String? sender}) {
    return Message(
        time: time ?? this.time,
        message: message ?? this.message,
        type: type ?? this.type,
        sender: sender ?? this.sender);
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'message': message,
      'type': type == MessageType.values[0] ? 0 : 1,
      'sender': sender
    };
  }

  factory Message.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Message();

    return Message(
        time: map['time'],
        message: map['message'],
        type: MessageType.values[map['type']],
        sender: map['sender']);
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));

  @override
  String toString() =>
      'Message(time: $time, message: $message, type: ${type.toString()}, sender: $sender)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Message &&
        o.time == time &&
        o.message == message &&
        o.type == type &&
        o.sender == sender;
  }

  @override
  int get hashCode =>
      time.hashCode ^ message.hashCode ^ type.hashCode ^ sender.hashCode;
}
