import 'dart:convert';

import 'package:at_auth/at_auth.dart';
import 'package:at_enrollment_app/screen/otp_screen.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnrollmentWidget extends StatefulWidget {
  const EnrollmentWidget({super.key});

  @override
  State<StatefulWidget> createState() => _EnrollmentState();
}

class _EnrollmentState extends State<EnrollmentWidget> {
  @override
  Widget build(BuildContext context) {
    List<EnrollmentData> notificationsList = [];
    return Scaffold(
      appBar: AppBar(
          title: const Text('Enrollment Notifications'),
          leading: ElevatedButton(
            onPressed: () {
              context.goNamed('HomePage');
            },
            child: const Icon(Icons.arrow_back),
          )),
      body: StreamBuilder<AtNotification>(
        stream: fetchEnrollmentNotifications(),
        builder:
            (BuildContext context, AsyncSnapshot<AtNotification> snapshot) {
          if (snapshot.hasData) {
            // Display the data from the stream = snapshot.data!.value!;
            notificationsList.add(EnrollmentData(
                snapshot.data!.from,
                '${snapshot.data!.key}${snapshot.data!.from}',
                jsonDecode(
                    snapshot.data!.value!)['encryptedApkamSymmetricKey']));
            return ListView.builder(
              padding: const EdgeInsetsDirectional.symmetric(),
              itemCount: notificationsList.length,
              itemBuilder: (context, index) {
                return _EnrollmentNotificationWidget(
                    enrollmentData: notificationsList[index]);
              },
            );
          } else if (snapshot.hasError) {
            // Handle error case
            return Text('Error: ${snapshot.error}');
          } else {
            // Handle loading or initial state
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomSheet: const OTPWidget(),
    );
  }

  Stream<AtNotification> fetchEnrollmentNotifications() {
    Stream<AtNotification> notificationStream = AtClientManager.getInstance()
        .atClient
        .notificationService
        .subscribe(regex: '__manage');
    return notificationStream;
  }
}

/// Widget to display the enrollment notifications received from the server
class _EnrollmentNotificationWidget extends StatefulWidget {
  final EnrollmentData enrollmentData;

  const _EnrollmentNotificationWidget({required this.enrollmentData});

  @override
  State<StatefulWidget> createState() => _EnrollmentNotificationWidgetState();
}

class _EnrollmentNotificationWidgetState
    extends State<_EnrollmentNotificationWidget> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    return ListBody(
      children: [
        TextButton(
            child: Text(widget.enrollmentData.enrollmentKey),
            onPressed: () {
              setState(() {
                showDetails = !showDetails;
              });
            }),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: showDetails,
                child: TextButton(
                    onPressed: () => {
                          _approveEnrollment(widget.enrollmentData)
                              .then((value) => {
                                    showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                              title: const Text(
                                                  'Enrollment Status'),
                                              content: Text(value.enrollStatus
                                                  .toString()),
                                              actions: [
                                                TextButton(
                                                    onPressed: () => {
                                                          Navigator.pop(context)
                                                        },
                                                    child: const Text('OK'))
                                              ],
                                            ))
                                  }),
                        },
                    child: const Text('Approve')),
              ),
              Visibility(
                visible: showDetails,
                child: TextButton(
                    onPressed: () => {
                          _denyEnrollment(widget.enrollmentData.enrollmentKey)
                              .then((value) => {
                                    showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                              title: const Text(
                                                  'Enrollment Status'),
                                              content: Text(value.enrollStatus
                                                  .toString()),
                                              actions: [
                                                TextButton(
                                                    onPressed: () => {
                                                          Navigator.pop(context)
                                                        },
                                                    child: const Text('OK'))
                                              ],
                                            ))
                                  }),
                        },
                    child: const Text('Deny')),
              )
            ]),
      ],
    );
  }

  Future<dynamic> _approveEnrollment(EnrollmentData enrollmentData) async {
    AtEnrollmentServiceImpl atEnrollmentServiceImpl =
        AtEnrollmentServiceImpl(enrollmentData.atSign, _getAtClientPreferences());
    String enrollmentId = enrollmentData.enrollmentKey
        .substring(0, enrollmentData.enrollmentKey.indexOf('.'));
    AtEnrollmentRequest atEnrollmentRequest = (AtEnrollmentRequest.approve()
          ..setEnrollmentId(enrollmentId)
          ..setEncryptedAPKAMSymmetricKey(
              enrollmentData.encryptedAPKAMSymmetricKey))
        .build();

    AtEnrollmentResponse atEnrollmentResponse = await atEnrollmentServiceImpl
        .manageEnrollmentApproval(atEnrollmentRequest);
    print(
        'Enrollment Id: ${atEnrollmentResponse.enrollmentId} | Enrollment Status ${atEnrollmentResponse.enrollStatus}');
    return atEnrollmentResponse;
  }

  Future<dynamic> _denyEnrollment(String enrollmentKey) async {
    /*AtEnrollmentServiceImpl atEnrollmentServiceImpl =
    AtEnrollmentServiceImpl(enrollmentData.atSign, _getAtClientPreferences());
    String enrollmentId =
        enrollmentKey.substring(0, enrollmentKey.indexOf('.'));
    AtEnrollmentRequest atEnrollmentRequest =
        AtEnrollmentRequest.deny().setEnrollmentId(enrollmentId).build();
    var enrollmentResponse =
        await AtClientManager.getInstance().atClient.enroll(atEnrollmentRequest);
    return enrollmentResponse;*/
  }

  _getAtClientPreferences() {
    return AtClientPreference()
      ..rootDomain = 'root.atsign.org'
      ..namespace = 'enroll'
      ..isLocalStoreRequired = true
      ..enableEnrollmentDuringOnboard = true;
  }
}

class EnrollmentData {
  late String atSign;
  late String enrollmentKey;
  late String encryptedAPKAMSymmetricKey;

  EnrollmentData(
      this.atSign, this.enrollmentKey, this.encryptedAPKAMSymmetricKey);
}
