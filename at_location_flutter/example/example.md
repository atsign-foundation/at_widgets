# at_location_flutter_example

In this example app we demo at_location_flutter - A Flutter package to send / receive locations between @‎signs built on the @‎platform to any Flutter application.

### Run your project

  ```bash
  flutter run
  ```

## Screens:

1. main.dart: 

```
It consists of two buttons, 

Start onboarding - On tap you will be logged in with an already authenticated atsign or moved to the onboarding screen to login with a new atsign.

Clear paired atsigns - If you want to remove any already paired atsign, use this button.
```

2. second_screen.dart: After successfully onboarding an atsign, we move to the second_screen.

```
It consists of the following functions, 

Show maps - Will navigate to the default home screen.

Send Location - Sends location for 30 minutes to the typed in atsign.

Request Location - Requests location from the typed in atsign.

Track Location - Shows the location (if available) of the typed in atsign.

Show multiple points - Displays static marker at LatLng(30,45) & LatLng(40,45),

Notifications: Displays the list of send/received share/request locations.
```