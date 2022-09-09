import 'dart:io';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_home_screen.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:flutter/material.dart';

import '../utils/at_onboarding_strings.dart';
import '../widgets/at_onboarding_button.dart';

class AtOnboardingIntroScreen extends StatefulWidget {
  final AtOnboardingConfig config;

  const AtOnboardingIntroScreen({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<AtOnboardingIntroScreen> createState() =>
      _AtOnboardingIntroScreenState();
}

class _AtOnboardingIntroScreenState extends State<AtOnboardingIntroScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.appColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.appColor,
          ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AtOnboardingStrings.onboardingTitle),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AtOnboardingDimens.borderRadius)),
            padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
            margin: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "This app was build on the @ platform, that @ platform apps require atSigns.",
                  style: TextStyle(
                    fontSize: AtOnboardingDimens.fontLarge,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AtOnboardingPrimaryButton(
                  height: 48,
                  borderRadius: 24,
                  child: Text(
                    'I have an atSign',
                    style: TextStyle(
                      color: Platform.isIOS || Platform.isAndroid
                          ? Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black
                          : null,
                    ),
                  ),
                  onPressed: () {
                    _navigateToHomePage(true);
                  },
                ),
                const SizedBox(height: 16),
                AtOnboardingSecondaryButton(
                  height: 48,
                  borderRadius: 24,
                  child: const Text(
                    "I don't have an atSign",
                  ),
                  onPressed: () {
                    _navigateToHomePage(false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHomePage(bool haveAtSign) async {
    //Navigate user to screen to add new atsign
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AtOnboardingHomeScreen(
            config: widget.config,
            haveAnAtsign: haveAtSign,
          );
        },
      ),
    );

    if (result != null) {
      if (!mounted) return;
      Navigator.pop(context, result);
    }
  }
}
