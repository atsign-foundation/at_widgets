import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:flutter/material.dart';

import '../at_onboarding.dart';
import '../services/at_onboarding_config.dart';

class AtOnboardingStartScreen extends StatefulWidget {
  final AtOnboardingConfig config;

  const AtOnboardingStartScreen({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  _AtOnboardingStartScreenState createState() =>
      _AtOnboardingStartScreenState();
}

class _AtOnboardingStartScreenState extends State<AtOnboardingStartScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final OnboardingService _onboardingService =
        OnboardingService.getInstance();
    _onboardingService.setAtClientPreference = widget.config.atClientPreference;
    try {
      final result = await _onboardingService.onboard();
      debugPrint("AtOnboardingInitScreen: result - $result");
      Navigator.pop(context, AtOnboardingResult.success);
    } catch (e) {
      debugPrint("AtOnboardingInitScreen: error - $e");
      //Todo
      if (e == OnboardingStatus.ATSIGN_NOT_FOUND ||
          e == OnboardingStatus.PRIVATE_KEY_NOT_FOUND) {
        Navigator.pop(context, AtOnboardingResult.notFound);
      } else if (e == OnboardingStatus.ACTIVATE) {
        Navigator.pop(context, AtOnboardingResult.activate);
      } else {
        Navigator.pop(context, AtOnboardingResult.error);
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AtSyncIndicator(),
              SizedBox(width: AtOnboardingDimens.paddingSmall),
              Text('Onboarding'),
            ],
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                BorderRadius.circular(AtOnboardingDimens.dialogBorderRadius),
          ),
        ),
      ),
    );
  }
}
