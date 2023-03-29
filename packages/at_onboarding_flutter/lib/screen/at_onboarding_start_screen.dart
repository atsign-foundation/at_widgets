import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding.dart';
import 'package:at_onboarding_flutter/at_onboarding_result.dart';
import 'package:at_onboarding_flutter/localizations/generated/l10n.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_intro_screen.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_config.dart';
import 'package:at_onboarding_flutter/services/free_atsign_service.dart';
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
  final OnboardingService _onboardingService = OnboardingService.getInstance();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _onboardingService.initialSetup(usingSharedStorage: false);
    // This feature will reopen in future
    // final isUsingSharedStorage = await onboardingService.isUsingSharedStorage();
    // if (isUsingSharedStorage == null) {
    //   //No defind yet
    //   final result = await askUserUseSharedStorage();
    //   await onboardingService.initialSetup(usingSharedStorage: result);
    // } else {
    //   await onboardingService.initialSetup(
    //       usingSharedStorage: isUsingSharedStorage);
    // }
    _onboardingService.setAtClientPreference = widget.config.atClientPreference;
    try {
      final result = await _onboardingService.onboard();
      debugPrint("AtOnboardingInitScreen: result - $result");

      if (!mounted) return;
      Navigator.pop(
        context,
        AtOnboardingResult.success(
          atsign: _onboardingService.currentAtsign!,
        ),
      );
    } catch (e) {
      debugPrint("AtOnboardingInitScreen: error - $e");
      if (e == OnboardingStatus.ATSIGN_NOT_FOUND ||
          e == OnboardingStatus.PRIVATE_KEY_NOT_FOUND) {
        if (!mounted) return;
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return AtOnboardingIntroScreen(
                config: widget.config,
              );
            },
          ),
        );

        if (!mounted) return;
        Navigator.pop(context, result);
      } else if (e == OnboardingStatus.ACTIVATE) {
        final result = await AtOnboarding.activateAccount(
          context: context,
          config: widget.config,
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
    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.primaryColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.primaryColor,
          ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  BorderRadius.circular(AtOnboardingDimens.dialogBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AtSyncIndicator(color: theme.primaryColor),
                const SizedBox(width: AtOnboardingDimens.paddingSmall),
                Text(
                  AtOnboardingLocalizations.current.onboarding,
                ),
              ],
            ),
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
          title: AtOnboardingLocalizations.current.title_shared_storage,
          message: AtOnboardingLocalizations.current.msg_shared_storage,
          actions: [
            AtOnboardingSecondaryButton(
              child: Text(
                AtOnboardingLocalizations.current.btn_no,
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            AtOnboardingPrimaryButton(
              child: Text(
                AtOnboardingLocalizations.current.btn_yes,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
    if (result is bool) {
      return result;
    }
    return false;
  }
}
