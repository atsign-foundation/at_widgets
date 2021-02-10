import 'dart:convert';
import 'dart:io';

import 'package:at_backupkey_flutter/services/backupkey_service.dart';
import 'package:at_backupkey_flutter/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share/share.dart';
import 'package:at_utils/at_logger.dart';

class BackupKeyWidget extends StatelessWidget {
  final AtSignLogger _logger = AtSignLogger('BackUp Key Widget');
  final _backupKeyService = BackUpKeyService();
  final String atsign;
  final bool isButton;
  final bool isIcon;
  final atClientService;
  // final Function onPressed;
  final String buttonText;
  final Color iconColor;
  final double buttonWidth;
  final double buttonHeight;
  final double iconSize;
  final Color buttonColor;

  BackupKeyWidget(
      {@required this.atsign,
      @required this.atClientService,
      this.isButton = false,
      this.isIcon,
      // this.onPressed,
      this.buttonText,
      this.iconColor,
      this.buttonWidth,
      this.buttonHeight,
      this.buttonColor,
      this.iconSize}) {
    _backupKeyService.atClientService = atClientService;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return isButton
        ? GestureDetector(
            onTap: () {
              _onBackup(context);
            },
            child: Container(
              width: this.buttonWidth ?? 158.toWidth,
              height: this.buttonHeight ?? (50.toHeight),
              padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.toWidth),
                  color: this.buttonColor == null
                      ? Colors.black
                      : this.buttonColor),
              child: Center(
                child: Text(buttonText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.toFont,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          )
        : GestureDetector(
            child: Icon(
              Icons.file_copy,
              color: this.iconColor,
            ),
            onTap: () {
              _showDialog(context);
            },
          );
  }

  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text(
                Strings.backUpKeysTitle,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Strings.backUpKeysDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 20),
                Row(
                  children: [
                    FlatButton(
                        child: Text(Strings.backButtonTitle,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await _onBackup(context);
                        }),
                    Spacer(),
                    FlatButton(
                        child: Text(Strings.cancelButtonTitle,
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                )
              ],
            ),
          );
        });
  }

  _onBackup(BuildContext context) async {
    var _size = MediaQuery.of(context).size;
    try {
      var aesEncryptedKeys = await _backupKeyService.getEncryptedKeys(atsign);
      var directory;
      String path;
      var status = await Permission.storage.status;
      if (status.isUndetermined) {
        await Permission.storage.request();
      }
      directory = await path_provider.getApplicationSupportDirectory();
      path = directory.path.toString() + '/';
      final encryptedKeysFile =
          await File('$path' + '$atsign${Strings.backupKeyName}').create();
      var keyString = jsonEncode(aesEncryptedKeys);
      encryptedKeysFile.writeAsStringSync(keyString);
      await Share.shareFiles([encryptedKeysFile.path],
          sharePositionOrigin:
              Rect.fromLTWH(0, 0, _size.width, _size.height / 2));
    } on Exception catch (ex) {
      _logger.severe('BackingUp keys throws $ex exception');
    } on Error catch (err) {
      _logger.severe('BackingUp keys throws $err error');
    }
  }
}
