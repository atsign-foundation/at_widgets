import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_utils/at_logger.dart';

class AtOnboardingConfig {
  ///Required field as for navigation.
  final BuildContext context;

  ///hides the references to webpages if set to true
  final bool? hideReferences;

  ///hides the qr functionality if set to true
  final bool? hideQrScan;

  ///Onboards the given [atsign] if not null.
  ///if [atsign] is null then takes the atsign from keychain.
  ///if[atsign] is empty then it directly jumps into authenticate without performing onboarding. (or)
  ///if [atsign] is empty then it just presents pairAtSign screen without onboarding the atsign. (or)
  ///Just provide an empty string for ignoring existing atsign in keychain or app's atsign.
  final String? atsign;

  ///The atClientPreference [required] to continue with the onboarding.
  final AtClientPreference atClientPreference;

  ///Default the plugin connects to [root.atsign.org] to perform onboarding.
  final String? domain;

  ///The color of the screen to match with the app's aesthetics. default it is [black].
  final Color? appColor;

  ///if logo is not null then displays the widget in the left side of appbar else displays nothing.
  final Widget? logo;

  ///Function returns atClientServiceMap on successful onboarding along with onboarded @sign.
  late Function(Map<String?, AtClientService>, String?) onboard;

  ///Function returns error when failed in onboarding the existing or given atsign if [nextScreen] is null;
  final Function(Object?) onError;

  ///after successful onboarding will gets redirected to this screen if it is not null.
  final Widget? nextScreen;

  ///after first time succesful onboarding it will get redirected to this screen if not null.
  final Widget? fistTimeAuthNextScreen;

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
    required this.context,
    this.hideReferences,
    this.hideQrScan,
    this.atsign,
    required this.atClientPreference,
    this.domain,
    this.appColor,
    this.logo,
    required this.onboard,
    required this.onError,
    this.nextScreen,
    this.fistTimeAuthNextScreen,
    this.appAPIKey,
    required this.rootEnvironment,
  });
}
