import 'dart:typed_data';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_utils/at_logger.dart';
import 'package:file_selector/file_selector.dart';

dynamic desktopImagePicker() async {
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
    final Uint8List image = await file.readAsBytes();
    return image;
  } catch (e) {
    atSignLogger.severe('Error in desktopImagePicker $e');
    return null;
  }
}
