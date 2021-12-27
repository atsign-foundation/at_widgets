<img src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_location_flutter)](https://pub.dev/packages/at_location_flutter) [![pub points](https://badges.bar/at_location_flutter/pub%20points)](https://pub.dev/packages/at_location_flutter/score) [![build status](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml/badge.svg?branch=trunk)](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_location_flutter

## Introduction

A flutter plugin project to share location between two atsigns.

## Get Started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


### Installation:

 To use this library in your app, add it to your pubspec.yaml

```dart 
  dependencies:
    at_chat_flutter: ^3.0.3
```

#### Add to your project

 ```dart
 flutter pub get 
 ```

 #### Import in your application code

 ```dart
 import 'package:at_location_flutter/at_location_flutter.dart';
 ```

### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising:
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The location service needs to be initialised with the `atClient` from the `AtClientService`, current atsign and a global navigator key.

```dart
initializeLocationService(
          clientSdkService.atClientServiceInstance.atClient,
          activeAtSign,
          NavService.navKey,
          mapKey: 'xxxx',
          apiKey: 'xxxx',
          showDialogBox: true);
```
### Usage
Navigating to the maps view is done simply by using:
```
Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(),
    ));
```

To request location from an atsign:
```
await sendRequestLocationNotification(receiver);
```

To share location from an atsign and duration of share in minutes:
```
await sendShareLocationNotification(receiver, 30);
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

We have a good example with explanation in the [at_location_flutter](https://pub.dev/packages/at_location_flutter/example) package.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.
