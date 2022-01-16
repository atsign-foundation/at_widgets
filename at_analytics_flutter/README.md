<img src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## Now for some internet optimism.

<!-- [![pub package](https://img.shields.io/pub/v/at_chat_flutter)](https://pub.dev/packages/at_chat_flutter) [![pub points](https://badges.bar/at_chat_flutter/pub%20points)](https://pub.dev/packages/at_chat_flutter/score) [![build status](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml/badge.svg?branch=trunk)](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE) -->


# at_chat_flutter

## Introduction

A flutter plugin to provide error or bug reporting feature.
This plugin provides a bug report screen.

## Get Started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


### Installation:

 To use this library in your app, add it to your pubspec.yaml

<!-- ``` 
  dependencies:
    at_chat_flutter: ^3.0.3
``` -->
#### Add to your project

 ```dart
 flutter pub get 
 ```
 #### Import in your application code

 <!-- ```dart
 import 'package:at_chat_flutter/at_chat_flutter.dart';
 ``` -->
### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising:
The chat service needs to be initialised. It is expected that the app will first create an AtClientService instance using the preferences and then use it to initialise the chat service.

```dart
initializeChatService(
        clientSdkService.atClientServiceInstance!.atClientManager,
        activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

### Usage

<!-- ### As a bottom sheet
```
FlatButton(
    onPressed: () {
        scaffoldKey.currentState
        .showBottomSheet((context) => ChatScreen());
    },
    child: Container(
        height: 40,
        child: Text('Open chat in bottom sheet'),
    ),
),
``` -->



## Example

<!-- We have a good example with explanation in the [at_analytics_flutter](https://pub.dev/packages/at_chat_flutter/example) package. -->

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.