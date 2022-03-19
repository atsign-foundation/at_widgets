import 'package:at_onboarding_flutter/screen/at_onboarding_activate_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reset_screen.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_size_config.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:flutter/material.dart';

import 'screen/at_onboarding_home_screen.dart';
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
    AtOnboardingConstants.setApiKey(config.appAPIKey ??
        (AtOnboardingConstants.rootEnvironment.apikey ?? ''));
    AtOnboardingConstants.rootDomain =
        config.domain ?? AtOnboardingConstants.rootEnvironment.domain;
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
    AtOnboardingConstants.setApiKey(config.appAPIKey ??
        (AtOnboardingConstants.rootEnvironment.apikey ?? ''));
    AtOnboardingConstants.rootDomain =
        config.domain ?? AtOnboardingConstants.rootEnvironment.domain;
    AtOnboardingSizeConfig().init(context);
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return AtOnboardingHomeScreen(config: config);
    }));

    if (result is AtOnboardingResult) {
      switch (result) {
        case AtOnboardingResult.success:
          return AtOnboardingResult.success;
        case AtOnboardingResult.error:
          return AtOnboardingResult.error;
        case AtOnboardingResult.activate:
          return activateAccount(context: context);
        case AtOnboardingResult.notFound:
          // TODO: Handle this case.
          break;
        case AtOnboardingResult.cancel:
          // TODO: Handle this case.
          break;
      }
    }
    return AtOnboardingResult.cancel;
  }

  static Future<AtOnboardingResult> activateAccount({
    required BuildContext context,
  }) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return const AtOnboardingActivateScreen(
        hideReferences: false,
      );
    }));

    if (result is AtOnboardingResult) {
      switch (result) {
        case AtOnboardingResult.success:
          return AtOnboardingResult.success;
        case AtOnboardingResult.error:
          return AtOnboardingResult.error;
        case AtOnboardingResult.notFound:
          // TODO: Handle this case.
          break;
        case AtOnboardingResult.activate:
          // TODO: Handle this case.
          break;
        case AtOnboardingResult.cancel:
          // TODO: Handle this case.
          break;
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
