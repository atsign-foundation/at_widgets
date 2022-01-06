<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_events_flutter)](https://pub.dev/packages/at_events_flutter) [![pub points](https://badges.bar/at_events_flutter/pub%20points)](https://pub.dev/packages/at_events_flutter/score) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_events_flutter

## Introduction

A flutter plugin project to manage events between atsigns.

## Get Started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


### Installation:

 To use this library in your app, add it to your pubspec.yaml

```dart
  dependencies:
    at_events_flutter: ^3.0.2
```
#### Add to your project

 ```dart
 flutter pub get 
 ```
 #### Import in your application code

 ```dart
 import 'package:at_events_flutter/at_events_flutter.dart';
 ```
### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising:
It is expected that the app will first authenticate an atsign using the Onboarding widget.

The event service needs to be initialised with a required GlobalKey<NavigatorState> parameter for
navigation purpose (make sure the key is passed to the parent [MaterialApp]), the rest being optional parameters.

```
  initialiseEventService(
    navKey,
    mapKey: 'xxxx',
    apiKey: 'xxxx',
    rootDomain: 'root.atsign.org',
    streamAlternative: (__){},
    initLocation: true,
  );
```

As this package needs location permission, so add these for:

IOS: (ios/Runner/Info.plist)

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Explain the description here.</string>
```

Android: (android/app/src/main/AndroidManifest.xml)

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

at_events_flutter depends on at_location_flutter for the following features:
 - Sending/receiving location, make sure to initialise at_location_flutter inside/outside the at_events_flutter package, if location sharing is needed.
 - To render the map, pass [mapKey] to [initializeLocationService], if map is needed.
 - To calculate the ETA, pass [apiKey] to [initializeLocationService], if ETA is needed.

### Usage
To create a new event, using the default screen:
```
  CreateEvent(
    AtClientManager.getInstance(),
  ),
```

To use event creation/edit functions, use the [EventService()] singleton, 
make sure to call [EventService().init()] before using these functions:
- createEvent() - Can create and edit based on [isEventUpdate] passed to [init()]
- editEvent() - Will update the already created event
- sendEventNotification() - Will create a new event

Navigating to the map screen for an event:
```
EventsMapScreenData().moveToEventScreen(eventNotificationModel);
```

Different datatypes used in the package:
```
 - EventNotificationModel: Contains the details of an event and is sent to atsigns while creating an event.
 - EventKeyLocationModel - The package uses this to keep a track of all the event notifications.
```

### Steps to get mapKey

  - Go to https://cloud.maptiler.com/maps/streets/
  - Click on `sign in` or `create a free account`
  - Come back to https://cloud.maptiler.com/maps/streets/ if not redirected automatically
  - Get your key from your `Embeddable viewer` input text box 
    - Eg : https://api.maptiler.com/maps/streets/?key=<YOUR_MAP_KEY>#-0.1/-2.80318/-38.08702
  - Copy <YOUR_MAP_KEY> and use it.

### Steps to get apiKey

  - Go to https://developer.here.com/tutorials/getting-here-credentials/ and follow the steps

## Example

We have a good example with explanation in the [at_events_flutter](https://pub.dev/packages/at_events_flutter/example) package.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.