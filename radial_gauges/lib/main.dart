import 'package:flutter/material.dart';

import 'radial_gauges/radial_gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyCharts(),
    );
  }
}

class MyCharts extends StatelessWidget {
  const MyCharts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Radial Gauges')),
      body: SafeArea(
        child: Column(
          children: const [
            SimpleGauge(
              actualValue: 75,
              maxValue: 100,
              icon: Icon(Icons.water),
              duration: 500,
              title: Text('Simple Gauge'),
            ),
            ScaleGauge(
              maxValue: 240,
              actualValue: 50,
              title: Text('Scale Gauge'),
            ),
            // RangeGauge(
            //   maxValue: 200,
            //   actualValue: 100,
            //   maxDegree: 180,
            //   startDegree: 180,
            //   isLegend: true,
            //   ranges: [
            //     Range(
            //       label: 'slow',
            //       lowerLimit: 0,
            //       upperLimit: 25,
            //       backgroundColor: Colors.blue,
            //     ),
            //     Range(
            //       label: 'medium',
            //       lowerLimit: 25,
            //       upperLimit: 50,
            //       backgroundColor: Colors.orange,
            //     ),
            //     Range(
            //       label: 'fast',
            //       lowerLimit: 50,
            //       upperLimit: 75,
            //       backgroundColor: Colors.lightGreen,
            //     ),
            //     Range(
            //       label: 'extra fast',
            //       lowerLimit: 75,
            //       upperLimit: 100,
            //       backgroundColor: Colors.purple,
            //     ),
            //     Range(
            //       label: 'super fast',
            //       lowerLimit: 100,
            //       upperLimit: 125,
            //       backgroundColor: Colors.yellow,
            //     ),
            //     Range(
            //       label: 'Mac 1',
            //       lowerLimit: 125,
            //       upperLimit: 150,
            //       backgroundColor: Colors.indigo,
            //     ),
            //     Range(
            //       label: 'Mac 2',
            //       lowerLimit: 150,
            //       upperLimit: 175,
            //       backgroundColor: Colors.pink,
            //     ),
            //     Range(
            //       label: 'Mac 3',
            //       lowerLimit: 175,
            //       upperLimit: 200,
            //       backgroundColor: Colors.teal,
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
