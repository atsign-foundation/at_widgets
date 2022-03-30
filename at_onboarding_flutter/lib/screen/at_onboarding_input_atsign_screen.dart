import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:flutter/material.dart';

import 'at_onboarding_reference_screen.dart';

class AtOnboardingInputAtSignScreen extends StatefulWidget {
  static Future<String?> push({
    required BuildContext context,
  }) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const AtOnboardingInputAtSignScreen()));
  }

  const AtOnboardingInputAtSignScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AtOnboardingInputAtSignScreen> createState() =>
      _AtOnboardingInputAtSignScreenState();
}

class _AtOnboardingInputAtSignScreenState
    extends State<AtOnboardingInputAtSignScreen> {
  final TextEditingController _atsignController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting up your account'),
        actions: [
          IconButton(
            onPressed: _showReferenceWebview,
            icon: const Icon(Icons.help),
          ),
        ],
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
                'Activate @sign',
                style: TextStyle(
                  fontSize: AtOnboardingDimens.fontLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                enabled: true,
                validator: (String? value) {
                  if (value == null || value == '') {
                    return '@sign cannot be empty';
                  }
                  return null;
                },
                controller: _atsignController,
                decoration: InputDecoration(
                  hintText: AtOnboardingStrings.atsignHintText,
                  prefix: Text(
                    '@',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: AtOnboardingDimens.paddingSmall),
                ),
              ),
              SizedBox(height: 20),
              AtOnboardingPrimaryButton(
                height: 48,
                borderRadius: 24,
                onPressed: _activateAtSign,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Activate',
                      style: TextStyle(
                        fontSize: AtOnboardingDimens.fontLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReferenceWebview() {
    AtOnboardingReferenceScreen.push(
      context: context,
      title: AtOnboardingStrings.faqTitle,
      url: AtOnboardingStrings.faqUrl,
    );
  }

  void _activateAtSign() async {
    final String atSign = _atsignController.text;
    Navigator.pop(context, atSign);
  }
}
