import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_result.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_activate_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_backup_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_generate_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_input_atsign_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_qrcode_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reference_screen.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_config.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_tutorial_service.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_error_util.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:at_utils/at_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

class AtOnboardingHomeScreen extends StatefulWidget {
  final AtOnboardingConfig config;

  /// If true, shows the custom dialog to get an atsign
  final bool getAtSign;
  final bool hideReferences;
  final bool hideQrScan;

  final onboardStatus = OnboardingStatus.ACTIVATE;
  final bool isFromIntroScreen;

  const AtOnboardingHomeScreen({
    Key? key,
    required this.config,
    this.getAtSign = false,
    this.hideReferences = false,
    this.hideQrScan = false,
    this.isFromIntroScreen = false,
  }) : super(key: key);

  @override
  State<AtOnboardingHomeScreen> createState() => _AtOnboardingHomeScreenState();
}

class _AtOnboardingHomeScreenState extends State<AtOnboardingHomeScreen> {
  final AtSignLogger _logger = AtSignLogger('At Onboarding');
  final OnboardingService _onboardingService = OnboardingService.getInstance();

  final bool scanQR = false;
  final bool showClose = false;
  late final Function? onClose;

  bool loading = false;
  bool permissionGrated = false;

  bool _isContinue = true;
  bool _uploadingQRCode = false;
  String? _pairingAtsign;

  ServerStatus? atSignStatus;
  final String _incorrectKeyFile = 'Unable to fetch the keys from chosen file. Please choose correct file';
  final String _failedFileProcessing = 'Failed in processing files. Please try again';

  late AtSyncDialog _inprogressDialog;

  ///tutorial
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> signInTargets = <TargetFocus>[];

  GlobalKey keyUploadAtSign = GlobalKey();
  GlobalKey keyUploadQRCode = GlobalKey();
  GlobalKey keyActivateAtSign = GlobalKey();
  GlobalKey keyCreateAnAtSign = GlobalKey();

  @override
  void initState() {
    _inprogressDialog = AtSyncDialog(context: context);
    checkPermissions();
    super.initState();
    _init();
  }

  void _init() async {
    initTargets();
    await _checkShowTutorial();
  }

