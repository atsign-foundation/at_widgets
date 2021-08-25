import 'dart:convert';
import 'dart:io';

import 'package:at_backupkey_flutter/services/backupkey_service.dart';
import 'package:at_backupkey_flutter/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share/share.dart';
import 'package:at_utils/at_logger.dart';

class BackupKeyWidget extends StatelessWidget {
  final AtSignLogger _logger = AtSignLogger('BackUp Key Widget');
  final _backupKeyService = BackUpKeyService();

  ///[required] to provide backup keys for `atsign` to save.
  final String atsign;

  ///set to `true` for using widget as a button.
  final bool isButton;

  ///set to `true` for using widget as an icon.
  final bool? isIcon;

  ///[required] to provide backupkeys.
  final atClientService;

  ///takes a `String` and displays on button. set [isButton] to `true` to use this.
  final String? buttonText;

  ///Color of the icon can be set if [isIcon] is set as `true`.
  final Color? iconColor;

  ///any double value for customizing width of button if [isButton] sets to `true`.
  final double? buttonWidth;

  ///any double value for customizing height of a button if [isButton] sets to `true`.
  final double? buttonHeight;

  ///any double value for customizing size of the icon if [isIcon] sets to `true`.
  final double? iconSize;

  ///Customize the button color if [isButton] sets to `true`.
  final Color? buttonColor;

  BackupKeyWidget(
      {required this.atsign,
      required this.atClientService,
      this.isButton = false,
      this.isIcon,
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
        ? Row(
            children: [
              GestureDetector(
                onTap: () async {
                  var result = await _onBackup(context);
                  if (result == false) {
                    _showAlertDialog(context);
                  }
                },
                child: Container(
                  width: this.buttonWidth ?? 158.toWidth,
                  height: this.buttonHeight ?? (50.toHeight),
                  padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.toWidth), color: this.buttonColor == null ? Colors.black : this.buttonColor),
                  child: Center(
                    child: Text(buttonText!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.toFont, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  var result = await _onBackup(context);
                  if (result == false) {
                    _showAlertDialog(context);
                  }
                },
                child: Container(
                  width: this.buttonWidth ?? 158.toWidth,
                  height: this.buttonHeight ?? (50.toHeight),
                  padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.toWidth), color: this.buttonColor == null ? Colors.black : this.buttonColor),
                  child: Center(
                    child: Text(buttonText!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.toFont, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          )
        : IconButton(
            icon: Icon(
              Icons.file_copy,
              color: this.iconColor,
            ),
            onPressed: () {
              _showDialog(context);
            },
          );
  }

  _showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: Row(
              children: [
                Text(
                  'Error',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.toFont),
                ),
                Icon(Icons.sentiment_dissatisfied, size: 25.toFont)
              ],
            ),
            content: Text(
              'Couldn\'t able to backup the key file',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.toFont),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(_);
                },
                child: Text('Close'),
              )
            ],
          );
        });
  }

  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctxt) {
          return AlertDialog(
            title: Center(
              child: Text(
                Strings.backUpKeysTitle,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Strings.backUpKeysDescription, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
                SizedBox(height: 20.toHeight),
                Row(
                  children: [
                    TextButton(
                        child: Text(Strings.backButtonTitle, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          var result = await _onBackup(context);
                          Navigator.pop(ctxt);
                          if (result == false) {
                            _showAlertDialog(context);
                          }
                        }),
                    Spacer(),
                    TextButton(
                        child: Text(Strings.cancelButtonTitle, style: TextStyle(color: Colors.black)),
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
      if (aesEncryptedKeys.isEmpty) {
        return false;
      }
      String path = await _generateFile(aesEncryptedKeys);
      print(path);
      // await Share.shareFiles([path],
      //     sharePositionOrigin:
      //         Rect.fromLTWH(0, 0, _size.width, _size.height / 2));
      Fluttertoast.showToast(
        msg: "Key saved to your device",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } on Exception catch (ex) {
      _logger.severe('BackingUp keys throws $ex exception');
    } on Error catch (err) {
      _logger.severe('BackingUp keys throws $err error');
    }
  }

  Future<String> _generateFile(Map<String, String> aesEncryptedKeys) async {
    var status = await Permission.storage.status;
    if (status.isDenied || status.isRestricted) {
      await Permission.storage.request();
    }
    var directory = await path_provider.getApplicationSupportDirectory();
    String path = directory.path.toString() + '/';
    final encryptedKeysFile = await File('$path' + '$atsign${Strings.backupKeyName}').create();
    var keyString = jsonEncode(aesEncryptedKeys);
    encryptedKeysFile.writeAsStringSync(keyString);
    return encryptedKeysFile.path;
  }
}
