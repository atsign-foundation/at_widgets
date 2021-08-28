import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerWidget extends StatefulWidget {
  QrScannerWidget({Key? key}) : super(key: key);

  @override
  _QrScannerWidgetState createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  QrReaderViewController? _controller;
  bool loading = false;
  bool cameraPermissionGranted = false;
  bool scanCompleted = false;
  OnboardingService onboardingService = OnboardingService.getInstance();

  @override
  void initState() {
    _verifyCameraPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        )
      ],
      content: QrReaderView(
        width: 300.0,
        height: 300.0,
        callback: (QrReaderViewController controller) {
          _controller = controller;
          _controller!.startCamera((String data, List<Offset> offsets) {
            onScan(data, offsets, context);
          });
        },
      ),
    );
  }

  Future<bool> _verifyCameraPermissions() async {
    PermissionStatus status = await Permission.camera.status;
    print('camera status => $status');
    if (status.isGranted) {
      return true;
    }
    return (await <Permission>[Permission.camera].request())[0] == PermissionStatus.granted;
  }

  Future<bool> onScan(String data, List<Offset> offsets, BuildContext context) async {
    late Future<bool> result;

    await _controller!.stopCamera();
    dynamic authenticateMessage = await onboardingService.authenticate(data);
    if (authenticateMessage == ResponseStatus.AUTH_SUCCESS) {
      return true;
    }

    // try again
    await _controller!.startCamera((String data, List<Offset> offsets) {
      result = onScan(data, offsets, context);
    });

    return result;
  }
}
