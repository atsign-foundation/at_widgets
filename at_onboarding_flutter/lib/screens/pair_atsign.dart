import 'dart:convert';

import 'dart:async';

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/screens/atsign_list_screen.dart';
import 'package:at_onboarding_flutter/screens/private_key_qrcode_generator.dart';
import 'package:at_onboarding_flutter/screens/web_view_screen.dart';
import 'package:at_onboarding_flutter/services/free_atsign_service.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/custom_appbar.dart';
import 'package:at_onboarding_flutter/widgets/custom_button.dart';
import 'package:at_onboarding_flutter/widgets/custom_dialog.dart';
import 'package:at_onboarding_flutter/widgets/custom_strings.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:at_utils/at_logger.dart';

class PairAtsignWidget extends StatefulWidget {
  final OnboardingStatus? onboardStatus;
  final bool getAtSign;
  PairAtsignWidget({Key? key, this.onboardStatus, this.getAtSign = false}) : super(key: key);
  @override
  _PairAtsignWidgetState createState() => _PairAtsignWidgetState();
}

class _PairAtsignWidgetState extends State<PairAtsignWidget> {
  final OnboardingService _onboardingService = OnboardingService.getInstance();
  final AtSignLogger _logger = AtSignLogger('QR Scan');
  final FreeAtsignService _freeAtsignService = FreeAtsignService();

  late QrReaderViewController _controller;
  bool loading = false;
  bool _isQR = false;
  bool _isBackup = false;
  AtSignStatus? _atsignStatus;

