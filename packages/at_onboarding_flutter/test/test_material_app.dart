import 'package:flutter/material.dart';

class TestMaterialApp extends StatelessWidget {
  final Widget? home;

  const TestMaterialApp({super.key, this.home});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Widget Test', home: home);
  }
}
