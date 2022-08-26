import 'dart:io';

import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AtOnboardingQRCodeResult {
  final String atSign;
  final String secret;

  AtOnboardingQRCodeResult({
    required this.atSign,
    required this.secret,
  });
}

class AtOnboardingQRCodeScreen extends StatefulWidget {
  const AtOnboardingQRCodeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AtOnboardingQRCodeScreen> createState() =>
      _AtOnboardingQRCodeScreenState();
}

class _AtOnboardingQRCodeScreenState extends State<AtOnboardingQRCodeScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  bool isDetecting = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Scan your QR!',
            style: TextStyle(
              color: Platform.isIOS || Platform.isAndroid
                  ? Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white
                  : null,
            ),
          ),
          actions: const [
            Center(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: AtSyncIndicator(color: Colors.white),
            )),
          ],
        ),
        body: _buildQrView(context),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      onScannedData(scanData.code);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onScannedData(String? qrCode) async {
    if (isDetecting) {
      return;
    }
    isDetecting = true;
    if ((qrCode ?? '').isNotEmpty) {
      List<String> values = (qrCode ?? '').split(':');
      if (values.length == 2) {
        controller?.pauseCamera();
        //It's issue from camera library so we need to add a delay to waiting for pause camera
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        Navigator.pop(
          context,
          AtOnboardingQRCodeResult(atSign: values[0], secret: values[1]),
        );
      } else {
        await controller?.pauseCamera();
        await AtOnboardingDialog.showError(
            context: context, message: 'Invalid QR.');
        await controller?.resumeCamera();
      }
    }
    isDetecting = false;
  }
}
