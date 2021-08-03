class MessageShareModel {
  String? passcode;
  String? message;
  String? identifier;

  MessageShareModel({this.passcode, this.message, this.identifier});

  MessageShareModel.fromJson(json) {
    passcode = json['passcode'] ?? '';
    message = json['message'] ?? '';
    identifier = json['identifier'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['passcode'] = this.passcode;
    data['message'] = this.message;
    data['identifier'] = this.identifier;
    return data;
  }
}
