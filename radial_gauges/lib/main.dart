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
          mainAxisSpacing: 50,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SimpleGauge(
                actualValue: 50,
                maxValue: 100,
                icon: Icon(Icons.water),
                duration: 500,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: ScaleGauge(
                maxValue: 240,
                actualValue: 50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RangeGauge(
                maxValue: 200,
                actualValue: 80,
                maxDegree: 180,
                startDegree: 180,
                ranges: [
                  Range(
                    label: 'slow',
                    lowerLimit: 0,
                    upperLimit: 25,
                    backgroundColor: Colors.blue,
                  ),
                  Range(
                    label: 'medium',
                    lowerLimit: 25,
                    upperLimit: 50,
                    backgroundColor: Colors.orange,
                  ),
                  Range(
                    label: 'fast',
                    lowerLimit: 50,
                    upperLimit: 75,
                    backgroundColor: Colors.lightGreen,
                  ),
                  Range(
                    label: 'extra fast',
                    lowerLimit: 75,
                    upperLimit: 100,
                    backgroundColor: Colors.purple,
                  ),
                  Range(
                    label: 'super fast',
                    lowerLimit: 100,
                    upperLimit: 125,
                    backgroundColor: Colors.blue,
                  ),
                  Range(
                    label: 'sonic fast',
                    lowerLimit: 125,
                    upperLimit: 150,
                    backgroundColor: Colors.orange,
                  ),
                  Range(
                    label: 'Mac 1',
                    lowerLimit: 150,
                    upperLimit: 175,
                    backgroundColor: Colors.lightGreen,
                  ),
                  Range(
                    label: 'Mac 2',
                    lowerLimit: 175,
                    upperLimit: 200,
                    backgroundColor: Colors.purple,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
