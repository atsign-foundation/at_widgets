# at_location_flutter_example

In this example app we demo at_events_flutter - A Flutter package to manage events between @‎signs built on the @‎platform to any Flutter application.

### Run your project

  ```bash
  flutter run
  ```

## Screens:

1. main.dart: 

It consists of two buttons:
 - Start onboarding - On tap you will be logged in with an already authenticated atsign or moved to the onboarding screen to login with a new atsign.
 - Clear paired atsigns - If you want to remove any already paired atsign, use this button.



2. second_screen.dart: After successfully onboarding an atsign, we move to the second_screen.

It consists of the following functions:
 - @atsign - Type in the receiver atsign.
 - Enter message - Type in the message.
 - Notify Text - Send the typed in message to the atsign.
 - Get past notifications - Navigate to a new screen, to see past notifications of the selected number of days.