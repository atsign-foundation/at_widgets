import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

abstract class ContactTheme {
  /// Creates a new contact theme based on provided colors and text styles.
  const ContactTheme({
    required this.backgroundColor,
    required this.primaryColor,
    required this.accentColor,
    required this.dividerColor,
    required this.avatarBorderColor,
    required this.appbarIconColor,
    required this.searchBackgroundColor,
    required this.searchInputTextStyle,
    required this.searchHintTextStyle,
    required this.contactTitleTextStyle,
    required this.contactSubtitleTextStyle,
    required this.headerTextStyle,
  });

  /// Used as a background color of contact screen
  final Color backgroundColor;

  /// The background color for major parts of the app (toolbars, etc)
  final Color primaryColor;

  /// The foreground color for widgets or icons
  final Color accentColor;

  /// The foreground color for dividers
  final Color dividerColor;

  /// The foreground color for avatar's border
  final Color avatarBorderColor;

  /// The foreground color for appbar's icons
  final Color appbarIconColor;

  /// The background color for search view
  final Color searchBackgroundColor;

  /// Text style of the text in search input.
  final TextStyle searchInputTextStyle;

  /// Text style of the textHint in search input.
  final TextStyle searchHintTextStyle;

  /// Text style of the contact's title.
  final TextStyle contactTitleTextStyle;

  /// Text style of the contact's subtitle.
  final TextStyle contactSubtitleTextStyle;

  /// Text style of the contact's header.
  final TextStyle headerTextStyle;
}

class DefaultContactTheme extends ContactTheme {
  const DefaultContactTheme({
    Color backgroundColor = Colors.white,
    Color primaryColor = Colors.white,
    Color accentColor = Colors.brown,
    Color dividerColor = ColorConstants.dividerColor,
    Color avatarBorderColor = const Color(0xfff4533d),
    Color appbarIconColor = Colors.white,
    Color searchBackgroundColor = ColorConstants.inputFieldColor,
    TextStyle searchInputTextStyle = const TextStyle(
      fontSize: 16,
      color: ColorConstants.fontPrimary,
    ),
    TextStyle searchHintTextStyle = const TextStyle(
      fontSize: 16,
      color: ColorConstants.greyText,
    ),
    TextStyle contactTitleTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14,
    ),
    TextStyle contactSubtitleTextStyle = const TextStyle(
      color: ColorConstants.fadedText,
      fontSize: 14,
    ),
    TextStyle headerTextStyle = const TextStyle(
      color: ColorConstants.blueText,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  }) : super(
          backgroundColor: backgroundColor,
          primaryColor: primaryColor,
          accentColor: accentColor,
          dividerColor: dividerColor,
          avatarBorderColor: avatarBorderColor,
          appbarIconColor: appbarIconColor,
          searchBackgroundColor: searchBackgroundColor,
          searchInputTextStyle: searchInputTextStyle,
          searchHintTextStyle: searchHintTextStyle,
          contactTitleTextStyle: contactTitleTextStyle,
          contactSubtitleTextStyle: contactSubtitleTextStyle,
          headerTextStyle: headerTextStyle,
        );
}

class DarkContactTheme extends ContactTheme {
  const DarkContactTheme({
    Color backgroundColor = Colors.black,
    Color primaryColor = Colors.black,
    Color accentColor = Colors.brown,
    Color dividerColor = ColorConstants.dividerColor,
    Color avatarBorderColor = Colors.white,
    Color appbarIconColor = Colors.white,
    Color searchBackgroundColor = const Color(0xFF181818),
    TextStyle searchInputTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    TextStyle searchHintTextStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFFADADAD),
    ),
    TextStyle contactTitleTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
    ),
    TextStyle contactSubtitleTextStyle = const TextStyle(
      color: ColorConstants.fadedText,
      fontSize: 14,
    ),
    TextStyle headerTextStyle = const TextStyle(
      color: ColorConstants.blueText,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  }) : super(
          backgroundColor: backgroundColor,
          primaryColor: primaryColor,
          accentColor: accentColor,
          dividerColor: dividerColor,
          avatarBorderColor: avatarBorderColor,
          appbarIconColor: appbarIconColor,
          searchBackgroundColor: searchBackgroundColor,
          searchInputTextStyle: searchInputTextStyle,
          searchHintTextStyle: searchHintTextStyle,
          contactTitleTextStyle: contactTitleTextStyle,
          contactSubtitleTextStyle: contactSubtitleTextStyle,
          headerTextStyle: headerTextStyle,
        );
}
