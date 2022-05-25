// ignore_for_file: unnecessary_cast

class ProfileModel {
  late String id;
  int dudesSent = 0;
  Duration dudeHours = const Duration(milliseconds: 0);
  Duration longestDude = const Duration(milliseconds: 0);

  ProfileModel({
    required this.id,
    required this.dudesSent,
    required this.dudeHours,
    required this.longestDude,
  });

  ProfileModel.newDude();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dudesSent': dudesSent,
      'dudeHours': dudeHours.inMilliseconds,
      'longestDude': longestDude.inMilliseconds,
    };
  }

  ProfileModel.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'] as String,
          dudesSent: json['dudesSent'] as int,
          dudeHours: Duration(milliseconds: json['dudeHours']) as Duration,
          longestDude: Duration(milliseconds: json['longestDude']) as Duration,
        );

  // @override
  // String toString() {
  //   return 'ProfileModel(id: $id, dude: $dude, sender: $sender, receiver: $receiver, timeSent: $timeSent, duration: $duration)';
  // }

  void saveId(String value) => id = value;
  void saveDudesSent(int value) => dudesSent = value;
  void saveDudeHours(Duration value) => dudeHours = value;
  void saveLongestDude(Duration value) => longestDude = value;

  bool getChampionStats() {
    return longestDude >= const Duration(hours: 1);
  }
}
