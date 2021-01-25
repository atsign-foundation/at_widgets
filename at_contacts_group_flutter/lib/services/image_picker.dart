import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ImagePicker {
  ImagePicker._();
  static ImagePicker _instance = new ImagePicker._();
  factory ImagePicker() => _instance;

  Future<Uint8List> pickImage() async {
    Uint8List fileContents;
    FilePickerResult result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    for (var pickedFile in result.files) {
      var path = pickedFile.path;
      fileContents = File(path).readAsBytesSync();
    }
    return fileContents;
  }
}
