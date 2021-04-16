import 'package:at_follows_flutter/services/connections_service.dart';

class Atsign {
  String title;
  dynamic profilePicture;
  String subtitle;
  bool isFollowing;

  bool _isValid(String value) {
    return value != null && value != '' && value != 'null';
  }

  setData(AtFollowsValue followsValue) {
    switch (followsValue.atKey.key) {
      case PublicData.image:
        profilePicture = followsValue.value;
        break;
      case PublicData.firstname:
        subtitle = _isValid(followsValue.value) ? followsValue.value + ' ' : '';
        break;
      case PublicData.lastname:
        subtitle = _isValid(followsValue.value)
            ? subtitle + followsValue.value
            : subtitle;
        break;
      default:
        break;
    }
  }

  Atsign({
    this.title,
    this.isFollowing,
    this.subtitle,
    this.profilePicture,
  });

  factory Atsign.fromJson(Map<String, dynamic> json) {
    return Atsign(
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        isFollowing: json['isFollowing'] as bool,
        profilePicture: json['profilePicture'] as dynamic);
  }
}

class PublicData {
  static const String image = 'image.persona';
  static const String firstname = 'firstname.persona';
  static const String lastname = 'lastname.persona';

  static List<String> list = [image, firstname, lastname];
}
