<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## [at_location_flutter] example
The [at_location_flutter] package is designed to make it easy to share/receive locations between two atsigns and also see it on a map.

## How it works

Like most applications built for the  @‎platform, we start with the [at_onboarding_flutter](https://pub.dev/packages/at_onboarding_flutter) widget which handles secure management of secret keys for an atsign as cryptographically secure replacement for usernames and passwords.

We use the [Onboarding()] widget in our [main.dart] and navigate to our [second_screen.dart] after successfully onboarding.

If you want to remove any already paired atsign, use the `Clear paired atsigns` button, it will remove all the paired atsigns for this example package.

As the [at_location_flutter] package has to be initialised, so we initialise it in the [init()] of `second_screen.dart` by calling
```dart
    initializeLocationService(
      NavService.navKey,
      mapKey: '',
      apiKey: '',
      showDialogBox: true,
    );
```

The [second_screen.dart] consists of the following functions:
 - Show maps - Will navigate to the default home screen. If you want to use this functionality then navigate to the [HomeScreen()].
 - Send Location - Sends location for 30 minutes to the typed in atsign. If you want to use this functionality then call [sendShareLocationNotification()], with the receiver atsign as the first parameter and time (in minutes) as the second.
 - Request Location - Requests location from the typed in atsign. If you want to use this functionality then call [sendRequestLocationNotification()], with the receiver atsign as the first parameter.
 - Track Location - Shows the location (if available) of the typed in atsign. If you want to use this functionality then navigate to [AtLocationFlutterPlugin()] and pass in the parameters as needed.
 - Show multiple points - Displays static marker at LatLng(30,45) & LatLng(40,45). If you want to use this functionality then navigate to [showLocation()] and pass in the static geo-coordinates.
 - Notifications: Displays the list of send/received share/request locations. If you want to see the list of notifications then use the [KeyStreamService().atNotificationsStream].

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.