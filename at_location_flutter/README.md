<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_location_flutter

A flutter plugin project to share location between two atsigns.

## Getting Started

This plugin can be added to the project as git dependency in pubspec.yaml

```
dependencies:
  at_location_flutter: ^0.0.3
```

### Sample usage
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The location service needs to be initialised with the `atClient` from the `AtClientService`, current atsign and a global navigator key.

```
initializeLocationService(
          clientSdkService.atClientServiceInstance.atClient,
          activeAtSign,
          NavService.navKey);
```

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
