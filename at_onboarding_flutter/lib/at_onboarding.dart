import 'package:at_onboarding_flutter/at_onboarding_activate_account_screen.dart';
import 'package:at_onboarding_flutter/at_onboarding_reset_screen.dart';
import 'package:at_onboarding_flutter/at_onboarding_screen.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:flutter/material.dart';

import 'at_onboarding_config.dart';
import 'at_onboarding_start_screen.dart';
import 'services/size_config.dart';
import 'utils/app_constants.dart';

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
    ColorConstants.darkTheme = Theme.of(context).brightness == Brightness.dark;
    AppConstants.setApiKey(
        config.appAPIKey ?? (AppConstants.rootEnvironment.apikey ?? ''));
    AppConstants.rootDomain =
        config.domain ?? AppConstants.rootEnvironment.domain;
    SizeConfig().init(context);
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
    ColorConstants.darkTheme = Theme.of(context).brightness == Brightness.dark;
    AppConstants.setApiKey(
        config.appAPIKey ?? (AppConstants.rootEnvironment.apikey ?? ''));
    AppConstants.rootDomain =
        config.domain ?? AppConstants.rootEnvironment.domain;
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
