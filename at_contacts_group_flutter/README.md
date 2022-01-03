<img src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_contacts_group_flutter)](https://pub.dev/packages/at_contacts_group_flutter) [![pub points](https://badges.bar/at_contacts_group_flutter/pub%20points)](https://pub.dev/packages/at_contacts_group_flutter/score) [![build status](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml/badge.svg?branch=trunk)](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_contacts_group_flutter

## Introduction

A Flutter plugin project to provide group functionality with contacts using @‎platform.

## Get Started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).

### Installation:

 To use this library in your app, add it to your pubspec.yaml

``` 
  dependencies:
    at_contacts_group_flutter: ^3.1.2
```
#### Add to your project

 ```dart
 flutter pub get 
 ```
 #### Import in your application code

 ```dart
 import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
 ```
### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising:

It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The groups service needs to be initialised with the `atClient` from the `AtClientService`, current atsign and the root server.

```
initializeGroupService(
        clientSdkService.atClientServiceInstance.atClient, currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

### Usage

Navigating to the groups list is done simply by using:
```
Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => GroupList(),
    ));
```

## Example

We have a good example with explanation in the [at_contacts_group_flutter](https://pub.dev/packages/at_contacts_group_flutter/example) package.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.