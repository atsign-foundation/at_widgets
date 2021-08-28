import 'package:dotenv/dotenv.dart' as dot;

/// AtEnv is a helper class to load in the environment variables from the .env file
class AtEnv {
  /// Load the environment variables from the .env file.
  /// Directly calls load from the dotenv package.
  static void load() => dot.load();

  /// Returns the root domain from the environment.
  /// Root domain is used to control what root server you want to use for the app.
  static final String rootDomain = _getEnvVar('ROOT_DOMAIN') ?? 'root.atsign.org';

  /// Returns the namespace from the environment.
  /// Namespace is used to filter by an app's namespace from the secondary server.
  static final String appNamespace = _getEnvVar('NAMESPACE') ?? 'at_skeleton_app';

  /// Returns the app api key from the environment.
  /// The api key used to generate free @signs by at_onboarding_flutter.
  /// Also used to pay commissions to developers (email )
  static final String appApiKey = _getEnvVar('API_KEY') ?? '';

  /// Returns the value of environment variable [key] loaded from the environment.
  /// Can be used for other environment variables beyond what is included by at_app.
  static String? _getEnvVar(String key) {
    String? value = dot.env[key];
    if (value?.isEmpty ?? false) return null;
    return value;
  }
}
