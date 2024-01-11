import 'package:at_enrollment_app/screen/landing_screen.dart';
import 'package:at_enrollment_app/screens/atkey_authenticator.dart';
import 'package:at_enrollment_app/screens/home.dart';
import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorConstant.bgColor,
      body: SafeArea(
        child: LandingPage(),
      ),
    );
  }
}
