import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding.dart';
import 'package:at_onboarding_flutter/at_onboarding_result.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_home_screen.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_config.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:flutter/material.dart';

class AtOnboardingStartScreen extends StatefulWidget {
  final AtOnboardingConfig config;

  const AtOnboardingStartScreen({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<AtOnboardingStartScreen> createState() =>
      _AtOnboardingStartScreenState();
}

class _AtOnboardingStartScreenState extends State<AtOnboardingStartScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final OnboardingService onboardingService = OnboardingService.getInstance();
    final isUsingSharedStorage = await onboardingService.isUsingSharedStorage();
    if (isUsingSharedStorage == null) {
      //No defind yet
      final result = await askUserUseSharedStorage();
      await onboardingService.initialSetup(usingSharedStorage: result);
    } else {
      await onboardingService.initialSetup(
          usingSharedStorage: isUsingSharedStorage);
    }
    onboardingService.setAtClientPreference = widget.config.atClientPreference;
    try {
      final result = await onboardingService.onboard();
      debugPrint("AtOnboardingInitScreen: result - $result");
      if (!mounted) return;
      Navigator.pop(context,
          AtOnboardingResult.success(atsign: onboardingService.currentAtsign!));
    } catch (e) {
      debugPrint("AtOnboardingInitScreen: error - $e");
      if (e == OnboardingStatus.ATSIGN_NOT_FOUND ||
          e == OnboardingStatus.PRIVATE_KEY_NOT_FOUND) {
        if (!mounted) return;
        final result = await await Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return AtOnboardingHomeScreen(config: widget.config);
        }));
        if (!mounted) return;
        Navigator.pop(context, result);
      } else if (e == OnboardingStatus.ACTIVATE) {
        final result = await AtOnboarding.activateAccount(
          context: context,
        );
        if (!mounted) return;
        Navigator.pop(context, result);
      } else {
        if (!mounted) return;
        Navigator.pop(
          context,
          AtOnboardingResult.error(
            message: "$e",
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                BorderRadius.circular(AtOnboardingDimens.dialogBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AtSyncIndicator(color: Theme.of(context).primaryColor),
              const SizedBox(width: AtOnboardingDimens.paddingSmall),
              const Text('Onboarding'),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> askUserUseSharedStorage() async {
    final result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AtOnboardingDialog(
            title:
                'Do you want to share this onboarded atsign with other apps on @platform?',
            message:
                'This would save you the process to onboard this atsign on other apps again.',
            actions: [
              AtOnboardingSecondaryButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              AtOnboardingPrimaryButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
    if (result is bool) {
      return result;
    }
    return false;
  }
}
