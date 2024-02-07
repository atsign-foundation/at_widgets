import 'package:at_auth/at_auth.dart';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_enrollment_app/models/enrollment.dart';
import 'package:at_enrollment_app/services/enrollment_service.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class EnrollmentRequestCard extends StatefulWidget {
  final EnrollmentData enrollmentData;
  const EnrollmentRequestCard({super.key, required this.enrollmentData});

  @override
  State<EnrollmentRequestCard> createState() => _EnrollmentRequestCardState();
}

class _EnrollmentRequestCardState extends State<EnrollmentRequestCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 334,
      height: 160,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.enrollmentData.atSign, style: TextStyle(fontSize: 13)),
          Text(
            'SSH No Ports',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text('Read Only', style: TextStyle(fontSize: 13)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                width: 130,
                buttonText: 'Deny',
                fontColor: Colors.grey,
                buttonColor: Colors.grey.withOpacity(0.2),
                onPressed: () {
                  setState(() {});
                },
              ),
              CustomButton(
                width: 130,
                buttonText: 'Approve',
                fontColor: Colors.white,
                buttonColor: ColorConstant.orange,
                onPressed: () {
                  _approveEnrollment(widget.enrollmentData);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> _approveEnrollment(EnrollmentData enrollmentData) async {
    AtEnrollmentServiceImpl atEnrollmentServiceImpl = AtEnrollmentServiceImpl(
      enrollmentData.atSign,
      EnrollmentService.getInstance().getAtClientPreferences(),
    );
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
    AtEnrollmentNotificationRequest atEnrollmentRequest =
        atEnrollmentRequestBuilder.build();

    AtEnrollmentResponse atEnrollmentResponse = await atEnrollmentServiceImpl
        .manageEnrollmentApproval(atEnrollmentRequest);
    print(
        'Enrollment Id: ${atEnrollmentResponse.enrollmentId} | Enrollment Status ${atEnrollmentResponse.enrollStatus}');
    return atEnrollmentResponse;
  }
}
