import 'package:at_enrollment_flutter/at_enrollment_flutter.dart';
import 'package:at_enrollment_flutter/screens/home/home.dart';
import 'package:at_enrollment_flutter/screens/home/onboarding_home_screen.dart';
import 'package:at_enrollment_flutter/services/enrollment_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class AtEnrollment {
  /// [init] should be called before using enrollment_flutter package
  /// it sets [atClientPreference],
  static init(AtClientPreference atClientPreference) {
    EnrollmentServiceWrapper.getInstance().setAtClientPreference =
        atClientPreference;
  }

  /// Use [submitEnrollmentRequest] to submit new enrollment request and generate atKey
  static Future submitEnrollmentRequest(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const HomeScreen();
        },
      ),
    );

    return EnrollmentServiceWrapper.getInstance().enrollmentCompleter.future;
  }

  static manageEnrollmentRequest(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const OnboardingHomeScreen(),
      ),
    );
  }
}
