import 'dart:io';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_generate_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_home_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reference_screen.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                RichText(
                  text: TextSpan(
                    text:
                        "This app was built on the atPlatform. All atPlatform apps require an atSign. ",
                    style: TextStyle(
                      fontSize: AtOnboardingDimens.fontLarge,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Learn more',
                        style: TextStyle(
                          fontSize: AtOnboardingDimens.fontLarge,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _showReferenceWebview,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AtOnboardingPrimaryButton(
                  height: 48,
                  borderRadius: 24,
                  child: Text(
                    'Already have an atSign',
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
                    "Get a free atSign",
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
    AtOnboardingResult? result;

    if (!haveAtSign) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AtOnboardingGenerateScreen(
            config: widget.config,
          ),
        ),
      );
    } else {
      //Navigate user to screen to add new atsign
      result = await Navigator.push(
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
    }

    if (result != null) {
      if (!mounted) return;
      Navigator.pop(context, result);
    }
  }

  void _showReferenceWebview() {
    if (Platform.isAndroid || Platform.isIOS) {
      AtOnboardingReferenceScreen.push(
        context: context,
        title: AtOnboardingStrings.faqTitle,
        url: AtOnboardingStrings.faqUrl,
        config: widget.config,
      );
    } else {
      launchUrl(
        Uri.parse(
          AtOnboardingStrings.faqUrl,
        ),
      );
    }
  }
}