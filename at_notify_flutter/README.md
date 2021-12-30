<img src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_notify_flutter)](https://pub.dev/packages/at_notify_flutter) [![pub points](https://badges.bar/at_notify_flutter/pub%20points)](https://pub.dev/packages/at_notify_flutter/score)
[![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_notify_flutter

## Introduction

A flutter plugin project to handle notifications in @protocol apps.

## Get Started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


### Installation:

 To use this library in your app, add it to your pubspec.yaml

```dart
  dependencies:
    at_notify_flutter: ^1.0.1
```
#### Add to your project

 ```dart
 flutter pub get 
 ```
 #### Import in your application code

 ```dart
 import 'package:at_notify_flutter/at_notify_flutter.dart';
 ```
### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising
It is expected that the app will first authenticate an atsign using the Onboarding widget.

The notify service needs to be initialised with a required atClientManager, 
currentAtSign & atClientPreference.

```
initializeNotifyService(
      atClientManager,
      activeAtSign,
      atClientPreference,
    );
```

### Usage

To notify an atsign with a message:
```
notifyText(
      context,
      currentAtsign,
      receiver,
      message,
    )
```

To see a list of past notifications:
```
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            NotifyScreen(notifyService: NotifyService())),
  );
```

## Example

We have a good example with explanation in the [at_notify_flutter](https://pub.dev/packages/at_notify_flutter/example) package.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.