import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const _tutorialVersion = '_versionTutorial';

  static Future<double> getTutorialVersion() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_tutorialVersion) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static void setTutorialVersion(double version) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_tutorialVersion, version);
  }
}
