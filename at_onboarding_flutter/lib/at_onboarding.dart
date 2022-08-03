import 'package:at_onboarding_flutter/screen/at_onboarding_activate_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reset_screen.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:flutter/material.dart';

import 'at_onboarding_result.dart';
import 'screen/at_onboarding_home_screen.dart';
import 'services/at_onboarding_config.dart';
import 'screen/at_onboarding_start_screen.dart';

class AtOnboarding {
  /// Using this function to get onboard atsing.
  ///
  /// @param context The build context.
  /// @param config The config for the onboard
  /// @param isSwitchingAtsign True - alway show UI for add new atsign. False - check onboard if existing atsing. Default is false
  /// @param atsign The atsign name when change the primary atsign.
  ///
  /// Return [AtOnboardingResult]
  static Future<AtOnboardingResult> onboard({
    required BuildContext context,
    required AtOnboardingConfig config,
    bool isSwitchingAtsign = false,
    String? atsign,
  }) async {
    AtOnboardingConstants.setApiKey(config.appAPIKey ??
        (AtOnboardingConstants.rootEnvironment.apikey ?? ''));
    AtOnboardingConstants.rootDomain =
        config.domain ?? AtOnboardingConstants.rootEnvironment.domain;

    if (!isSwitchingAtsign || (atsign ?? '').trim().isNotEmpty) {
      if ((atsign ?? '').trim().isNotEmpty) {
        await changePrimaryAtsign(atsign: atsign!);
      }
      //Check if existing an atsign => return onboard success
      final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AtOnboardingStartScreen(config: config),
      );
      if (result is AtOnboardingResult) {
        return result;
      } else {
        return AtOnboardingResult.cancelled();
      }
    } else {
      //Navigate user to screen to add new atsign
      final result = await Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return AtOnboardingHomeScreen(config: config);
      }));
      if (result is AtOnboardingResult) {
        //Update primary atsign after onboard success
        if (result.status == AtOnboardingResultStatus.success &&
            result.atsign != null) {
          await changePrimaryAtsign(atsign: result.atsign!);
        }
        return result;
      } else {
        return AtOnboardingResult.cancelled();
      }
    }
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
      return result;
    } else {
      return AtOnboardingResult.cancelled();
    }
  }

  static Future<bool> changePrimaryAtsign({required String atsign}) async {
    return await OnboardingService.getInstance()
        .changePrimaryAtsign(atsign: atsign);
  }

  static Future<AtOnboardingResetResult> reset({
    required BuildContext context,
    required AtOnboardingConfig config,
  }) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return AtOnboardingResetScreen(config: config);
    }));
    if (result is AtOnboardingResetResult) {
      return result;
    } else {
      return AtOnboardingResetResult.canceled;
    }
  }
}
