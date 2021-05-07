import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImagePicker {
  ImagePicker._();
  static ImagePicker _instance = ImagePicker._();
  factory ImagePicker() => _instance;

  Future<Uint8List?> pickImage() async {
    Uint8List? fileContents;
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null) {
      for (var pickedFile in result.files) {
        var path = pickedFile.path!;
        File file = File(path);
        var compressedFile = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: 400,
          minHeight: 200,
        );
        fileContents = compressedFile;
      }
    }
    return fileContents;
  }
}
