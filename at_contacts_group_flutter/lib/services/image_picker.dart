import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImagePicker {
  ImagePicker._();
  static final ImagePicker _instance = ImagePicker._();
  factory ImagePicker() => _instance;

  Future<Uint8List?> pickImage() async {
    Uint8List? fileContents;
    // ignore: omit_local_variable_types
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null) {
      for (PlatformFile pickedFile in result.files) {
        String path = pickedFile.path!;
        File file = File(path);
        Uint8List? compressedFile = await FlutterImageCompress.compressWithFile(
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
