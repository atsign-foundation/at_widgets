import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestMaterialApp extends StatelessWidget {
  final Widget? home;

  TestMaterialApp({this.home});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Widget Test', home: home);
    // return MediaQuery(
    //     data: MediaQueryData(),
    //     child: MaterialApp(title: 'Widget Test', home: home));
  }
}
