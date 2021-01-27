import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/images.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/custom_appbar.dart';
import 'package:at_onboarding_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:at_utils/at_logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:archive/archive_io.dart';

class PrivateKeyQRCodeGenScreen extends StatefulWidget {
  PrivateKeyQRCodeGenScreen({Key key}) : super(key: key);

  @override
  _PrivateKeyQRCodeGenScreenState createState() =>
      _PrivateKeyQRCodeGenScreenState();
}

class _PrivateKeyQRCodeGenScreenState extends State<PrivateKeyQRCodeGenScreen> {
  var _logger = AtSignLogger('AtPrivateKeyQRCodeGeneration');
  String atsign;
  var aesKey;
  var _size;

  @override
  void initState() {
    super.initState();
    atsign = OnboardingService.getInstance().currentAtsign;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  GlobalKey globalKey = new GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    if (atsign == null) {
      return Text('An @sign is required.');
    }
    _size = MediaQuery.of(context).size;
    return Opacity(
      opacity: _loading ? 0.2 : 1,
      child: AbsorbPointer(
        absorbing: _loading,
        child: Scaffold(
          backgroundColor: ColorConstants.light,
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: Strings.saveBackupZipTitle,
            showBackButton: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  Strings.saveImportantTitle,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.fontBold18primary,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  Strings.saveBackupDescription,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.fontR16primary,
                ),
                SizedBox(
                  height: 40.toHeight,
                ),
                Center(
                    child: Image.asset(
                  Images.backupZip,
                  package: AppConstants.package,
                )),
                SizedBox(
                  height: 30.toHeight,
                ),
                CustomButton(
                  width: 230.toWidth,
                  buttonText: Strings.saveButtonTitle,
                  onPressed: _saveBackuzip,
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                CustomButton(
                  width: 230.toWidth,
                  isInverted: true,
                  buttonText: Strings.coninueButtonTitle,
                  onPressed: () async {
                    await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OnboardingService.getInstance().nextScreen));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _saveBackuzip() async {
    final _onboardingService = OnboardingService.getInstance();
    try {
      var aesEncryptedKeys = await _onboardingService.getEncryptedKeys(atsign);
      var directory;
      String path;
      var status = await Permission.storage.status;
      if (status.isUndetermined) {
        await Permission.storage.request();
      }
      directory = await path_provider.getApplicationSupportDirectory();
      path = directory.path.toString() + '/';
      // var aesKey = await _onboardingService.getAESKey(atsign);
      // final String imageData = '$atsign:$aesKey';
      final encryptedKeysFile =
          await File('$path${Strings.backupFileName(atsign)}').create();
      var keyString = jsonEncode(aesEncryptedKeys);
      // keyString = keyString + imageData;
      encryptedKeysFile.writeAsStringSync(keyString);
      var encoder = ZipFileEncoder();
      encoder.create('$path' + '${atsign + AppConstants.backupZipExtension}');
      encoder.addFile(encryptedKeysFile);
      encoder.close();
      encryptedKeysFile.deleteSync();
      await Share.shareFiles([encoder.zip_path],
          sharePositionOrigin:
              Rect.fromLTWH(0, 0, _size.width, _size.height / 2));
    } on Exception catch (ex) {
      _logger.severe('BackingUp keys throws $ex exception');
    } on Error catch (err) {
      _logger.severe('BackingUp keys throws $err error');
    }
  }
}
