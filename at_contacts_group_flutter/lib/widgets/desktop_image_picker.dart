import 'dart:typed_data';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_utils/at_logger.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_compression/image_compression.dart';

Future<Uint8List?> desktopImagePicker() async {
  AtSignLogger atSignLogger = AtSignLogger('desktopImagePicker');
  try {
    // ignore: omit_local_variable_types
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'png', 'jpeg'],
    );
    final List<XFile> files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isEmpty) {
      return null;
    }
    // ignore: omit_local_variable_types
    final XFile file = files[0];

    final input = ImageFile(
      rawBytes: await file.readAsBytes(),
      filePath: file.path,
    );

    final output = compress(ImageFileConfiguration(
        input: input,
        config: const Configuration(
            jpgQuality: 50,
            pngCompression: PngCompression.defaultCompression,
            outputType: OutputType.jpg)));

    return output.rawBytes;
  } catch (e) {
    atSignLogger.severe('Error in desktopImagePicker $e');
    return null;
  }
}
