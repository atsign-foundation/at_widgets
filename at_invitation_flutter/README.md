<img src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_invitation_flutter)](https://pub.dev/packages/at_invitation_flutter) [![pub points](https://badges.bar/at_invitation_flutter/pub%20points)](https://pub.dev/packages/at_invitation_flutter/score) [![build status](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml/badge.svg?branch=trunk)](https://github.com/atsign-foundation/at_client_sdk/actions/workflows/at_client_sdk.yaml) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)


# at_invitation_flutter

## Introduction

A Flutter package to share data and invite contacts using SMS or email to the @platform.

## Get Started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


### Installation:

 To use this library in your app, add it to your pubspec.yaml

``` 
  dependencies:
    at_invitation_flutter: ^1.0.1
```
#### Add to your project

 ```dart
 flutter pub get 
 ```
 #### Import in your application code

 ```dart
 import 'package:at_invitation_flutter/at_invitation_flutter.dart';
 ```
### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising:
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The invitation service needs to be initialised with the `AtClientService` instance, current atsign, a global navigator key and a url of web page to use for launching and redirection.

```
initializeInvitationService(
        navkey: scaffoldKey,
        atClientInstance: clientSdkService.atClientServiceInstance?.atClient,
        currentAtSign: activeAtSign,
        webPage: 'https://xxxx',
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

The app also needs to handle deep links and handle incoming link with parameters.
The [uni_links](https://pub.dev/packages/uni_links) package can be used for this.


### Webpage requirements
A webpage with app information like store links will be required. It also needs to have the javascript functions provided in this [file](https://github.com/atsign-foundation/at_widgets/tree/trunk/at_invitation_flutter/webpage_content/cookieManager.js). The function `checkAndWriteCookie` needs to be called on the `onLoad` event of the webpage.

### Caveats
- This will not work if the the user disables cookies in browser.
- In Android, Chrome browser does not support automatic redirection back to app. User will have to tap on the link at top of the page to return to the app.
  
### Usage

### Share a Invite
```
onPressed: () 
{
  shareAndInvite(context, 'welcome');
}
```

### Fetch a Invite
```
fetchInviteData(context, queryParameters['key'] ?? '',
              queryParameters['atsign'] ?? '');
```

## Example

We have a good example with explanation in the [at_invitation_flutter](https://pub.dev/packages/at_invitation_flutter/example) package.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.