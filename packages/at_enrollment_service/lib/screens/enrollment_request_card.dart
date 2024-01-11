import 'package:at_auth/at_auth.dart';
import 'package:at_enrollment_app/models/enrollment.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class EnrollmentRequestCard extends StatefulWidget {
  EnrollmentData enrollmentData;
  EnrollmentRequestCard({super.key, required this.enrollmentData});

  @override
  State<EnrollmentRequestCard> createState() => _EnrollmentRequestCardState();
}

class _EnrollmentRequestCardState extends State<EnrollmentRequestCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Text(widget.enrollmentData.atSign),
            Spacer(),
            ElevatedButton(
                onPressed: () {
                  print('accept');
                  _approveEnrollment(widget.enrollmentData);
                },
                child: Text('Accept')),
            ElevatedButton(onPressed: () {}, child: Text('Deny'))
          ],
        ),
      ),
    );
  }

  Future<dynamic> _approveEnrollment(EnrollmentData enrollmentData) async {
    AtEnrollmentServiceImpl atEnrollmentServiceImpl = AtEnrollmentServiceImpl(
        enrollmentData.atSign, _getAtClientPreferences());
    String enrollmentId = enrollmentData.enrollmentKey
        .substring(0, enrollmentData.enrollmentKey.indexOf('.'));
    AtEnrollmentNotificationRequestBuilder atEnrollmentRequestBuilder =
        AtEnrollmentNotificationRequestBuilder();

    atEnrollmentRequestBuilder.setEnrollmentId(enrollmentId);
    atEnrollmentRequestBuilder.setEnrollOperationEnum(
      EnrollOperationEnum.approve,
    );
    atEnrollmentRequestBuilder.setEncryptedApkamSymmetricKey(
        enrollmentData.encryptedAPKAMSymmetricKey);
    // atEnrollmentRequestBuilder.
    AtEnrollmentNotificationRequest atEnrollmentRequest =
        atEnrollmentRequestBuilder.build();

    AtEnrollmentResponse atEnrollmentResponse = await atEnrollmentServiceImpl
        .manageEnrollmentApproval(atEnrollmentRequest);
    print(
        'Enrollment Id: ${atEnrollmentResponse.enrollmentId} | Enrollment Status ${atEnrollmentResponse.enrollStatus}');
    return atEnrollmentResponse;
  }

  _getAtClientPreferences() {
    return AtClientPreference()
      ..rootDomain = 'root.atsign.org'
      ..namespace = 'enroll'
      ..isLocalStoreRequired = true
      ..enableEnrollmentDuringOnboard = true;
  }
}
