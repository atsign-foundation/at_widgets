import 'dart:convert';

import 'package:at_enrollment_app/models/enrollment.dart';
import 'package:at_enrollment_app/screens/components/enrollment_request_card.dart';
import 'package:at_enrollment_app/services/enrollment_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

class EnrollmentRequestScreen extends StatefulWidget {
  const EnrollmentRequestScreen({super.key});

  @override
  State<EnrollmentRequestScreen> createState() =>
      _EnrollmentRequestScreenState();
}

class _EnrollmentRequestScreenState extends State<EnrollmentRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const SizedBox(height: 25),
          StreamBuilder<AtNotification>(
            stream:
                EnrollmentService.getInstance().fetchEnrollmentNotifications(),
            builder:
                (BuildContext context, AsyncSnapshot<AtNotification> snapshot) {
              if (snapshot.hasData) {
                EnrollmentData enrollmentData = EnrollmentData(
                  snapshot.data!.from,
                  '${snapshot.data!.key}${snapshot.data!.from}',
                  jsonDecode(
                      snapshot.data!.value!)['encryptedApkamSymmetricKey'],
                );

                print('enrollmentData : ${snapshot.data!}');

                return EnrollmentRequestCard(
                  enrollmentData: enrollmentData,
                );
              } else if (snapshot.hasError) {
                // Handle error case
                return Text('Error: ${snapshot.error}');
              } else {
                // Handle loading or initial state
                return const Center(
                  child: Column(
                    children: [
                      Text('No request'),
                      Text('At the moment'),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
