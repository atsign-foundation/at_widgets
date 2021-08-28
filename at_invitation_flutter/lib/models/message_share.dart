class MessageShareModel {
  String? passcode;
  String? message;
  String? identifier;

  MessageShareModel({this.passcode, this.message, this.identifier});

  MessageShareModel.fromJson(Map<dynamic, dynamic> json) {
    passcode = json['passcode'] ?? '';
    message = json['message'] ?? '';
    identifier = json['identifier'] ?? '';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['passcode'] = passcode;
    data['message'] = message;
    data['identifier'] = identifier;
    return data;
  }
}
