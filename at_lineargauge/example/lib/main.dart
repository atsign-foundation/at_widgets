import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:linear_gauge/linear_gauge.dart';
import 'package:linear_gauge/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Linear gauge Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: LinearGuagePage(),
    );
  }
}

class LinearGuagePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LinearGuagePageState createState() => _LinearGuagePageState();
}

class _LinearGuagePageState extends State<LinearGuagePage> {
  bool isRunning = true;
  var value = -35.5;
  var endValue = 800.0;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: LinearGauge(
          orientation: GaugeOrientation.vertical,
          barRadius: const Radius.circular(6),
          width: MediaQuery.of(context).size.width - 50,
          animation: isRunning,
          gaugeHeight: 40.0,
          progressColor: Colors.orange,
          animationDuration: 900,
          minValue: -40.0,
          maxValue: endValue,
          currentValue: value,
          gaugeStatus: Text("$value"),
          widgetIndicator: const Icon(Icons.arrow_drop_down, size: 40),
          divisions: 5,
          subDivisions: 4,
        ),
      ),
    );
  }
}
