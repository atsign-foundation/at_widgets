import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const envVars = {
    'NAMESPACE': 'namespace-value',
    'ROOT_DOMAIN': 'domain-value',
    'API_KEY': 'api-key-value',
  };

  group('AtEnv Test', () {
    setUp(() {
      dotenv.env.addAll(envVars);
    });
    tearDown(() => dotenv.clean());

    test('Load NAMESPACE Test', () {
      const key = 'NAMESPACE';
      var fromDotEnv = dotenv.env[key];
      var fromAtEnv = AtEnv.appNamespace;
      expect(fromAtEnv, fromDotEnv);
      expect(fromDotEnv, envVars[key]);
    });

    test('Load ROOT_DOMAIN Test', () {
      const key = 'ROOT_DOMAIN';
      var fromDotEnv = dotenv.env[key];
      var fromAtEnv = AtEnv.rootDomain;
      expect(fromAtEnv, fromDotEnv);
      expect(fromDotEnv, envVars[key]);
    });

    test('Load API_KEY Test', () {
      const key = 'API_KEY';
      var fromDotEnv = dotenv.env[key];
      var fromAtEnv = AtEnv.appApiKey;
      expect(fromAtEnv, fromDotEnv);
      expect(fromDotEnv, envVars[key]);
    });
  });
}
