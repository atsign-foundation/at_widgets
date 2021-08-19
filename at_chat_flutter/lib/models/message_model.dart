import 'dart:convert';

enum MessageType { INCOMING, OUTGOING }
enum MessageContentType { TEXT, IMAGE }

extension MessageContentTypeExt on MessageContentType {
  static MessageContentType? fromIndex(int index) {
    if (index >= 0 && index < MessageContentType.values.length) {
      return MessageContentType.values[index];
    } else {
      return null;
    }
  }
}

class Message {
  int? time;
  String? message;
  MessageType? type;
  MessageContentType? contentType;
  String? sender;

  Message({
    this.time,
    this.message,
    this.type,
    this.contentType = MessageContentType.TEXT,
    this.sender,
  });

  Message copyWith({
    int? time,
    String? message,
    MessageType? type,
    MessageContentType? contentType,
    String? sender,
  }) {
    return Message(
        time: time ?? this.time,
        message: message ?? this.message,
        type: type ?? this.type,
        contentType: contentType ?? this.contentType,
        sender: sender ?? this.sender);
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'message': message,
      'type': type == MessageType.values[0] ? 0 : 1,
      'content_type': contentType?.index,
      'sender': sender,
    };
  }

  factory Message.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Message();

    return Message(
      time: map['time'],
      message: map['message'],
      type: MessageType.values[map['type']],
      contentType: MessageContentTypeExt.fromIndex(map['content_type'] ?? 0),
      sender: map['sender'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));

  @override
  String toString() =>
      'Message(time: $time, message: $message, type: ${type.toString()}, '
      'contentType ${contentType.toString()}, sender: $sender)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Message &&
        o.time == time &&
        o.message == message &&
        o.type == type &&
        o.contentType == contentType &&
        o.sender == sender;
  }

  @override
  int get hashCode =>
      time.hashCode ^ message.hashCode ^ type.hashCode ^ sender.hashCode;
}
