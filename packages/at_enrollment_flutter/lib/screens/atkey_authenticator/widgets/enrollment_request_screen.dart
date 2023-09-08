import 'package:at_enrollment_flutter/screens/atkey_authenticator/widgets/enrollment_request_card.dart';
import 'package:at_enrollment_flutter/services/enrollment_service.dart';
import 'package:at_enrollment_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class EnrollmentRequestScreen extends StatefulWidget {
  const EnrollmentRequestScreen({super.key});

  @override
  State<EnrollmentRequestScreen> createState() =>
      _EnrollmentRequestScreenState();
}

class _EnrollmentRequestScreenState extends State<EnrollmentRequestScreen> {
  @override
  void initState() {
    fetchPendingEnrollments();
    super.initState();
  }

  fetchPendingEnrollments() async {
    await EnrollmentServiceWrapper.getInstance().fetchPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // buildDateLabel('Today'),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: EnrollmentServiceWrapper.getInstance()
                .pendingEnrollmentControllerStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('enrollmentData : ${snapshot.data!}');
                return ListView.separated(
                  itemCount: snapshot.data?.length ?? 0,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (context, index) {
                    return snapshot.data?[index] != null
                        ? EnrollmentRequestCard(
                            status: RequestStatus.pending,
                            enrollmentData: snapshot.data![index],
                          )
                        : const SizedBox.shrink();
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const Center(
                  child: Text('No data found'),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildDateLabel(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: ColorConstant.lightGray,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
