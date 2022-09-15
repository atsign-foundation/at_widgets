import 'dart:async';
import 'dart:developer';

import 'package:at_common_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

final StreamController<ThemeMode> updateThemeMode =
    StreamController<ThemeMode>.broadcast();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  TextTheme getTextTheme(Color primaryTextColor) {
    final textTheme = TextTheme(
      headline1: TextStyle(fontSize: 96.0, color: primaryTextColor),
      headline2: TextStyle(fontSize: 60.0, color: primaryTextColor),
      headline3: TextStyle(fontSize: 48.0, color: primaryTextColor),
      headline4: TextStyle(fontSize: 34.0, color: primaryTextColor),
      headline5: TextStyle(fontSize: 24.0, color: primaryTextColor),
      headline6: TextStyle(
        fontSize: 20.0,
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
      ),
      subtitle1: TextStyle(fontSize: 16.0, color: primaryTextColor),
      subtitle2: TextStyle(
        fontSize: 14.0,
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
      ),
      bodyText1: TextStyle(fontSize: 16.0, color: primaryTextColor),
      bodyText2: TextStyle(fontSize: 14.0, color: primaryTextColor),
      button: TextStyle(
        fontSize: 14.0,
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
      ),
      caption: TextStyle(fontSize: 12.0, color: primaryTextColor),
      overline: TextStyle(fontSize: 14.0, color: primaryTextColor),
    );

    return textTheme;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: updateThemeMode.stream,
      initialData: ThemeMode.light,
      builder: (context, snapshot) {
        return MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFf4533d),
            colorScheme: ThemeData.light().colorScheme.copyWith(
                  primary: const Color(0xFFf4533d),
                ),
            backgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
            textTheme: getTextTheme(Colors.black),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            colorScheme: ThemeData.dark().colorScheme.copyWith(
                  primary: Colors.blue,
                ),
            backgroundColor: Colors.grey[850],
            scaffoldBackgroundColor: Colors.grey[850],
            textTheme: getTextTheme(Colors.white),
          ),
          themeMode: snapshot.data,
          title: 'Example App',
          home: const MyHomePage(title: 'Example App Home Page'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: CustomAppBar(
        appBarColor: Theme.of(context).primaryColor,
        showBackButton: false,
        showTitle: true,
        titleText: widget.title,
        titleTextStyle: const TextStyle().copyWith(
          fontSize: 18.toFont,
          fontWeight: FontWeight.w700,
        ),
        showLeadingIcon: true,
        leadingIcon: const Icon(
          Icons.home_outlined,
        ),
        onTrailingIconPressed: () {
          log('Trailing icon of appbar pressed');
        },
        showTrailingIcon: true,
        trailingIcon: Center(
          child: IconButton(
            onPressed: () {
              updateThemeMode.sink.add(
                  Theme.of(context).brightness == Brightness.light
                      ? ThemeMode.dark
                      : ThemeMode.light);
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20.0),
            const Text('Custom AppBar ☝️'),
            const Divider(
              color: Color(0xFFBEC0C8),
              height: 30,
              thickness: 2,
            ),
            const Text('Custom Input field:'),
            const SizedBox(height: 16),
            CustomInputField(
              icon: Icons.emoji_emotions_outlined,
              width: 200.0,
              initialValue: "initial value",
              value: (String val) {
                log('Current value of input field: $val');
              },
              inputFieldColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.2),
              iconColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            const Divider(
              color: Color(0xFFBEC0C8),
              height: 48,
              thickness: 2,
            ),
            const Text('Custom Button:'),
            const SizedBox(height: 16),
            CustomButton(
              height: 50.0,
              width: 200.0,
              buttonText: 'Add',
              onPressed: () {
                log('Custom button pressed');
              },
              buttonColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              fontColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
