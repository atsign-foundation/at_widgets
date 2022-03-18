import 'package:at_onboarding_flutter/screen/at_onboarding_activate_account_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reset_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_screen.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_size_config.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_color_constants.dart';
import 'package:flutter/material.dart';

import 'services/at_onboarding_config.dart';
import 'screen/at_onboarding_start_screen.dart';

enum AtOnboardingResult {
  success, //Authenticate success
  error, //Authenticate error
  notFound, //Don't exist any account
  activate, //Have an account and need to activate
  cancel, //User canceled
}

class AtOnboarding {
  static Future<AtOnboardingResult> onboard({
    required BuildContext context,
    required AtOnboardingConfig config,
  }) async {
    AtOnboardingColorConstants.darkTheme = Theme.of(context).brightness == Brightness.dark;
    AtOnboardingAppConstants.setApiKey(
        config.appAPIKey ?? (AtOnboardingAppConstants.rootEnvironment.apikey ?? ''));
    AtOnboardingAppConstants.rootDomain =
        config.domain ?? AtOnboardingAppConstants.rootEnvironment.domain;
    AtOnboardingSizeConfig().init(context);
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AtOnboardingStartScreen(config: config),
    );
    if (result is AtOnboardingResult) {
      switch (result) {
        case AtOnboardingResult.success:
          return AtOnboardingResult.success;
        case AtOnboardingResult.error:
          return AtOnboardingResult.error;
        case AtOnboardingResult.notFound:
          return start(
            context: context,
            config: config,
          );
          break;
        case AtOnboardingResult.activate:
          return activateAccount(context: context);
        case AtOnboardingResult.cancel:
          break;
      }
    }
    return AtOnboardingResult.cancel;
  }

  static Future<AtOnboardingResult> start({
    required BuildContext context,
    required AtOnboardingConfig config,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    AtOnboardingColorConstants.darkTheme = Theme.of(context).brightness == Brightness.dark;
    AtOnboardingAppConstants.setApiKey(
        config.appAPIKey ?? (AtOnboardingAppConstants.rootEnvironment.apikey ?? ''));
    AtOnboardingAppConstants.rootDomain =
        config.domain ?? AtOnboardingAppConstants.rootEnvironment.domain;
    // await showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (_) => AtOnboardingScreen(config: config),
    // );

    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return AtOnboardingScreen(config: config);
    }));

    if (result is AtOnboardingResult) {
      switch (result) {
        case AtOnboardingResult.success:
          return AtOnboardingResult.success;
        case AtOnboardingResult.error:
          return AtOnboardingResult.error;
        case AtOnboardingResult.activate:
          return activateAccount(context: context);
      }
    }
    return AtOnboardingResult.cancel;
  }

  static Future<AtOnboardingResult> activateAccount({
    required BuildContext context,
  }) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return const AtOnboardingActivateAccountScreen(
        hideReferences: false,
      );
    }));

    if (result is AtOnboardingResult) {
      switch (result) {
        case AtOnboardingResult.success:
          return AtOnboardingResult.success;
        case AtOnboardingResult.error:
          return AtOnboardingResult.error;
      }
    }
    return AtOnboardingResult.cancel;
  }

  static Future<AtOnboardingResult> reset({
    required BuildContext context,
    required AtOnboardingConfig config,
  }) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return AtOnboardingResetScreen(config: config);
    }));
    if (result is AtOnboardingResult) {
      return result;
    } else {
      return AtOnboardingResult.cancel;
    }
  }
}
