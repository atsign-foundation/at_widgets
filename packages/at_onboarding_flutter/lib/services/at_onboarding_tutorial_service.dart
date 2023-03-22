import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const int _tutorialVersion = 2;

enum TutorialDisplay {
  normal,
  always,
  never,
}

class TutorialServiceInfo {
  int versionInfo;
  bool hasShowSignInPage;
  bool hasshowSignUpPage;

  TutorialServiceInfo({
    this.versionInfo = _tutorialVersion,
    this.hasShowSignInPage = false,
    this.hasshowSignUpPage = false,
  });

  factory TutorialServiceInfo.fromJson(Map<String, dynamic> json) {
    return TutorialServiceInfo(
      versionInfo: json['versionInfo'],
      hasShowSignInPage: json['hasShowSignInPage'],
      hasshowSignUpPage: json['hasshowSignUpPage'],
    );
  }

  Map<String, dynamic> toJson() => {
    "versionInfo": versionInfo,
    "hasShowSignInPage": hasShowSignInPage,
    "hasshowSignUpPage": hasshowSignUpPage,
  };
}

class TutorialService {
  static const _tutorialInfo = 'tutorialInfo';

  static Future<TutorialServiceInfo?> getTutorialInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return TutorialServiceInfo.fromJson(
        jsonDecode(
          prefs.getString(_tutorialInfo) ?? '',
        ),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> setTutorialInfo(TutorialServiceInfo info) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    info.versionInfo = _tutorialVersion;
    final data = jsonEncode(info);
    await prefs.setString(_tutorialInfo, data);
  }

  static Future<bool> hasShowTutorialSignIn() async {
    final tutorialInfo = await getTutorialInfo();
    return tutorialInfo?.hasShowSignInPage ?? false;
  }

  static Future<bool> hasShowTutorialSignUp() async {
    final tutorialInfo = await getTutorialInfo();
    return tutorialInfo?.hasshowSignUpPage ?? false;
  }

  static Future<bool> checkShowTutorial() async {
    final tutorialInfo = await getTutorialInfo();
    final showPageDone = tutorialInfo?.hasshowSignUpPage != true ||
        tutorialInfo?.hasShowSignInPage != true;
    final checkNewestVersion =
        _tutorialVersion > (tutorialInfo?.versionInfo ?? 0);

    if (checkNewestVersion || showPageDone) {
      if (checkNewestVersion) {
        final tutorialInfo = TutorialServiceInfo();
        await setTutorialInfo(tutorialInfo);
      }
      return false;
    }
    return true;
  }
}
