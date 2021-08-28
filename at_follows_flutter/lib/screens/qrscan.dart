import 'package:at_follows_flutter/domain/connection_model.dart';
import 'package:at_follows_flutter/services/connections_service.dart';
import 'package:at_follows_flutter/services/sdk_service.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:at_follows_flutter/widgets/custom_appbar.dart';
import 'package:at_follows_flutter/widgets/custom_button.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_follows_flutter/services/size_config.dart';

class QrScan extends StatefulWidget {
  @override
  _QrScanState createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  final AtSignLogger _logger = AtSignLogger('Connections QR Scan');
  bool permissionGrated = false;
  bool loading = false;
  bool _scanCompleted = false;
  QrReaderViewController? _controller;
  bool _isScan = false;

  @override
  void initState() {
    checkPermissions();
    super.initState();
  }

  Future<void> checkPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus storageStatus = await Permission.storage.status;
    _logger.info('camera status => $cameraStatus');
    _logger.info('storage status is $storageStatus');

    if (cameraStatus.isRestricted || cameraStatus.isDenied) {
      await askPermissions(Permission.camera);
    } else if (storageStatus.isRestricted || storageStatus.isDenied) {
      await askPermissions(Permission.storage);
    } else if (cameraStatus.isGranted && storageStatus.isGranted) {
      setState(() {
        permissionGrated = true;
      });
    }
  }

  Future<void> askPermissions(Permission type) async {
    if (type == Permission.camera) {
      await Permission.camera.request();
    } else if (type == Permission.storage) {
      await Permission.storage.request();
    }
  }

  Future<bool> _validateFollowingAtsign(String? atsign, [bool isScan = false]) async {
    if (ConnectionProvider().containsFollowing(atsign)) {
      await _showFollowersAlertDialog(context, atsign, isScan: isScan);
      return false;
    } else if (atsign == SDKService().atsign) {
      await _showFollowersAlertDialog(context, atsign, message: Strings.ownAtsign, isScan: isScan);
      return false;
    } else if (atsign == Strings.invalidAtsign) {
      await _showFollowersAlertDialog(context, atsign, message: Strings.invalidAtsignMessage, isScan: isScan);
      return false;
    }
    AtSignStatus? atSignStatus = await SDKService().checkAtSignStatus(atsign!);
    if (atSignStatus == AtSignStatus.teapot || atSignStatus == AtSignStatus.activated) {
      return true;
    } else {
      await _showFollowersAlertDialog(context, atsign,
          message: Strings.getAtSignStatusMessage(atSignStatus), isScan: isScan);
      return false;
    }
  }

  Future<void> onScan(String data, List<Offset> offsets, BuildContext context) async {
    // _controller.stopCamera();
    setState(() {
      loading = true;
    });
    _logger.info('received data is $data');
    if (data != '') {
      String? formattedAtsign = ConnectionsService().formatAtSign(data);
      bool result = await _validateFollowingAtsign(formattedAtsign, true);

      if (result) {
        Navigator.pop(context);
        await ConnectionProvider().follow(formattedAtsign);
      }
    } else {
      _logger.severe('Scanning the QRcode throws error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstants.backgroundColor,
        appBar: CustomAppBar(
          showTitle: true,
          title: SDKService().atsign,
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                  SwitchListTile(
                    title: Text(
                      Strings.qrscanDescription,
                      style: CustomTextStyles.fontR16primary,
                      textAlign: TextAlign.center,
                    ),
                    value: _isScan,
                    onChanged: (bool value) {
                      setState(() {
                        _isScan = value;
                      });
                    },
                    inactiveTrackColor: ColorConstants.inactiveTrackColor,
                    inactiveThumbColor: ColorConstants.inactiveThumbColor,
                    activeTrackColor: ColorConstants.activeTrackColor,
                    activeColor: ColorConstants.activeColor,
                  ),
                  SizedBox(height: 20.toHeight),
                  Center(
                    child: Builder(
                      builder: (BuildContext context) => Container(
                        alignment: Alignment.center,
                        width: 300.toWidth,
                        height: 350.toHeight,
                        color: Colors.black,
                        child: !permissionGrated || !_isScan
                            ? const SizedBox()
                            : Stack(
                                children: <Widget>[
                                  QrReaderView(
                                    width: 300.toWidth,
                                    height: 350.toHeight,
                                    callback: (QrReaderViewController container) async {
                                      _controller = container;
                                      await _controller!.startCamera((String data, List<Offset> offsets) async {
                                        if (!_scanCompleted) {
                                          await _controller?.stopCamera();
                                          _scanCompleted = true;

                                          await onScan(data, offsets, context);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.toHeight),
                  Text(
                    'OR',
                    style: CustomTextStyles.fontR14primary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.toHeight),
                  CustomButton(
                      height: 40.toHeight,
                      isActive: true,
                      onPressedCallBack: (bool value) {
                        _getAtsignForm(context);
                      },
                      text: Strings.enterAtsignButton),
                  SizedBox(height: 20.toHeight),
                ],
              ),
              loading
                  ? SizedBox(
                      height: SizeConfig().screenHeight * 0.6,
                      width: SizeConfig().screenWidth,
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color?>(ColorConstants.buttonHighLightColor)),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ));
  }

  Future<AlertDialog?> _getAtsignForm(BuildContext context) async {
    TextEditingController _atsignController = TextEditingController();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    await showDialog<AlertDialog>(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Text(
                Strings.enterAtsignTitle,
                style: CustomTextStyles.fontR16primary,
              ),
              content: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: TextFormField(
                  validator: (String? value) {
                    if (value == null || value == '') {
                      return '@sign cannot be empty';
                    }
                    return null;
                  },
                  controller: _atsignController,
                  decoration: InputDecoration(
                      hintText: Strings.atsignHintText,
                      prefixText: '@',
                      border: OutlineInputBorder(borderSide: BorderSide(color: ColorConstants.buttonHighLightColor!))),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      String? formattedAtsign = ConnectionsService().formatAtSign(_atsignController.text);

                      Navigator.pop(_);
                      bool result = await _validateFollowingAtsign(formattedAtsign);

                      if (!result) {
                        setState(() {
                          loading = false;
                        });
                        return;
                      } else {
                        Navigator.pop(context, true);
                        await ConnectionProvider().follow(formattedAtsign);
                      }
                    }
                  },
                  child: Text(
                    Strings.submitButton,
                    style: TextStyle(color: ColorConstants.buttonHighLightColor, fontSize: 14.toFont),
                  ),
                ),
              ]);
        });
  }

  Future<AlertDialog?> _showFollowersAlertDialog(BuildContext context, String? atsign,
      {String? message, bool isScan = false}) async {
    await showDialog<AlertDialog>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(message ?? '${Strings.existingFollower}$atsign', style: CustomTextStyles.fontR14dark),
            actions: <Widget>[
              TextButton(
                child: const Text(Strings.close),
                onPressed: () {
                  Navigator.pop(context);
                  if (isScan) {
                    _controller!.startCamera((String data1, List<Offset> offsets1) {
                      if (!_scanCompleted) {
                        onScan(data1, offsets1, context);
                        _scanCompleted = true;
                      }
                    });
                    setState(() {
                      loading = false;
                      _scanCompleted = false;
                    });
                  }
                },
              )
            ],
          );
        });
  }
}
