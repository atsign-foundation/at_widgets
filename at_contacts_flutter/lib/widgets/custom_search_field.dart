/// A search field to filter out the contacts

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/contact_theme.dart';
import 'package:flutter/material.dart';

class ContactSearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;
  final ContactTheme theme;

  ContactSearchField({
    this.hintText = '',
    this.onChanged,
    this.theme = const DefaultContactTheme(),
  });

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
          hintStyle: theme.searchHintTextStyle,
          filled: true,
          fillColor: theme.searchBackgroundColor,
          contentPadding: EdgeInsets.symmetric(vertical: 15.toHeight),
          prefixIcon: Icon(
            Icons.search,
            color: theme.searchHintTextStyle.color,
            size: 20.toFont,
          ),
        ),
        style: theme.searchInputTextStyle,
      ),
    );
  }
}
