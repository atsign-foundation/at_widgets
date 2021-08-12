import 'package:flutter/material.dart';

/// See [ChatTheme.userAvatarNameColors]
const COLORS = [
  Color(0xffff6767),
  Color(0xff66e0da),
  Color(0xfff5a2d9),
  Color(0xfff0c722),
  Color(0xff6a85e5),
  Color(0xfffd9a6f),
  Color(0xff92db6e),
  Color(0xff73b8e5),
  Color(0xfffd7590),
  Color(0xffc78ae5),
];

/// Dark
const DARK = Color(0xff1f1c38);

/// Error
const ERROR = Color(0xffff6767);

/// N0
const NEUTRAL_0 = Color(0xff1d1c21);

/// N2
const NEUTRAL_2 = Color(0xff9e9cab);

/// N7
const NEUTRAL_7 = Color(0xffffffff);

/// N7 with opacity
const NEUTRAL_7_WITH_OPACITY = Color(0x80ffffff);

/// Primary
const PRIMARY = Color(0xff6f61e8);

/// Secondary
const SECONDARY = Color(0xfff5f5f7);

/// Secondary dark
const SECONDARY_DARK = Color(0xff2b2250);

/// Base chat theme containing all required variables to make a theme.
/// Extend this class if you want to create a custom theme.
@immutable
abstract class ChatTheme {
  /// Used as a background color of a chat widget
  final Color backgroundColor;

  /// Used as a background color of a incoming message
  final Color incomingBackgroundColor;

  /// Used as a background color of a outgoing message
  final Color outgoingBackgroundColor;

  /// Color of the bottom bar where text field is
  final Color inputBackgroundColor;

  /// Color of the text field's text and attachment/send buttons
  final Color inputTextColor;

  /// Text style of the message input. To change the color use [inputTextColor].
  final TextStyle inputTextStyle;

  /// Body text style used for displaying incoming text message
  final TextStyle incomingTextStyle;

  /// Body text style used for displaying outgoing text message
  final TextStyle outgoingTextStyle;

  /// Creates a new chat theme based on provided colors and text styles.
  const ChatTheme({
    required this.backgroundColor,
    required this.incomingBackgroundColor,
    required this.outgoingBackgroundColor,
    required this.inputBackgroundColor,
    required this.inputTextColor,
    required this.inputTextStyle,
    required this.incomingTextStyle,
    required this.outgoingTextStyle,
  });
}

/// Default chat theme which extends [ChatTheme]
@immutable
class DefaultChatTheme extends ChatTheme {
  /// Creates a default chat theme. Use this constructor if you want to
  /// override only a couple of variables, otherwise create a new class
  /// which extends [ChatTheme]
  const DefaultChatTheme({
    Color backgroundColor = Colors.white,
    Color incomingBackgroundColor = const Color(0xfff5f5f7),
    Color outgoingBackgroundColor = const Color(0xff6f61e8),
    Color inputBackgroundColor = const Color(0xffb1b1b1),
    Color inputTextColor = Colors.black,
    TextStyle inputTextStyle = const TextStyle(color: Colors.black),
    TextStyle incomingTextStyle = const TextStyle(color: Colors.black),
    TextStyle outgoingTextStyle = const TextStyle(color: Colors.white),
  }) : super(
          backgroundColor: backgroundColor,
          incomingBackgroundColor: incomingBackgroundColor,
          outgoingBackgroundColor: outgoingBackgroundColor,
          inputBackgroundColor: inputBackgroundColor,
          inputTextColor: inputTextColor,
          inputTextStyle: inputTextStyle,
          incomingTextStyle: incomingTextStyle,
          outgoingTextStyle: outgoingTextStyle,
        );
}

/// Dark chat theme which extends [ChatTheme]
@immutable
class DarkChatTheme extends ChatTheme {
  /// Creates a dark chat theme. Use this constructor if you want to
  /// override only a couple of variables, otherwise create a new class
  /// which extends [ChatTheme]
  const DarkChatTheme({
    Color backgroundColor = const Color(0xff1f1c38),
    Color incomingBackgroundColor = const Color(0xff2b2250),
    Color outgoingBackgroundColor = const Color(0xff6f61e8),
    Color inputBackgroundColor = const Color(0xff2b2250),
    Color inputTextColor = Colors.black,
    TextStyle inputTextStyle = const TextStyle(color: Colors.white),
    TextStyle incomingTextStyle = const TextStyle(color: Colors.white),
    TextStyle outgoingTextStyle = const TextStyle(color: Colors.white),
  }) : super(
          backgroundColor: backgroundColor,
          incomingBackgroundColor: incomingBackgroundColor,
          outgoingBackgroundColor: outgoingBackgroundColor,
          inputBackgroundColor: inputBackgroundColor,
          inputTextColor: inputTextColor,
          inputTextStyle: inputTextStyle,
          incomingTextStyle: incomingTextStyle,
          outgoingTextStyle: outgoingTextStyle,
        );
}
