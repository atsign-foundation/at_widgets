# radial_gauges

The at_radial_gauge library comes with three highly  customizable radial gauges. They are the simple gauge, range gauge and scale gauge. The main parameters are the actual value and maximum value, the range gauge parameter has an extra range parameter that is also a required value.

## Simple Gauge Example

The code snippet below shows the simple gauge widget with the required  `actualValue`, `maxValue` and the optional `icon`, `duration` and `title` properties. The `duration` property controls the duration of the animation of this widget.

```dart
SimpleGauge(
    actualValue: 75,
    maxValue: 100,
    icon: Icon(Icons.water),
    duration: 500,
    title: Text('Simple Gauge',)
),
```

## Scale Gauge

The code snippet below shows the scale gauge widget with the required  `actualValue`, `maxValue` and the optional `title` properties.
```dart
ScaleGauge(
    maxValue: 99,
    actualValue: 44,
    title: Text('Scale Gauge'),
),
```

## Range Gauge
The code snippet below shows the range gauge widget with the required  `actualValue`, `maxValue` and `range` properties. The  `maxDegree`, `startDegree`, `isLegend`, `title` and `titlePosition` properties are optional.

```dart
RangeGauge(
    maxValue: 75,
    actualValue: 45,
    maxDegree: 180,
    startDegree: 180,
    isLegend: true,
    title: const Text('Range Gauge'),
    titlePosition: TitlePosition.bottom,
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
    ],
),
```
