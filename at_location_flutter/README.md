<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_location_flutter)](https://pub.dev/packages/at_location_flutter) [![](https://img.shields.io/static/v1?label=Backend&message=@Platform&color=<COLOR>)](https://atsign.dev) [![](https://img.shields.io/static/v1?label=Publisher&message=The%20@%20Company&color=F05E3E)](https://atsign.com) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_location_flutter

## Introduction

A flutter package to share and receive location between two atsigns.

## Get Started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


### Manually add the package to a project:

Instructions on how to manually add this package to you project can be found on pub.dev [here](https://pub.dev/packages/at_location_flutter/install).

### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising:
It is expected that the app will first authenticate an atsign using the Onboarding widget.

The location service needs to be initialised with a required GlobalKey<NavigatorState> parameter for
navigation purpose (make sure the key is passed to the parent [MaterialApp]), the rest being optional parameters.

```dart
await initializeLocationService(
      navKey,
      mapKey: 'xxxx',
      apiKey: 'xxxx',
      showDialogBox: true,
      streamAlternative: (__){},
      isEventInUse: true, 
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

### Usage

To share location with an atsign for 30 minutes:
```
sendShareLocationNotification(receiver, 30);
```

To request location from an atsign:
```
sendRequestLocationNotification(receiver);
```

To view location of atsigns:
```
AtLocationFlutterPlugin(
  ['atsign1', 'atsign2', ...]
)
```

To use the default map view:
```
Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapScreen(
                currentAtSign: AtLocationNotificationListener().currentAtSign,
                userListenerKeyword: locationNotificationModel,
              )),
    );
```

To use the default home screen view:
```
Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(),
    ));
```

Different datatypes used in the package:
```
 - LocationNotificationModel: Contains the details of a share/request location and is sent to atsigns while sharing / requesting.
 - LocationDataModel: Gets transferred in the background, contains the actual geo-coordinates and other details.
 - KeyLocationModel - The package uses this to keep a track of all the share/request notifications.
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
