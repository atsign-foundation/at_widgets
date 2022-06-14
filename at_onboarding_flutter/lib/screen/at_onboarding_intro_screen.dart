import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:flutter/material.dart';

import '../utils/at_onboarding_strings.dart';
import '../widgets/at_onboarding_button.dart';

class AtOnboardingIntroScreen extends StatefulWidget {
  const AtOnboardingIntroScreen({Key? key}) : super(key: key);

  @override
  State<AtOnboardingIntroScreen> createState() =>
      _AtOnboardingIntroScreenState();
}

class _AtOnboardingIntroScreenState extends State<AtOnboardingIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                "This app was build on the @ platform, that @ platform apps require atsigns.",
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
                child: const Text(
                  'I have an atsign',
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              const SizedBox(height: 16),
              AtOnboardingSecondaryButton(
                height: 48,
                borderRadius: 24,
                child: const Text(
                  "I don't have an atsign",
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
