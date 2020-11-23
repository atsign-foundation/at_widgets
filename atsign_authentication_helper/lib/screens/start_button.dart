import 'dart:async';
import 'package:atsign_authentication_helper/screens/scan_qr.dart';
import 'package:atsign_authentication_helper/widgets/custom_button.dart';
import 'package:atsign_authentication_helper/services/client_sdk_service.dart';
import 'package:atsign_authentication_helper/services/size_config.dart';
import 'package:atsign_authentication_helper/utils/colors.dart';
import 'package:atsign_authentication_helper/utils/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class StartButton extends StatefulWidget {
  final Widget nextScreen;
  const StartButton({Key key, @required this.nextScreen}) : super(key: key);

  @override
  _StartButtonState createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  bool onboardSuccess = false;
  bool sharingStatus = false;
  ClientSdkService clientSdkService;
  // bool userAcceptance;
  final Permission _cameraPermission = Permission.camera;
  final Permission _storagePermission = Permission.storage;
  Completer c = Completer();
  bool authenticating = false;

  @override
  void initState() {
    super.initState();
    _initClientSdkService();
    _checkToOnboard();
    _checkForPermissionStatus();
  }

  String state;
  void _initClientSdkService() {
    clientSdkService = ClientSdkService.getInstance();
    clientSdkService.setNextScreen = widget.nextScreen;
    SystemChannels.lifecycle.setMessageHandler((msg) {
      state = msg;
      debugPrint('SystemChannels> $msg');
      clientSdkService.app_lifecycle_state = msg;
      if (clientSdkService.monitorConnection != null &&
          clientSdkService.monitorConnection.isInValid()) {
        clientSdkService.startMonitor();
      }
    });
  }

  void _checkToOnboard() async {
    // onboard call to get the already setup atsigns
    await clientSdkService.onboard().then((isChecked) async {
      if (!isChecked) {
        c.complete(true);
        print("onboard returned: $isChecked");
      } else {
        await clientSdkService.startMonitor();
        onboardSuccess = true;
        c.complete(true);
      }
    }).catchError((error) async {
      c.complete(true);
      print("Error in authenticating: $error");
    });
  }

  void _checkForPermissionStatus() async {
    final existingCameraStatus = await _cameraPermission.status;
    if (existingCameraStatus != PermissionStatus.granted) {
      await _cameraPermission.request();
    }
    final existingStorageStatus = await _storagePermission.status;
    if (existingStorageStatus != PermissionStatus.granted) {
      await _storagePermission.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          width: 140,
          height: 40,
          child: CustomButton(
            buttonText: TextStrings().buttonStart,
            onPressed: () async {
              this.setState(() {
                authenticating = true;
              });
              await c.future;
              if (onboardSuccess) {
                await Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => widget.nextScreen));
              } else {
                await Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ScanQrScreen()));
              }
            },
          ),
        ),
        authenticating
            ? Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ColorConstants.redText)),
              )
            : SizedBox()
      ],
    );
  }
}