  Future<void> _checkShowTutorial() async {
    if (widget.config.tutorialDisplay == AtOnboardingTutorialDisplay.always) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showTutorial();
    } else if (widget.config.tutorialDisplay == AtOnboardingTutorialDisplay.never) {
      return;
    } else {
      final result = await AtOnboardingTutorialService.checkShowTutorial();
      if (!result) {
        await Future.delayed(const Duration(milliseconds: 300));
        final result = await AtOnboardingTutorialService.hasShowTutorialSignIn();
        if (!result) {
          _showTutorial();
        }
      }
    }
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: signInTargets,
      skipWidget: const Text(
        "SKIP TUTORIAL",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: _endTutorial,
      onSkip: _endTutorial,
    )..show(context: context);
  }

  void _endTutorial() async {
    var tutorialInfo = await AtOnboardingTutorialService.getTutorialInfo();
    tutorialInfo ??= AtTutorialServiceInfo();
    tutorialInfo.hasShowSignInPage = true;

    AtOnboardingTutorialService.setTutorialInfo(tutorialInfo);
  }

  void initTargets() {
    signInTargets.add(
      TargetFocus(
        identify: "keyUploadAtSign",
        keyTarget: keyUploadAtSign,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Center(
                child: Text(
                  "If you have an activated atSign, tap to upload your atKeys",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AtOnboardingDimens.fontLarge,
                  ),
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 8.0,
        paddingFocus: 8.0,
      ),
    );

    signInTargets.add(
      TargetFocus(
        identify: "keyUploadQRCode",
        keyTarget: keyUploadQRCode,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Center(
                child: Text(
                  (Platform.isAndroid || Platform.isIOS) ? "Tap to scan QR code" : "Tap to upload image QR code",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AtOnboardingDimens.fontLarge,
                  ),
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 8.0,
        paddingFocus: 8.0,
      ),
    );

    signInTargets.add(
      TargetFocus(
        identify: "keyActivateAtSign",
        keyTarget: keyActivateAtSign,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Center(
                child: Text(
                  "Tap here to activate your atSign",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AtOnboardingDimens.fontLarge,
                  ),
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 8.0,
        paddingFocus: 8.0,
      ),
    );

    signInTargets.add(
      TargetFocus(
        identify: "keyCreateAnAtSign",
        keyTarget: keyCreateAnAtSign,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Center(
                child: Text(
                  "If you don't have an atSign, tap here to get one",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AtOnboardingDimens.fontLarge,
                  ),
                ),
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 8.0,
        paddingFocus: 8.0,
      ),
    );
  }

  Future<void> checkPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
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
    } else {
      // bypassing for desktop platforms
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

  Future<void> _uploadKeyFile() async {
    try {
      if (!permissionGrated) {
        await checkPermissions();
      }
      _isContinue = true;
      String? fileContents, aesKey, atsign;
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if ((result?.files ?? []).isEmpty) {
        //User cancelled => do nothing
        return;
      }
      setState(() {
        loading = true;
      });
      for (PlatformFile pickedFile in result?.files ?? <PlatformFile>[]) {
        String? path = pickedFile.path;
        if (path == null) {
          throw const FileSystemException('FilePicker.pickFiles returned a null path');
        }
        File selectedFile = File(path);
        int length = selectedFile.lengthSync();
        if (length < 10) {
          await showErrorDialog(_incorrectKeyFile);
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
              File file1 = await File('${path}test').create();
              file1.writeAsBytesSync(bytes);
              String result = decodeQrCode(file1.path);
              List<String> params = result.replaceAll('"', '').split(':');
              atsign = params[0];
              aesKey = params[1];
              await File('${path}test').delete();
              //read scan QRcode and extract atsign,aeskey
            }
          }
        } else if (pickedFile.name.contains('atKeys')) {
          fileContents = File(path.toString()).readAsStringSync();
        } else if (aesKey == null && atsign == null && pickedFile.name.contains('_private_key.png')) {
          //read scan QRcode and extract atsign,aeskey
          var result = decodeQrCode(path);

          List<String> params = result.split(':');
          atsign = params[0];
          aesKey = params[1];
        } else {
          Uint8List result1 = selectedFile.readAsBytesSync();
          fileContents = String.fromCharCodes(result1);
          bool result = _validatePickedFileContents(fileContents);
          _logger.finer('result after extracting data is......$result');
          if (!result) {
            await showErrorDialog(_incorrectKeyFile);
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
        atsign = "@${params[0]}";
        Map<String, dynamic> keyMap = jsonDecode(fileContents);
        aesKey = keyMap[AtOnboardingConstants.atSelfEncryptionKey];
      }
      if (fileContents == null || (aesKey == null && atsign == null)) {
        await showErrorDialog(_incorrectKeyFile);
        setState(() {
          loading = false;
        });
        return;
      } else if (OnboardingService.getInstance().formatAtSign(atsign) != _pairingAtsign && _pairingAtsign != null) {
        await showErrorDialog(AtOnboardingErrorToString().atsignMismatch(_pairingAtsign));
        setState(() {
          loading = false;
        });
        return;
      }
      setState(() {
        loading = false;
      });
      await _processAESKey(atsign, aesKey, fileContents);
    } catch (error) {
      setState(() {
        loading = false;
      });
      _logger.severe('Uploading backup zip file throws $error');
      await showErrorDialog(_failedFileProcessing);
    }
  }

  String decodeQrCode(String imagepath) {
    var image = img.decodePng(File(imagepath).readAsBytesSync())!;

    LuminanceSource source =
        RGBLuminanceSource(image.width, image.height, image.getBytes(format: img.Format.abgr).buffer.asInt32List());
    var bitmap = BinaryBitmap(HybridBinarizer(source));

    var reader = QRCodeReader();
    var decodedResult = reader.decode(bitmap);
    return decodedResult.text;
  }

  Future<void> _uploadKeyFileForDesktop() async {
    try {
      _isContinue = true;
      String? fileContents, aesKey, atsign;
      setState(() {
        loading = true;
      });

      String? path = await _desktopKeyPicker();
      if (path == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      File selectedFile = File(path);
      int length = selectedFile.lengthSync();
      if (length < 10) {
        await showErrorDialog(_incorrectKeyFile);
        return;
      }

      fileContents = File(path).readAsStringSync();

      if (fileContents.isNotEmpty) {
        List<String> keyData = fileContents.split(',"@');
        List<String> params = keyData[1].toString().substring(0, keyData[1].length - 2).split('":"');
        atsign = "@${params[0]}";
        Map<String, dynamic> keyMap = jsonDecode(fileContents);
        aesKey = keyMap[AtOnboardingConstants.atSelfEncryptionKey];
      }
      if (fileContents.isEmpty || (aesKey == null && atsign == null)) {
        await showErrorDialog(_incorrectKeyFile);
        setState(() {
          loading = false;
        });
        return;
      } else if (OnboardingService.getInstance().formatAtSign(atsign) != _pairingAtsign && _pairingAtsign != null) {
        await showErrorDialog(AtOnboardingErrorToString().atsignMismatch(_pairingAtsign));
        setState(() {
          loading = false;
        });
        return;
      }
      setState(() {
        loading = false;
      });
      await _processAESKey(atsign, aesKey, fileContents);
    } catch (error) {
      setState(() {
        loading = false;
      });
      _logger.severe('Uploading backup zip file throws $error');
      await showErrorDialog(_failedFileProcessing);
    }
  }

  Future<String?> _desktopQRFilePicker() async {
    try {
      // ignore: omit_local_variable_types, prefer_const_constructors
      XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        // ignore: prefer_const_literals_to_create_immutables
        extensions: <String>['png'],
      );
      List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      if (files.isEmpty) {
        return null;
      }
      XFile file = files[0];
      return file.path;
    } catch (e) {
      _logger.severe('Error in desktopImagePicker $e');
      return null;
    }
  }

  Future<String?> _desktopKeyPicker() async {
    try {
      // ignore: prefer_const_constructors
      XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        // ignore: prefer_const_literals_to_create_immutables
        extensions: <String>['atKeys'],
      );
      List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      if (files.isEmpty) {
        return null;
      }
      XFile file = files[0];
      return file.path;
    } catch (e) {
      _logger.severe('Error in desktopImagePicker $e');
      return null;
    }
  }

  Future<void> _processAESKey(String? atsign, String? aesKey, String contents) async {
    dynamic authResponse;
    assert(aesKey != null || aesKey != '');
    assert(atsign != null || atsign != '');
    assert(contents != '');
    _inprogressDialog.show(message: 'Processing...');
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      bool isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist) {
        _inprogressDialog.close();
        await showErrorDialog(AtOnboardingErrorToString().pairedAtsign(atsign));
        return;
      }

      _onboardingService.setAtClientPreference = widget.config.atClientPreference;

      authResponse = await _onboardingService.authenticate(
        atsign,
        jsonData: contents,
        decryptKey: aesKey,
      );
      _inprogressDialog.close();
      if (authResponse == AtOnboardingResponseStatus.authSuccess) {
        //Don't show backup key for case user upload backup key
        // await AtOnboardingBackupScreen.push(context: context);
        if (!mounted) return;
        Navigator.pop(context, AtOnboardingResult.success(atsign: atsign!));
      } else if (authResponse == AtOnboardingResponseStatus.serverNotReached) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNotFound,
        );
      } else if (authResponse == AtOnboardingResponseStatus.authFailed) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNull,
        );
      } else {
        await showErrorDialog('Response Time out');
      }
    } catch (e) {
      _inprogressDialog.close();
      if (e == AtOnboardingResponseStatus.serverNotReached && _isContinue) {
        await _processAESKey(atsign, aesKey, contents);
      } else if (e == AtOnboardingResponseStatus.authFailed) {
        _logger.severe('Error in authenticateWithAESKey');
        await showErrorDialog('Auth Failed');
      } else if (e == AtOnboardingResponseStatus.timeOut) {
        await showErrorDialog('Response Time out');
      } else {
        _logger.warning(e);
      }
    }
  }

  Future<void> showErrorDialog(String? errorMessage) async {
    return AtOnboardingDialog.showError(context: context, message: errorMessage ?? '');
  }

  bool _validatePickedFileContents(String fileContents) {
    bool result = fileContents.contains(BackupKeyConstants.PKAM_PRIVATE_KEY_FROM_KEY_FILE) &&
        fileContents.contains(BackupKeyConstants.PKAM_PUBLIC_KEY_FROM_KEY_FILE) &&
        fileContents.contains(BackupKeyConstants.ENCRYPTION_PRIVATE_KEY_FROM_FILE) &&
        fileContents.contains(BackupKeyConstants.ENCRYPTION_PUBLIC_KEY_FROM_FILE) &&
        fileContents.contains(BackupKeyConstants.SELF_ENCRYPTION_KEY_FROM_FILE);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.primaryColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.primaryColor,
          ),
    );

    return AbsorbPointer(
      absorbing: loading,
      child: Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              AtOnboardingStrings.onboardingTitle,
            ),
            /*leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),*/
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: _showReferenceWebview,
                icon: const Icon(Icons.help),
              ),
            ],
          ),
          body: Center(
            child: Container(
              // width: _dialogWidth,
              decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AtOnboardingDimens.borderRadius)),
              padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
              margin: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Pair an atSign using your atKeys',
                    style: TextStyle(
                      fontSize: AtOnboardingDimens.fontLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  AtOnboardingPrimaryButton(
                    key: keyUploadAtSign,
                    height: 48,
                    borderRadius: 24,
                    onPressed: (Platform.isMacOS || Platform.isLinux || Platform.isWindows)
                        ? _uploadKeyFileForDesktop
                        : _uploadKeyFile,
                    isLoading: loading,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Upload atKeys',
                          style: TextStyle(
                            fontSize: AtOnboardingDimens.fontLarge,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.cloud_upload_rounded,
                          // size: 20,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Upload your atKey file. This file was generated when you activated and paired your atSign and you were prompted to store it in a secure location.',
                    style: TextStyle(fontSize: AtOnboardingDimens.fontSmall),
                  ),
                  const SizedBox(height: 20),
                  if (!widget.hideQrScan) const SizedBox(height: 5),
                  if (!widget.hideQrScan)
                    const Text(
                      'Have a QR Code?',
                      style: TextStyle(
                        fontSize: AtOnboardingDimens.fontLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (!widget.hideQrScan) const SizedBox(height: 5),
                  if (!widget.hideQrScan)
                    (Platform.isAndroid || Platform.isIOS)
                        ? AtOnboardingSecondaryButton(
                            key: keyUploadQRCode,
                            height: 48,
                            borderRadius: 24,
                            onPressed: () async {
                              _showQRCodeScreen(context: context);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Scan QR code',
                                  style: TextStyle(fontSize: AtOnboardingDimens.fontLarge),
                                ),
                                Icon(Icons.arrow_right_alt_rounded)
                              ],
                            ),
                          )
                        : AtOnboardingSecondaryButton(
                            key: keyUploadQRCode,
                            height: 48,
                            borderRadius: 24,
                            isLoading: _uploadingQRCode,
                            onPressed: () async {
                              _uploadQRFileForDesktop();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Upload QR code',
                                  style: TextStyle(fontSize: AtOnboardingDimens.fontLarge),
                                ),
                                Icon(Icons.arrow_right_alt_rounded)
                              ],
                            ),
                          ),
                  const SizedBox(height: 20),
                  if (!widget.hideQrScan)
                    const Text(
                      'Activate an atSign?',
                      style: TextStyle(
                        fontSize: AtOnboardingDimens.fontLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (!widget.hideQrScan) const SizedBox(height: 5),
                  if (!widget.hideQrScan)
                    AtOnboardingSecondaryButton(
                      key: keyActivateAtSign,
                      height: 48,
                      borderRadius: 24,
                      onPressed: () async {
                        _showActiveScreen(context: context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Activate atSign',
                            style: TextStyle(fontSize: AtOnboardingDimens.fontLarge),
                          ),
                          Icon(Icons.arrow_right_alt_rounded)
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        if (widget.isFromIntroScreen) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AtOnboardingGenerateScreen(
                                onGenerateSuccess: ({
                                  required String atSign,
                                  required String secret,
                                }) {
                                  String cramSecret = secret.split(':').last;
                                  String atsign = atSign.startsWith('@') ? atSign : '@$atSign';
                                  _processSharedSecret(atsign, cramSecret);
                                },
                                config: widget.config,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Text(
                        "Get a free atSign",
                        key: keyCreateAnAtSign,
                        style: TextStyle(
                          fontSize: AtOnboardingDimens.fontNormal,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActiveScreen({
    required BuildContext context,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtOnboardingInputAtSignScreen(
          config: widget.config,
        ),
      ),
    );

    if ((result ?? '').isNotEmpty) {
      if (!mounted) return;
      final result2 = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AtOnboardingActivateScreen(
            hideReferences: true,
            atSign: result!,
            config: widget.config,
          ),
        ),
      );

      if (result2 is AtOnboardingResult) {
        switch (result2.status) {
          case AtOnboardingResultStatus.success:
            if (!mounted) return;
            Navigator.of(context).pop(result2);
            break;
          case AtOnboardingResultStatus.error:
            if (!mounted) return;
            Navigator.pop(context, result2);
            break;
          case AtOnboardingResultStatus.cancel:
            break;
        }
      }
    }
  }

  void _showQRCodeScreen({
    required BuildContext context,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtOnboardingQRCodeScreen(
          config: widget.config,
        ),
      ),
    );
    if (result is AtOnboardingQRCodeResult) {
      _processSharedSecret(result.atSign, result.secret);
    }
  }

  Future<dynamic> _processSharedSecret(String atsign, String secret) async {
    dynamic authResponse;
    try {
      _inprogressDialog.show(message: 'Processing...');
      await Future.delayed(const Duration(milliseconds: 400));
      bool isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist) {
        _inprogressDialog.close();
        await _showAlertDialog(AtOnboardingErrorToString().pairedAtsign(atsign));
        return;
      }

      //Delay for waiting for ServerStatus change to teapot when activating an atsign
      await Future.delayed(const Duration(seconds: 10));

      _onboardingService.setAtClientPreference = widget.config.atClientPreference;

      authResponse = await _onboardingService.authenticate(atsign, cramSecret: secret, status: widget.onboardStatus);

      int round = 1;
      atSignStatus = await _onboardingService.checkAtSignServerStatus(atsign);
      while (atSignStatus != ServerStatus.activated) {
        if (round > 10) {
          break;
        }

        await Future.delayed(const Duration(seconds: 3));
        round++;
        atSignStatus = await _onboardingService.checkAtSignServerStatus(atsign);
        debugPrint("currentAtSignStatus: $atSignStatus");
      }

      _inprogressDialog.close();
      if (authResponse == AtOnboardingResponseStatus.authSuccess) {
        if (atSignStatus == ServerStatus.teapot) {
          await _showAlertDialog(
            AtOnboardingStrings.atsignNull,
          );
          return;
        }

        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AtOnboardingBackupScreen(
              config: widget.config,
            ),
          ),
        );

        if (!mounted) return;
        Navigator.pop(context, AtOnboardingResult.success(atsign: atsign));
      } else if (authResponse == AtOnboardingResponseStatus.serverNotReached) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNotFound,
        );
      } else if (authResponse == AtOnboardingResponseStatus.authFailed) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNull,
        );
      } else {
        await showErrorDialog('Response Time out');
      }
    } catch (e) {
      _inprogressDialog.close();
      if (e == AtOnboardingResponseStatus.authFailed) {
        _logger.severe('Error in authenticateWith cram secret');
        await _showAlertDialog(e, title: 'Auth Failed');
      } else if (e == AtOnboardingResponseStatus.serverNotReached && _isContinue) {
        await _processSharedSecret(atsign, secret);
      } else if (e == AtOnboardingResponseStatus.timeOut) {
        await _showAlertDialog(e, title: 'Response Time out');
      }
    }
    return authResponse;
  }

  Future<void> _uploadQRFileForDesktop() async {
    try {
      String? aesKey, atsign;
      setState(() {
        _uploadingQRCode = true;
      });
      String? path = await _desktopQRFilePicker();
      if (path == null) {
        setState(() {
          _uploadingQRCode = false;
        });
        return;
      }

      File selectedFile = File(path);

      int length = selectedFile.lengthSync();
      if (length < 10) {
        await showErrorDialog('Incorrect QR file');
        return;
      }

      img.Image image = img.decodePng(selectedFile.readAsBytesSync())!;

      LuminanceSource source =
          RGBLuminanceSource(image.width, image.height, image.getBytes(format: img.Format.abgr).buffer.asInt32List());
      BinaryBitmap bitmap = BinaryBitmap(HybridBinarizer(source));

      QRCodeReader reader = QRCodeReader();
      Result result = reader.decode(bitmap);
      List<String> params = result.text.replaceAll('"', '').split(':');
      atsign = params[0];
      aesKey = params[1];

      if (aesKey.isEmpty && atsign.isEmpty) {
        await showErrorDialog('Incorrect QR file');
        setState(() {
          _uploadingQRCode = false;
        });
        return;
      }
      _processSharedSecret(atsign, aesKey);
      // await processAESKey(atsign, aesKey, false);
      setState(() {
        _uploadingQRCode = false;
      });
    } catch (error) {
      _logger.warning(error);
      setState(() {
        _uploadingQRCode = false;
      });
      await showErrorDialog('Failed to process file');
    }
  }

  Future<void> _showAlertDialog(dynamic errorMessage, {String? title}) async {
    String? messageString = AtOnboardingErrorToString().getErrorMessage(errorMessage);
    return AtOnboardingDialog.showError(context: context, title: title, message: messageString);
  }

  void _showReferenceWebview() {
    if (Platform.isAndroid || Platform.isIOS) {
      AtOnboardingReferenceScreen.push(
        context: context,
        title: AtOnboardingStrings.faqTitle,
        url: AtOnboardingStrings.faqUrl,
        config: widget.config,
      );
    } else {
      launchUrl(
        Uri.parse(
          AtOnboardingStrings.faqUrl,
        ),
      );
    }
  }
}
