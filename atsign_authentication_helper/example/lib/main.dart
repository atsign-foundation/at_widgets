import 'package:flutter/material.dart';
import 'package:atsign_authentication_helper/atsign_authentication_helper.dart';
import 'package:atsign_authentication_helper_example/second_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(child: StartButton(nextScreen: SecondScreen())),
      ),
    );
  }
}
