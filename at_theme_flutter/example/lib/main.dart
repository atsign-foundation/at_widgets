import 'dart:async';

import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:flutter/material.dart';

import 'src/pages/profile_page.dart';

void main() {
  runApp(MyApp());
}

final StreamController<AppTheme> appThemeController =
StreamController<AppTheme>.broadcast();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppTheme>(
      stream: appThemeController.stream,
      initialData: AppTheme.from(),
      builder: (context, snapshot) {
        AppTheme appTheme = snapshot.data ?? AppTheme.from();
        return InheritedAppTheme(
          theme: appTheme,
          child: MaterialApp(
            title: 'Multi theme',
            theme: appTheme.toThemeData(),
            home: ProfilePage(),
          ),
        );
      },
    );
  }
}