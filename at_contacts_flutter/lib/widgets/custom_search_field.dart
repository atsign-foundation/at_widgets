/// A search field to filter out the contacts

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class ContactSearchField extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;
  ContactSearchField(this.hintText, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.toFont),
      child: TextField(
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16.toFont,
            color: ColorConstants.greyText,
          ),
          filled: true,
          fillColor: ColorConstants.inputFieldColor,
          contentPadding: EdgeInsets.symmetric(vertical: 15.toHeight),
          prefixIcon: Icon(
            Icons.search,
            color: ColorConstants.greyText,
            size: 20.toFont,
          ),
        ),
        style: TextStyle(
          fontSize: 16.toFont,
          color: ColorConstants.fontPrimary,
        ),
      ),
    );
  }
}
