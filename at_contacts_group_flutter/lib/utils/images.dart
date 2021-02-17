class AllImages {
  AllImages._();
  static AllImages _instance = AllImages._();
  factory AllImages() => _instance;

  // ignore: non_constant_identifier_names
  String PERSON1 = "assets/images/person1.png";
  // ignore: non_constant_identifier_names
  String PERSON2 = "assets/images/person2.png";
  // ignore: non_constant_identifier_names
  String EMPTY_GROUP = "assets/images/empty_group.png";
  // ignore: non_constant_identifier_names
  String GROUP_PHOTO = "assets/images/group_photo.png";
  String SEND = 'assets/images/send.png';
}
