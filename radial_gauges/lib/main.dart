import 'package:radial_gauges/radial_gauges/text_annotation_gauge.dart';

import 'radial_gauges/range_pointer_gauge.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: RangePointerGauge(actualValue: 50, maxValue: 100),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextAnnotationGauge(
                minValue: 0,
                maxValue: 240,
                actualValue: 142,
                label: 'Km/h',
                pointerColor: Colors.blue,
                animate: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
