import 'package:at_onboarding_flutter/screen/at_onboarding_otp_screen.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../onboarding_data_test.dart';

void main() {
  late OnboardingDataTest onboardingDataTest;

  setUpAll(() {
    //Runs once before all test cases are executed.
    onboardingDataTest = OnboardingDataTest();
  });

  Widget _defaultApp({
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Material(
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: AtOnboardingOTPScreen(
                hideReferences: true,
                atSign: "unablecoyote17",
                config: onboardingDataTest.config,
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('show Otp Screen', (tester) async {
    await tester.pumpWidget(_defaultApp());
    await tester.pump();

    expect(
        find.text(
          AtOnboardingStrings.onboardingTitle,
        ),
        findsOneWidget);
  });
}
