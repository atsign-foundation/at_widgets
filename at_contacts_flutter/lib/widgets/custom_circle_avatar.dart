/// A customized circular avatar to display the profile picture with a small border
/// takes in @param [image] for the [asset image]
/// @param [size] to define the size of the avatar
/// @param [nonAsset] if the image is coming over the network
/// @param [byteImage] to display the image from the netwok

import 'dart:typed_data';
import 'package:at_contacts_flutter/utils/contact_theme.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String? image;
  final double size;
  final bool nonAsset;
  final Uint8List? byteImage;
  final ContactTheme theme;

  const CustomCircleAvatar({
    Key? key,
    this.image,
    this.size = 50,
    this.nonAsset = false,
    this.byteImage,
    this.theme = const DefaultContactTheme(),
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.toFont,
      width: size.toFont,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.toWidth),
        border: Border.all(color: theme.avatarBorderColor, width: 2),
      ),
      child: CircleAvatar(
        radius: (size - 5).toFont,
        backgroundColor: Colors.transparent,
        backgroundImage: nonAsset
            ? Image.memory(byteImage!).image
            : AssetImage(image!, package: 'at_contacts_flutter'),
      ),
    );
  }
}
