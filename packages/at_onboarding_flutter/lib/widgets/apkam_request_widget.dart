// import 'package:at_client/src/enrollment/enrollment_request.dart';
import 'package:at_client/src/enrollment/enrollment_request.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:crypton/crypton.dart';
import 'package:flutter/material.dart';

class ApkamRequestWidget extends StatelessWidget {
  ApkamRequestWidget({Key? key}) : super(key: key);
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // create enrollment builder so form field value can be saved
    EnrollmentBuilder enrollmentBuilder = Enrollment.request();

    /// method to request enrollment
    _requestEnrollment(String appName) async {
      if (_formkey.currentState!.validate()) {
        _formkey.currentState!.save();
        isLoading = true;
        final currentAtSign = AtClientManager.getInstance().atClient.getCurrentAtSign()!;

        final preferences = AtClientManager.getInstance().atClient.getPreferences()!;

        final namespace = preferences.namespace!;

        final AtClient atClient = await AtClientImpl.create(currentAtSign, namespace, preferences);

        // atClient.getOTP().then((value) => enrollmentBuilder.setTotp(value));
        // ;

        enrollmentBuilder.setAPKAMPublicKey(RSAKeypair.fromRandom().publicKey.toString());

        final Enrollment enrollment = enrollmentBuilder.build();

        EnrollmentResponse enrollmentResponse = await atClient.enroll(enrollment);
        isLoading = false;
      }
    }

// TODO: create a strings file to store all strings
    return Card(
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'App Name',
            ),
            onSaved: (newValue) => enrollmentBuilder.setAppName(newValue!),
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Device Name',
            ),
            onSaved: (newValue) => enrollmentBuilder.setDeviceName(newValue!),
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Namespaces',
            ),
            onSaved: (newValue) => enrollmentBuilder.setNamespaces([newValue!]),
          ),
        ],
      ),
    );
  }
}
