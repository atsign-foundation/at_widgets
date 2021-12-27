<img src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_events_flutter)](https://pub.dev/packages/at_events_flutter) [![pub points](https://badges.bar/at_events_flutter/pub%20points)](https://pub.dev/packages/at_events_flutter/score) [![build status](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml/badge.svg?branch=trunk)](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_events_flutter

## Introduction

A flutter plugin project to manage events.

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
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The event service needs to be initialised with the `atClient` from the `AtClientService` and the root server.

```
initialiseEventService(
  clientSdkService.atClientServiceInstance.atClient,
  NavService.navKey,
  rootDomain: MixedConstants.ROOT_DOMAIN,
  mapKey: 'xxxx',
  apiKey: 'xxxx');
```

### Usage
To create a new event:
```
await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: StadiumBorder(),
    builder: (BuildContext context) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12.0),
            topRight: const Radius.circular(12.0),
          ),
        ),
        child: CreateEvent(),
      );
    });
```

Navigating to the events list is done simply by using:
```
Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventList(),
      ),
    );
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