import 'package:flutter/material.dart';

import 'contact_theme.dart';

/// Used to make provided [ContactTheme] class available through the whole package
class InheritedContactTheme extends InheritedWidget {
  /// Creates [InheritedWidget] from a provided [ChatTheme] class
  const InheritedContactTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  /// Represents contact theme
  final ContactTheme theme;

  static InheritedContactTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedContactTheme>()!;
  }

  @override
  bool updateShouldNotify(InheritedContactTheme oldWidget) =>
      theme.hashCode != oldWidget.theme.hashCode;
}
