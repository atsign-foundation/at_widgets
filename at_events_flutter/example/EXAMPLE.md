<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## [at_events_flutter] example
The [at_events_flutter] package is designed to make it easy to manage events between atsigns.

## How it works

Like most applications built for the  @‎platform, we start with the [at_onboarding_flutter](https://pub.dev/packages/at_onboarding_flutter) widget which handles secure management of secret keys for an atsign as cryptographically secure replacement for usernames and passwords.

We use the [Onboarding()] widget in our [main.dart] and navigate to our [second_screen.dart] after successfully onboarding.

If you want to remove any already paired atsign, use the `Clear paired atsigns` button, it will remove all the paired atsigns for this example package.

As the [at_events_flutter] package has to be initialised, so we initialise it in the [init()] of `second_screen.dart` by calling
```dart
    initialiseEventService(NavService.navKey,
        mapKey: '',
        apiKey: '',
        rootDomain: 'root.atsign.org',
        streamAlternative: updateEvents
    );
```

NOTE: The [at_events_flutter] depends on [at_location_flutter] for location sharing, so we use the default value of [initLocation] (true) in [initialiseEventService()].

We also pass a function [updateEvents] to [initialiseEventService()] in the [streamAlternative] parameter which will give us a list of updated events from the [at_events_flutter] package.

The [second_screen.dart] consists of the following functions:
  - Create event - Will build the default create event bottomsheet. To use this functionality call [CreateEvent()].
  - Move to the map screen for an event - Call [HomeEventService().onEventModelTap()] and pass in the event parameter.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.