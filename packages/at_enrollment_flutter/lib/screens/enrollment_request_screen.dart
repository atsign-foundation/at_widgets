import 'package:at_enrollment_flutter/screens/atkey_authenticator/widgets/enrollment_request_card.dart';
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
          Expanded(
            child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, i) {
                  return const Column(
                    children: [
                      // TODO: check this widget
                      // EnrollmentRequestCard(),
                      SizedBox(
                        height: 13,
                      )
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }
}
