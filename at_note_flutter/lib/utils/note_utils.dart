import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'bottom_sheet_dialog.dart';

enum NoteEnum {
  text,
  image,
}

showConfirmDialog(
  BuildContext context,
  String message, {
  Function? onConfirmed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Ok"),
            onPressed: () {
              if (onConfirmed != null) {
                onConfirmed!();
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showAlertDialog(
  BuildContext context,
  String message,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Alert"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showLoading(BuildContext context) {
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<dynamic> showBottomSheetDialog(BuildContext context,
    {Function()? photoCallback, Function()? cameraCallback}) {
  return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      builder: (context) {
        return BottomSheetDialog(
          photoCallback: photoCallback,
          cameraCallback: cameraCallback,
        );
      });
}

Future<Uint8List?> readFileByte(String filePath) async {
  File file = File(filePath);
  try {
    var fileInByte = await file.readAsBytes();
    return fileInByte;
  } catch (error) {
    return null;
  }
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

Future<String> getBase64FromFile(File? file) async {
  if (file != null && await file.exists()) {
    List<int> fileInByte = await file.readAsBytes();
    String fileInBase64 = base64Encode(fileInByte);
    return fileInBase64;
  } else {
    return '';
  }
}
