import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_enrollment_app/screen/home_screen.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:flutter/material.dart';
import 'package:at_auth/at_auth.dart';
import 'package:go_router/go_router.dart';

class SendEnrollmentRequestWidget extends StatefulWidget {
  String? otp;

  SendEnrollmentRequestWidget({Key? key, required this.otp}) : super(key: key);

  @override
  State<SendEnrollmentRequestWidget> createState() =>
      _SendEnrollmentRequestWidgetState();
}

class _SendEnrollmentRequestWidgetState
    extends State<SendEnrollmentRequestWidget> {
  final atSignController = TextEditingController();
  final appNameController = TextEditingController();
  final deviceNameController = TextEditingController();

  final namespaceWidgetList = [_NamespaceWidget()];

  String enrollmentId = '';
  String enrollmentStatus = '';
  String errorDescription = '';
  bool showErrorWidget = false;
  bool showSuccessWidget = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Send Enrollment Request'),
          leading: ElevatedButton(
            onPressed: () {
              context.go('/');
            },
            child: const Icon(Icons.arrow_back),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 150,
                      height: 50,
                      child: TextField(
                        controller: atSignController,
                        decoration: const InputDecoration(
                          labelText: 'Enter atSign',
                        ),
                      )),
                  SizedBox(
                      width: 150,
                      height: 50,
                      child: TextField(
                        controller: appNameController,
                        decoration: const InputDecoration(
                          labelText: 'Enter app name',
                        ),
                      )),
                  SizedBox(
                      width: 150,
                      height: 50,
                      child: TextField(
                        controller: deviceNameController,
                        decoration: const InputDecoration(
                          labelText: 'Enter device name',
                        ),
                      )),
                ],
              ),
            ),
            Container(
                alignment: Alignment.topLeft,
                child: Column(children: namespaceWidgetList)),
            Container(
              padding: const EdgeInsetsDirectional.only(top: 30),
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                  onPressed: () {
                    namespaceWidgetList.add(_NamespaceWidget());
                    setState(() {});
                  },
                  child: const Text('Add another namespace')),
            ),
            Container(
              padding: const EdgeInsetsDirectional.only(top: 30),
              alignment: Alignment.topLeft,
              child: SizedBox(
                  width: 150,
                  height: 50,
                  child: Text(
                      'OTP: ${widget.otp!}') /*TextField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                    ),
                  )*/
                  ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.only(top: 30),
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Map<String, String> namespaceMap = {};
                        for (var namespaceWidget in namespaceWidgetList) {
                          namespaceMap[namespaceWidget.namespaceController
                              .text] = namespaceWidget.getAccess();
                        }
                        _sendEnrollmentRequest(
                            atSignController.text,
                            appNameController.text,
                            deviceNameController.text,
                            widget.otp!,
                            namespaceMap);

                        setState(() {
                          namespaceWidgetList.add(_NamespaceWidget());
                          atSignController.clear();
                          appNameController.clear();
                          deviceNameController.clear();
                          namespaceWidgetList.clear();
                          //otpController.clear();
                        });
                      },
                      child: const Text('Submit enrollment')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          atSignController.clear();
                          appNameController.clear();
                          deviceNameController.clear();
                          namespaceWidgetList.clear();
                          //otpController.clear();
                          namespaceWidgetList.clear();
                          namespaceWidgetList.add(_NamespaceWidget());
                          showErrorWidget = false;
                          showSuccessWidget = false;
                        });
                      },
                      child: const Text('Reset')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.only(top: 30),
              alignment: Alignment.centerLeft,
              child: Column(children: [
                Visibility(
                    visible: showSuccessWidget,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enrollment submitted successfully',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('EnrollmentId: $enrollmentId',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Enrollment Status: $enrollmentStatus',
                            style: const TextStyle(fontWeight: FontWeight.bold))
                      ],
                    )),
                Visibility(
                    visible: showErrorWidget,
                    child: const SizedBox(
                      height: 100,
                      width: 50,
                      child: Text('Failed to send enrollment'),
                    ))
              ]),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _sendEnrollmentRequest(String atSign, String appName,
      String deviceName, String otp, Map<String, String> namespaceMap) async {
    AtEnrollmentRequestBuilder atEnrollmentRequestBuilder =
        AtEnrollmentRequest.request()
          ..setAppName(appName)
          ..setDeviceName(deviceName)
          ..setOtp(otp)
          ..setNamespaces(namespaceMap);
    AtEnrollmentRequest atEnrollmentRequest =
        atEnrollmentRequestBuilder.build();
    EnrollResponse enrollResponse = await OnboardingService.getInstance()
        .enroll(atSign, atEnrollmentRequest);

    setState(() {
      if (enrollResponse.enrollmentId.isEmpty) {
        showErrorWidget = true;
      } else {
        showSuccessWidget = true;
        enrollmentId = enrollResponse.enrollmentId;
        enrollmentStatus = enrollResponse.enrollStatus.toString();
      }
    });
  }
}

class _NamespaceWidget extends StatefulWidget {
  final TextEditingController namespaceController = TextEditingController();
  bool? _readCheckedValue = false;
  bool? _writeCheckedValue = false;

  @override
  State<StatefulWidget> createState() => _NamespaceWidgetState();

  String getAccess() {
    if (_writeCheckedValue == true) {
      return "rw";
    } else if (_readCheckedValue == true) {
      return "r";
    } else {
      return "";
    }
  }
}

class _NamespaceWidgetState extends State<_NamespaceWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      SizedBox(
          width: 150,
          child: TextField(
            controller: widget.namespaceController,
            decoration: const InputDecoration(hintText: 'Enter Namespace'),
          )),
      const Spacer(),
      const Text('Access: ', style: TextStyle(fontWeight: FontWeight.bold)),
      Flexible(
          child: Checkbox(
        value: widget._readCheckedValue,
        onChanged: (newValue) {
          setState(() {
            widget._readCheckedValue = newValue;
          });
        },
      )),
      const Text('Read'),
      Flexible(
          child: Checkbox(
        value: widget._writeCheckedValue,
        onChanged: (newValue) {
          setState(() {
            widget._writeCheckedValue = newValue;
          });
        },
      )),
      const Text('Write'),
    ]);
  }
}
