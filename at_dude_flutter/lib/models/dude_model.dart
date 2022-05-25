// ignore_for_file: unnecessary_cast

import 'package:uuid/uuid.dart';

class DudeModel {
  late String id;
  String dude = '';
  late String sender;
  late String receiver;
  late DateTime timeSent;
  late Duration duration;
  DudeModel({
    required this.id,
    required this.dude,
    required this.sender,
    required this.receiver,
    required this.timeSent,
    required this.duration,
  });

  DudeModel.newDude();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dude': dude,
      'sender': sender,
      'receiver': receiver,
      'timeSent': timeSent.toIso8601String(),
      'duration': duration.inMilliseconds,
    };
  }

  DudeModel.fromJson(Map<String, dynamic> json)
      : this(
            id: json['id'] as String,
            dude: json['dude'] as String,
            sender: json['sender'] as String,
            receiver: json['receiver'] as String,
            timeSent: DateTime.parse((json['timeSent'])) as DateTime,
            duration: Duration(milliseconds: json['duration']) as Duration);

  // @override
  // String toString() {
  //   return 'DudeModel(id: $id, dude: $dude, sender: $sender, receiver: $receiver, timeSent: $timeSent, duration: $duration)';
  // }

  void saveId() => id = const Uuid().v4();
  void saveDude(String value) => dude = value;
  void saveSender(String value) => sender = value;
  void saveReceiver(String value) => receiver = value;
  void saveTimeSent() => timeSent = DateTime.now();

  ///Record the duration of a dude.
  /// Record the length of a dude use want to send.
  void saveDuration(DateTime startTime) {
    duration = DateTime.now().difference(startTime);
  }
}
