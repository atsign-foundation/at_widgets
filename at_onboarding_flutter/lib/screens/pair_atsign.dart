import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/screens/atsign_list_screen.dart';
import 'package:at_onboarding_flutter/screens/private_key_qrcode_generator.dart';
import 'package:at_onboarding_flutter/screens/web_view_screen.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
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
  final OnboardingStatus onboardStatus;
  final bool getAtSign;
  PairAtsignWidget({Key key, this.onboardStatus, this.getAtSign = false})
      : super(key: key);
  @override
  _PairAtsignWidgetState createState() => _PairAtsignWidgetState();
}

class _PairAtsignWidgetState extends State<PairAtsignWidget> {
  var _onboardingService = OnboardingService.getInstance();
  AtSignLogger _logger = AtSignLogger('QR Scan');

  QrReaderViewController _controller;
  bool loading = false;
  bool _isQR = false;
  bool _isBackup = false;
  AtSignStatus _atsignStatus;

  bool _isServerCheck = false;
  bool _isContinue = true;
  String _pairingAtsign;
  String _loadingMessage;
  bool isValidated = false;
  bool permissionGrated = false;
  bool scanCompleted = false;
  String _incorrectKeyFile =
      'Unable to fetch the keys from chosen file. Please choose correct file';
  String _failedFileProcessing = 'Failed in processing files. Please try again';
  @override
  void initState() {
    checkPermissions();
    if (widget.getAtSign == true) {
      _getAtsignForm();
    }
    if (widget.onboardStatus != null) {
      if (widget.onboardStatus == OnboardingStatus.ACTIVATE) {
        _isQR = true;
      }
      if (widget.onboardStatus == OnboardingStatus.RESTORE) {
        _isBackup = true;
      }
    }
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool _isCram(String data) {
    if (data == null || data == '' || !data.contains('@')) {
      return false;
    }
    return true;
  }

  _processSharedSecret(String atsign, String secret) async {
    var authResponse;
    try {
      setState(() {
        loading = true;
      });
      var isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist) {
        setState(() {
          loading = false;
        });
        _showAlertDialog(CustomStrings().pairedAtsign(atsign));
        return;
      }
      authResponse = await _onboardingService.authenticate(atsign,
          cramSecret: secret, status: widget.onboardStatus);
      if (authResponse == ResponseStatus.AUTH_SUCCESS) {
        if (widget.onboardStatus == OnboardingStatus.ACTIVATE ||
            widget.onboardStatus == OnboardingStatus.RESTORE) {
          _onboardingService.onboardFunc(_onboardingService.atClientServiceMap,
              _onboardingService.currentAtsign);
          if (_onboardingService.nextScreen == null) {
            Navigator.pop(context);
            return;
          }
          await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => _onboardingService.nextScreen));
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PrivateKeyQRCodeGenScreen()),
          );
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (e == ResponseStatus.AUTH_FAILED) {
        _logger.severe('Error in authenticateWith cram secret');
        _showAlertDialog(e, title: 'Auth Failed');
      } else if (e == ResponseStatus.SERVER_NOT_REACHED && _isContinue) {
        _isServerCheck = _isContinue;
        await _processSharedSecret(atsign, secret);
      } else if (e == ResponseStatus.TIME_OUT) {
        _showAlertDialog(e, title: 'Response Time out');
      }
    }
    return authResponse;
  }

  void onScan(String data, List<Offset> offsets, context) async {
    _isServerCheck = false;
    _isContinue = true;
    _controller.stopCamera();
    var message;
    if (_isCram(data)) {
      List params = data.split(':');
      if (params[1].length < 128) {
        _showAlertDialog(CustomStrings().invalidCram(params[0]));
      } else if (OnboardingService.getInstance().formatAtSign(params[0]) !=
              _pairingAtsign &&
          _pairingAtsign != null) {
        _showAlertDialog(CustomStrings().atsignMismatch(_pairingAtsign));
      } else if (params[1].length == 128) {
        message = await this._processSharedSecret(params[0], params[1]);
      } else {
        _showAlertDialog(CustomStrings().invalidData);
      }
    } else {
      _showAlertDialog(CustomStrings().invalidData);
    }
    this.setState(() {
      loading = false;
    });
    if (message != ResponseStatus.AUTH_SUCCESS) {
      scanCompleted = false;
      await _controller.startCamera((data, offsets) {
        if (!scanCompleted) {
          onScan(data, offsets, context);
          scanCompleted = true;
        }
      });
    }
  }

  checkPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status;
    _logger.info("camera status => $cameraStatus");
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

  askPermissions(Permission type) async {
    if (type == Permission.camera) {
      await Permission.camera.request();
    } else if (type == Permission.storage) {
      await Permission.storage.request();
    } else {
      await [Permission.camera, Permission.storage].request();
    }
    setState(() {
      permissionGrated = true;
    });
  }

  void _uploadCramKeyFile() async {
    try {
      if (!permissionGrated) {
        await checkPermissions();
      }
      _isServerCheck = false;
      _isContinue = true;
      String cramKey;
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: false);
      setState(() {
        loading = true;
      });
      for (var file in result.files) {
        if (cramKey == null) {
          String result = await FlutterQrReader.imgScan(file.path);
          if (result.contains('@')) {
            cramKey = result;
            break;
          } //read scan QRcode and extract atsign,aeskey
        }
      }
      if (_isCram(cramKey)) {
        List params = cramKey.split(':');
        if (params[1].length < 128) {
          _showAlertDialog(CustomStrings().invalidCram(params[0]));
        } else if (OnboardingService.getInstance().formatAtSign(params[0]) !=
                _pairingAtsign &&
            _pairingAtsign != null) {
          _showAlertDialog(CustomStrings().atsignMismatch(_pairingAtsign));
        } else if (params[1].length == 128) {
          await this._processSharedSecret(params[0], params[1]);
        } else {
          _showAlertDialog(CustomStrings().invalidData);
        }
      } else {
        _showAlertDialog(CustomStrings().invalidData);
      }
      setState(() {
        loading = false;
      });
    } catch (error) {
      _logger.severe('Uploading activation qr code throws $error');
      setState(() {
        loading = false;
      });
      _showAlertDialog(error);
    }
  }

  _processAESKey(String atsign, String aesKey, String contents) async {
    assert(aesKey != null || aesKey != '');
    assert(atsign != null || atsign != '');
    assert(contents != null || contents != '');
    setState(() {
      loading = true;
    });
    try {
      var isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist) {
        setState(() {
          loading = false;
        });
        _showAlertDialog(CustomStrings().pairedAtsign(atsign));
        return;
      }
      var authResponse = await _onboardingService.authenticate(atsign,
          jsonData: contents, decryptKey: aesKey);
      if (authResponse == ResponseStatus.AUTH_SUCCESS) {
        if (_onboardingService.nextScreen == null) {
          Navigator.pop(context);
          _onboardingService.onboardFunc(_onboardingService.atClientServiceMap,
              _onboardingService.currentAtsign);
        } else {
          _onboardingService.onboardFunc(_onboardingService.atClientServiceMap,
              _onboardingService.currentAtsign);
          await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => _onboardingService.nextScreen));
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
        _showAlertDialog(e, isPkam: true, title: 'Auth Failed');
      } else if (e == ResponseStatus.TIME_OUT) {
        _showAlertDialog(e, title: 'Response Time out');
      }
    }
  }

  void _uploadKeyFile() async {
    try {
      if (!permissionGrated) {
        await checkPermissions();
      }
      _isServerCheck = false;
      _isContinue = true;
      var fileContents, aesKey, atsign;
      FilePickerResult result = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);
      setState(() {
        loading = true;
      });
      for (var pickedFile in result.files) {
        var path = pickedFile.path;
        File selectedFile = File(path);
        var length = selectedFile.lengthSync();
        if (length < 10) {
          _showAlertDialog(_incorrectKeyFile);
          return;
        }

        if (pickedFile.extension == 'zip') {
          var bytes = selectedFile.readAsBytesSync();
          final archive = ZipDecoder().decodeBytes(bytes);
          for (var file in archive) {
            if (file.name.contains('atKeys')) {
              fileContents = String.fromCharCodes(file.content);
            } else if (aesKey == null &&
                atsign == null &&
                file.name.contains('_private_key.png')) {
              var bytes = file.content as List<int>;
              var path = (await path_provider.getTemporaryDirectory()).path;
              var file1 = await File('$path' + 'test').create();
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
        } else if (aesKey == null &&
            atsign == null &&
            pickedFile.name.contains('_private_key.png')) {
//read scan QRcode and extract atsign,aeskey
          String result = await FlutterQrReader.imgScan(path);
          List<String> params = result.split(':');
          atsign = params[0];
          aesKey = params[1];
        } else {
          var result1 = selectedFile.readAsBytesSync();
          fileContents = String.fromCharCodes(result1);
          var result = _validatePickedFileContents(fileContents);
          _logger.finer('result after extracting data is......$result');
          if (!result) {
            _showAlertDialog(_incorrectKeyFile);
            setState(() {
              loading = false;
            });
            return;
          }
        }
      }
      if (aesKey == null && atsign == null && fileContents != null) {
        var keyData = fileContents.split(',"@');
        List<String> params = keyData[1]
            .toString()
            .substring(0, keyData[1].length - 2)
            .split('":"');
        atsign = params[0];
        aesKey = params[1];
      }
      if (fileContents == null || (aesKey == null && atsign == null)) {
        _showAlertDialog(_incorrectKeyFile);
        setState(() {
          loading = false;
        });
        return;
      } else if (OnboardingService.getInstance().formatAtSign(atsign) !=
              _pairingAtsign &&
          _pairingAtsign != null) {
        _showAlertDialog(CustomStrings().atsignMismatch(_pairingAtsign));
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
      _showAlertDialog(_failedFileProcessing);
    }
  }

  _showAlertDialog(var errorMessage,
      {bool isPkam, String title, bool getClose, Function onClose}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              isErrorDialog: true,
              showClose: true,
              context: context,
              message: errorMessage,
              title: title,
              onClose: getClose == true ? onClose : () {});
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
        backgroundColor: ColorConstants.light,
        appBar: CustomAppBar(
          showBackButton: true,
          title: Strings.pairAtsignTitle,
          actionItems: [
            IconButton(
                icon: Icon(Icons.help, size: 16.toFont),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                                title: Strings.faqTitle,
                                url: Strings.faqUrl,
                              )));
                })
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: 25.toHeight, horizontal: 24.toHeight),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isQR) ..._getQRWidget(deviceTextFactor),
                    if (_isBackup) ...[
                      SizedBox(
                        height: SizeConfig().screenHeight * 0.25,
                      ),
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              style: CustomTextStyles.fontR16primary,
                              children: [
                                TextSpan(
                                    text: _pairingAtsign + ', ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: Strings.backupKeyDescription)
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
                            padding: EdgeInsets.only(
                                top: SizeConfig().screenHeight * 0.30),
                            child: Center(
                              child: Container(
                                color: ColorConstants.light,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0.toFont),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Center(
                                            child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        ColorConstants
                                                            .appColor)),
                                          ),
                                          SizedBox(width: 6.toWidth),
                                          Flexible(
                                            flex: 7,
                                            child: Text(
                                                Strings.recurr_server_check,
                                                textAlign: TextAlign.start,
                                                style: CustomTextStyles
                                                    .fontR16primary),
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
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          ColorConstants.appColor)),
                                  SizedBox(height: 20.toHeight),
                                  if (_loadingMessage != null)
                                    Text(
                                      _loadingMessage,
                                      style: TextStyle(
                                          fontSize: 15.toFont,
                                          fontWeight: FontWeight.w500),
                                    )
                                  // isValidated
                                  //     ? Text(
                                  //         'Getting your @sign ready. Please wait...',
                                  //         style: TextStyle(
                                  //             fontSize: 15.toFont,
                                  //             fontWeight: FontWeight.w500),
                                  //       )
                                  //     : Text('')
                                ])),
                          )
                    : SizedBox()
              ],
            ),
          ),
        ));
  }

  _getQRWidget(deviceTextFactor) {
    return <Widget>[
      SizedBox(height: 70.toHeight),
      RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(
                  fontSize: 16, color: ColorConstants.lightBackgroundColor),
              children: [
                TextSpan(text: Strings.scanQrMessage),
                TextSpan(text: AppConstants.website)
              ])),
      SizedBox(
        height: 25.toHeight,
      ),
      Builder(
        builder: (context) => Container(
          alignment: Alignment.center,
          width: 300.toWidth,
          height: 350.toHeight,
          color: Colors.black,
          child: !permissionGrated
              ? SizedBox()
              : Stack(
                  children: [
                    QrReaderView(
                      width: 300.toWidth,
                      height: 350.toHeight,
                      callback: (container) {
                        this._controller = container;
                        _controller.startCamera((data, offsets) {
                          if (!scanCompleted) {
                            onScan(data, offsets, context);
                            scanCompleted = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
        ),
      ),
      SizedBox(
        height: 25.toHeight,
      ),
      Center(child: Text('OR')),
      SizedBox(
        height: 25.toHeight,
      ),
      CustomButton(
        width: 230.toWidth,
        height: 50.toHeight * deviceTextFactor,
        buttonText: Strings.uploadQRTitle,
        onPressed: _uploadCramKeyFile,
      ),
    ];
  }

  bool _validatePickedFileContents(String fileContents) {
    var result = fileContents
            .contains(BackupKeyConstants.PKAM_PRIVATE_KEY_FROM_KEY_FILE) &&
        fileContents
            .contains(BackupKeyConstants.PKAM_PUBLIC_KEY_FROM_KEY_FILE) &&
        fileContents
            .contains(BackupKeyConstants.ENCRYPTION_PRIVATE_KEY_FROM_FILE) &&
        fileContents
            .contains(BackupKeyConstants.ENCRYPTION_PUBLIC_KEY_FROM_FILE) &&
        fileContents.contains(BackupKeyConstants.SELF_ENCRYPTION_KEY_FROM_FILE);
    return result;
  }

  _getAtsignForm() {
    loading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
            isAtsignForm: true,
            onLimitExceed: (atsignsList, message) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AtsignListScreen(
                            atsigns: atsignsList,
                            message: message,
                          ))).then((value) async {
                print('value is $value');
                value == null ? _getAtsignForm() : await _onAtSignSubmit(value);
              });
            },
            onValidate: (atsign, secret) async {
              _loadingMessage = Strings.loadingAtsignReady;
              setState(() {});
              await _processSharedSecret(atsign, secret);
            },
            onSubmit: (atsign) async => await _onAtSignSubmit(atsign),
          ),
        ),
      );
    });
  }

  Future<void> _onAtSignSubmit(String atsign) async {
    setState(() {
      _loadingMessage = Strings.loadingAtsignStatus;
    });
    var isExist = await OnboardingService.getInstance()
        .isExistingAtsign(atsign)
        .catchError((error) {
      _showAlertDialog(error);
    });
    var atsignStatus =
        await OnboardingService.getInstance().checkAtsignStatus(atsign: atsign);
    _pairingAtsign = OnboardingService.getInstance().formatAtSign(atsign);
    _atsignStatus = atsignStatus ?? AtSignStatus.error;
    switch (_atsignStatus) {
      case AtSignStatus.teapot:
        if (isExist) {
          _showAlertDialog(CustomStrings().pairedAtsign(atsign),
              getClose: true, onClose: _getAtsignForm);
          break;
        }
        _isQR = true;
        break;
      case AtSignStatus.activated:
        if (isExist) {
          _showAlertDialog(CustomStrings().pairedAtsign(atsign),
              getClose: true, onClose: _getAtsignForm);
          break;
        }
        _isBackup = true;
        break;
      case AtSignStatus.unavailable:
      case AtSignStatus.notFound:
        _showAlertDialog(Strings.atsignNotFound,
            getClose: true, onClose: _getAtsignForm);
        break;
      case AtSignStatus.error:
        _showAlertDialog(Strings.atsignNull,
            getClose: true, onClose: _getAtsignForm);
        break;
      default:
        break;
    }
    setState(() {
      loading = false;
      _loadingMessage = null;
    });
  }
}