  bool _isServerCheck = false;
  bool _isContinue = true;
  String? _pairingAtsign;
  String? _loadingMessage;
  bool isValidated = false;
  bool permissionGrated = false;
  bool scanCompleted = false;
  bool scanQR = false;
  final String _incorrectKeyFile = 'Unable to fetch the keys from chosen file. Please choose correct file';
  final String _failedFileProcessing = 'Failed in processing files. Please try again';
  @override
  void initState() {
    checkPermissions();
    if (widget.getAtSign == true) {
      _getAtsignForm();
    }
    if (widget.onboardStatus != null) {
      if (widget.onboardStatus == OnboardingStatus.ACTIVATE) {
        _isQR = true;
        loading = true;
        _getLoginWithAtsignDialog(context);
      }
      if (widget.onboardStatus == OnboardingStatus.RESTORE) {
        _isBackup = true;
      }
    }
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool _isCram(String? data) {
    if (data == null || data == '' || !data.contains('@')) {
      return false;
    }
    return true;
  }

  Future<dynamic> _processSharedSecret(String atsign, String secret, {bool isScanner = false}) async {
    dynamic authResponse;
    try {
      setState(() {
        loading = true;
      });
      bool isExist = await (_onboardingService.isExistingAtsign(atsign) as FutureOr<bool>);
      if (isExist) {
        setState(() {
          loading = false;
        });
        await _showAlertDialog(CustomStrings().pairedAtsign(atsign));
        return;
      }
      authResponse = await _onboardingService.authenticate(atsign, cramSecret: secret, status: widget.onboardStatus);
      if (authResponse == ResponseStatus.AUTH_SUCCESS) {
        if (widget.onboardStatus == OnboardingStatus.ACTIVATE || widget.onboardStatus == OnboardingStatus.RESTORE) {
          _onboardingService.onboardFunc(_onboardingService.atClientServiceMap, _onboardingService.currentAtsign);
          if (_onboardingService.nextScreen == null) {
            if (isScanner) Navigator.pop(context);
            Navigator.pop(context);
            return;
          }
          if (isScanner) Navigator.pop(context);
          await Navigator.pushReplacement(context,
              MaterialPageRoute<OnboardingService>(builder: (BuildContext context) => _onboardingService.nextScreen!));
        } else {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute<PrivateKeyQRCodeGenScreen>(
                builder: (BuildContext context) => PrivateKeyQRCodeGenScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (e == ResponseStatus.AUTH_FAILED) {
        _logger.severe('Error in authenticateWith cram secret');
        await _showAlertDialog(e, title: 'Auth Failed');
      } else if (e == ResponseStatus.SERVER_NOT_REACHED && _isContinue) {
        _isServerCheck = _isContinue;
        await _processSharedSecret(atsign, secret);
      } else if (e == ResponseStatus.TIME_OUT) {
        await _showAlertDialog(e, title: 'Response Time out');
      }
    }
    return authResponse;
  }

  Future<void> onScan(String data, List<Offset> offsets, BuildContext context) async {
    _isServerCheck = false;
    _isContinue = true;
    await _controller.stopCamera();
    dynamic message;
    if (_isCram(data)) {
      List<String> params = data.split(':');
      if (params[1].length < 128) {
        await _showAlertDialog(CustomStrings().invalidCram(params[0]));
      } else if (OnboardingService.getInstance().formatAtSign(params[0]) != _pairingAtsign && _pairingAtsign != null) {
        await _showAlertDialog(CustomStrings().atsignMismatch(_pairingAtsign));
      } else if (params[1].length == 128) {
        message = await _processSharedSecret(params[0], params[1]);
      } else {
        await _showAlertDialog(CustomStrings().invalidData);
      }
    } else {
      await _showAlertDialog(CustomStrings().invalidData);
    }
    setState(() {
      loading = false;
    });
    if (message != ResponseStatus.AUTH_SUCCESS) {
      scanCompleted = false;
      await _controller.startCamera((String data, List<Offset> offsets) {
        if (!scanCompleted) {
          onScan(data, offsets, context);
          scanCompleted = true;
        }
      });
    }
  }

  Future<void> checkPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.status;
    PermissionStatus storageStatus = await Permission.storage.status;
    _logger.info('camera status => $cameraStatus');
    _logger.info('storage status is $storageStatus');
    if (cameraStatus.isRestricted && storageStatus.isRestricted) {
      await askPermissions(Permission.unknown);
    } else if (cameraStatus.isRestricted || cameraStatus.isDenied) {
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
    } else {
      await <Permission>[Permission.camera, Permission.storage].request();
    }
    setState(() {
      permissionGrated = true;
    });
  }

  Future<void> _processAESKey(String? atsign, String? aesKey, String contents) async {
    assert(aesKey != null || aesKey != '');
    assert(atsign != null || atsign != '');
    assert(contents != '');
    setState(() {
      loading = true;
    });
    try {
      bool? isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist != null && isExist) {
        setState(() {
          loading = false;
        });
        await _showAlertDialog(CustomStrings().pairedAtsign(atsign));
        return;
      }
      dynamic authResponse = await _onboardingService.authenticate(atsign, jsonData: contents, decryptKey: aesKey);
      if (authResponse == ResponseStatus.AUTH_SUCCESS) {
        if (_onboardingService.nextScreen == null) {
          Navigator.pop(context);
          _onboardingService.onboardFunc(_onboardingService.atClientServiceMap, _onboardingService.currentAtsign);
        } else {
          _onboardingService.onboardFunc(_onboardingService.atClientServiceMap, _onboardingService.currentAtsign);
          await Navigator.pushReplacement(
              context, MaterialPageRoute<Widget>(builder: (BuildContext context) => _onboardingService.nextScreen!));
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (e == ResponseStatus.SERVER_NOT_REACHED && _isContinue) {
        _isServerCheck = _isContinue;
        await _processAESKey(atsign, aesKey, contents);
      } else if (e == ResponseStatus.AUTH_FAILED) {
        _logger.severe('Error in authenticateWithAESKey');
        await _showAlertDialog(e, isPkam: true, title: 'Auth Failed');
      } else if (e == ResponseStatus.TIME_OUT) {
        await _showAlertDialog(e, title: 'Response Time out');
      } else {
        print(e);
      }
    }
  }

  Future<void> _uploadKeyFile() async {
    try {
      if (!permissionGrated) {
        await checkPermissions();
      }
      _isServerCheck = false;
      _isContinue = true;
      String? fileContents, aesKey, atsign;
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);
      setState(() {
        loading = true;
      });
      for (PlatformFile pickedFile in result?.files ?? <PlatformFile>[]) {
        String path = pickedFile.path!;
        File selectedFile = File(path);
        int length = selectedFile.lengthSync();
        if (length < 10) {
          await _showAlertDialog(_incorrectKeyFile);
          return;
        }

        if (pickedFile.extension == 'zip') {
          Uint8List bytes = selectedFile.readAsBytesSync();
          Archive archive = ZipDecoder().decodeBytes(bytes);
          for (ArchiveFile file in archive) {
            if (file.name.contains('atKeys')) {
              fileContents = String.fromCharCodes(file.content);
            } else if (aesKey == null && atsign == null && file.name.contains('_private_key.png')) {
              List<int> bytes = file.content as List<int>;
              String path = (await path_provider.getTemporaryDirectory()).path;
              File file1 = await File(path + 'test').create();
              file1.writeAsBytesSync(bytes);
              String result = await FlutterQrReader.imgScan(file1.path);
              List<String> params = result.replaceAll('"', '').split(':');
              atsign = params[0];
              aesKey = params[1];
              await File(path + 'test').delete();
              //read scan QRcode and extract atsign,aeskey
            }
          }
        } else if (pickedFile.name.contains('atKeys')) {
          fileContents = File(path).readAsStringSync();
        } else if (aesKey == null && atsign == null && pickedFile.name.contains('_private_key.png')) {
//read scan QRcode and extract atsign,aeskey
          String result = await FlutterQrReader.imgScan(path);
          List<String> params = result.split(':');
          atsign = params[0];
          aesKey = params[1];
        } else {
          Uint8List result1 = selectedFile.readAsBytesSync();
          fileContents = String.fromCharCodes(result1);
          bool result = _validatePickedFileContents(fileContents);
          _logger.finer('result after extracting data is......$result');
          if (!result) {
            await _showAlertDialog(_incorrectKeyFile);
            setState(() {
              loading = false;
            });
            return;
          }
        }
      }
      if (aesKey == null && atsign == null && fileContents != null) {
        List<String> keyData = fileContents.split(',"@');
        List<String> params = keyData[1].toString().substring(0, keyData[1].length - 2).split('":"');
        atsign = params[0];
        aesKey = params[1];
      }
      if (fileContents == null || (aesKey == null && atsign == null)) {
        await _showAlertDialog(_incorrectKeyFile);
        setState(() {
          loading = false;
        });
        return;
      } else if (OnboardingService.getInstance().formatAtSign(atsign) != _pairingAtsign && _pairingAtsign != null) {
        await _showAlertDialog(CustomStrings().atsignMismatch(_pairingAtsign));
        setState(() {
          loading = false;
        });
        return;
      }
      await _processAESKey(atsign, aesKey, fileContents);
      setState(() {
        loading = false;
      });
    } catch (error) {
      setState(() {
        loading = false;
      });
      _logger.severe('Uploading backup zip file throws $error');
      await _showAlertDialog(_failedFileProcessing);
    }
  }

  Future<CustomDialog?> _showAlertDialog(
    dynamic errorMessage, {
    bool? isPkam,
    String? title,
    bool? getClose,
    Function? onClose,
  }) async {
    await showDialog<CustomDialog>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(context,
              isErrorDialog: true,
              showClose: true,
              message: errorMessage,
              title: title,
              onClose: getClose == true ? onClose : () {});
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // QR Scanner
    if (scanQR) {
      return Scaffold(
        backgroundColor: ColorConstants.light,
        appBar: CustomAppBar(
          showBackButton: true,
          title: Strings.pairAtsignTitle,
        ),
        body: QrReaderView(
          width: 300.0,
          height: 300.0,
          callback: (QrReaderViewController controller) {
            _controller = controller;
            _controller.startCamera((String data, List<Offset> offsets) {
              onScan(data, offsets, context);
            });
          },
        ),
      );
    }
    return Scaffold(
        backgroundColor: ColorConstants.light,
        appBar: CustomAppBar(
          showBackButton: true,
          title: Strings.pairAtsignTitle,
          actionItems: <Widget>[
            IconButton(
                icon: Icon(Icons.help, size: 16.toFont),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                          builder: (BuildContext context) => WebViewScreen(
                                title: Strings.faqTitle,
                                url: Strings.faqUrl,
                              )));
                }),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 25.toHeight, horizontal: 24.toHeight),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // if (_isQR) ..._getLoginWithAtsignDialog(context),
                    if (_isBackup) ...<Widget>[
                      SizedBox(
                        height: SizeConfig().screenHeight * 0.25,
                      ),
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(style: CustomTextStyles.fontR16primary, children: <InlineSpan>[
                            TextSpan(text: _pairingAtsign ?? ', ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: Strings.backupKeyDescription)
                          ])),
                      SizedBox(
                        height: 25.toHeight,
                      ),
                      Center(
                        child: CustomButton(
                          width: 230.toWidth,
                          buttonText: Strings.uploadZipTitle,
                          onPressed: _uploadKeyFile,
                        ),
                      ),
                      SizedBox(
                        height: 25.toHeight,
                      ),
                    ]
                  ],
                ),
                loading
                    ? _isServerCheck
                        ? Padding(
                            padding: EdgeInsets.only(top: SizeConfig().screenHeight * 0.30),
                            child: Center(
                              child: Container(
                                color: ColorConstants.light,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0.toFont),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Center(
                                            child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.appColor)),
                                          ),
                                          SizedBox(width: 6.toWidth),
                                          Flexible(
                                            flex: 7,
                                            child: Text(Strings.recurr_server_check,
                                                textAlign: TextAlign.start, style: CustomTextStyles.fontR16primary),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: CustomButton(
                                          isInverted: true,
                                          height: 35.0.toHeight,
                                          width: 65.toWidth,
                                          buttonText: Strings.stopButtonTitle,
                                          onPressed: () {
                                            _isContinue = false;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: SizeConfig().screenHeight * 0.6,
                            width: SizeConfig().screenWidth,
                            child: Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.appColor)),
                              SizedBox(height: 20.toHeight),
                              if (_loadingMessage != null)
                                Text(
                                  _loadingMessage!,
                                  style: TextStyle(fontSize: 15.toFont, fontWeight: FontWeight.w500),
                                )
                            ])),
                          )
                    : const SizedBox()
              ],
            ),
          ),
        ));
  }

  void _getLoginWithAtsignDialog(BuildContext context) {
    loginWithAtsignAfterReset(context);
  }

  bool _validatePickedFileContents(String fileContents) {
    bool result = fileContents.contains(BackupKeyConstants.PKAM_PRIVATE_KEY_FROM_KEY_FILE) &&
        fileContents.contains(BackupKeyConstants.PKAM_PUBLIC_KEY_FROM_KEY_FILE) &&
        fileContents.contains(BackupKeyConstants.ENCRYPTION_PRIVATE_KEY_FROM_FILE) &&
        fileContents.contains(BackupKeyConstants.ENCRYPTION_PUBLIC_KEY_FROM_FILE) &&
        fileContents.contains(BackupKeyConstants.SELF_ENCRYPTION_KEY_FROM_FILE);
    return result;
  }

  void _getAtsignForm() {
    loading = true;
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
          onWillPop: () async {
            int ct = 0;
            Navigator.of(context).popUntil((_) => ct++ >= 2);
            return true;
          },
          child: CustomDialog(
            context,
            isAtsignForm: true,
            onLimitExceed: (List<String> atsignsList, String message) {
              Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (_) => AtsignListScreen(
                            atsigns: atsignsList,
                            message: message,
                          ))).then((dynamic value) async {
                print('value is $value');
                value == null ? _getAtsignForm() : await _onAtSignSubmit(value);
              });
            },
            onValidate: (String atsign, String secret, bool isScanner) async {
              _loadingMessage = Strings.loadingAtsignReady;
              setState(() {});
              await _processSharedSecret(atsign, secret, isScanner: isScanner);
            },
            onSubmit: (String atsign) async {
              await _onAtSignSubmit(atsign);
            },
          ),
        ),
      );
    });
  }

  Future<void> _onAtSignSubmit(String atsign) async {
    setState(() {
      _loadingMessage = Strings.loadingAtsignStatus;
    });
    bool? isExist = await OnboardingService.getInstance().isExistingAtsign(atsign).catchError((dynamic error) async {
      await _showAlertDialog(error);
    });
    AtSignStatus? atsignStatus = await OnboardingService.getInstance().checkAtsignStatus(atsign: atsign);
    _pairingAtsign = OnboardingService.getInstance().formatAtSign(atsign);
    _atsignStatus = atsignStatus ?? AtSignStatus.error;
    switch (_atsignStatus) {
      case AtSignStatus.teapot:
        if (isExist!) {
          await _showAlertDialog(CustomStrings().pairedAtsign(atsign), getClose: true, onClose: _getAtsignForm);
          break;
        }
        _isQR = true;
        if (_isQR) {
          await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => WillPopScope(
                  onWillPop: () async {
                    int ct = 0;
                    Navigator.of(context).popUntil((_) => ct++ >= 2);
                    return true;
                  },
                  child: CustomDialog(
                    context,
                    onValidate: (String atsign, String secret, bool isScanner) async {
                      _loadingMessage = Strings.loadingAtsignReady;
                      setState(() {});
                      await _processSharedSecret(atsign, secret, isScanner: isScanner);
                    },
                    isAtsignForm: true,
                    isQR: true,
                    atsign: atsign,
                  )));
        }

        break;
      case AtSignStatus.activated:
        if (isExist!) {
          await _showAlertDialog(CustomStrings().pairedAtsign(atsign), getClose: true, onClose: _getAtsignForm);
          break;
        }
        _isBackup = true;
        break;
      case AtSignStatus.unavailable:
      case AtSignStatus.notFound:
        await _showAlertDialog(Strings.atsignNotFound, getClose: true, onClose: _getAtsignForm);
        break;
      case AtSignStatus.error:
        await _showAlertDialog(Strings.atsignNull, getClose: true, onClose: _getAtsignForm);
        break;
      default:
        break;
    }
    if (_isQR) {
      await loginWithAtsign(atsign, context);
    }
    setState(() {
      loading = false;
      _loadingMessage = null;
    });
  }

  //It will validate the person with atsign, email and the OTP.
  //If the validation is successful, it will return a cram secret for the user to login
  Future<bool> loginWithAtsignAfterReset(BuildContext context) async {
    String? atsign = _onboardingService.currentAtsign;
    atsign ??= await _onboardingService.getAtSign();
    if (atsign != null) {
      atsign = atsign.split('@').last;
    }
    dynamic data;
    bool status = false;

    dynamic response = await _freeAtsignService.loginWithAtsign(atsign!);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);

      print(data);
      status = true;
      // atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      await showErrorDialog(context, errorMessage);
    }
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
            onWillPop: () async {
              int ct = 0;
              Navigator.of(context).popUntil((_) => ct++ >= 2);
              return true;
            },
            child: CustomDialog(
              context,
              onValidate: (String atsign, String secret, bool isScanner) async {
                _loadingMessage = Strings.loadingAtsignReady;
                setState(() {});
                await _processSharedSecret(atsign, secret, isScanner: isScanner);
              },
              isAtsignForm: true,
              isQR: true,
              atsign: atsign!,
            )));
    return status;
  }

  //It will validate the person with atsign, email and the OTP.
  //If the validation is successful, it will return a cram secret for the user to login
  Future<bool> loginWithAtsign(String atsign, BuildContext context) async {
    dynamic data;
    bool status = false;

    dynamic response = await _freeAtsignService.loginWithAtsign(atsign);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);

      print(data);
      status = true;
      // atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      await showErrorDialog(context, errorMessage);
    }
    return status;
  }

  Future<CustomDialog?> showErrorDialog(BuildContext context, String errorMessage) async {
    return showDialog<CustomDialog>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            context,
            isErrorDialog: true,
            showClose: true,
            message: errorMessage,
            onClose: () {},
          );
        });
  }
}
