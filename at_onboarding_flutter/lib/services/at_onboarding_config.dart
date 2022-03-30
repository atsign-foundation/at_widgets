import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_utils/at_logger.dart';

class AtOnboardingConfig {

  ///hides the references to webpages if set to true
  final bool hideReferences;

  ///hides the qr functionality if set to true
  final bool hideQrScan;

  ///The atClientPreference [required] to continue with the onboarding.
  final AtClientPreference atClientPreference;

  ///Default the plugin connects to [root.atsign.org] to perform onboarding.
  final String? domain;

  /// API authentication key for getting free atsigns
  final String? appAPIKey;

  /// Setting up [RootEnvironment] to **Staging** will use the staging environment for onboarding.
  ///
  ///```dart
  /// RootEnvironment.Staging
  ///```
  ///
  /// Setting up RootEnvironment to **Production** will use the production environment for onboarding.
  ///
  ///```dart
  /// RootEnvironment.Production
  ///```
  ///
  /// Setting up RootEnvironment to **Testing** will use the testing(docker) environment for onboarding.
  ///
  ///```dart
  /// RootEnvironment.Testing
  ///```
  ///
  /// **Note:**
  /// API Key is required when you set [rootEnvironment] to production.
  final RootEnvironment rootEnvironment;
  final AtSignLogger logger = AtSignLogger('At Onboarding Flutter');

  AtOnboardingConfig({
    required this.atClientPreference,
    required this.rootEnvironment,
    this.domain,
    this.appAPIKey,
    this.hideReferences = false,
    this.hideQrScan = false,
  });
}
