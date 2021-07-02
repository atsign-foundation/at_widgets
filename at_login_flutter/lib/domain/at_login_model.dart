
class AtLoginObj {
  String atsign;
  String requestorUrl;
  String challenge;
  String requestorLogoUrl;
  String certificate;
  bool allowLogin;

  // bool _isValid(String value) {
  //   return value != null && value != '' && value != 'null';
  // }

  AtLoginObj({
    this.atsign,
    this.requestorUrl,
    this.challenge,
    this.certificate,
    this.allowLogin,
    this.requestorLogoUrl,
  });

  Map<String, dynamic> toJson() => {
    'atsign': atsign,
    'requestorUrl': requestorUrl,
    'challenge': challenge,
    'certificate': certificate,
    'allowLogin': allowLogin.toString(),
    'requestorLogoUrl': requestorLogoUrl,
  };

  factory AtLoginObj.fromJson(Map<String, dynamic> json) {
    return AtLoginObj(
        atsign: json['atsign'] as String,
        requestorUrl: json['requestorUrl'] as String,
        challenge: json['challenge'] as String,
        certificate: json['certificate'] as String,
        allowLogin: json['allowLogin'] as bool,
        requestorLogoUrl: json['requestorLogoUrl'] as String);
  }
}

class PublicData {
  static const String image = 'image.wavi';
  static const String firstname = 'firstname.wavi';
  static const String lastname = 'lastname.wavi';

  static const String imagePersona = 'image.persona';
  static const String firstnamePersona = 'firstname.persona';
  static const String lastnamePersona = 'lastname.persona';

  static List<String> list = [image, firstname, lastname];

  static Map<String, String> personaMap = {
    image: imagePersona,
    firstname: firstnamePersona,
    lastname: lastnamePersona
  };
}
