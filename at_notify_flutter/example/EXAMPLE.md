<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## [at_notify_flutter] example
The [at_notify_flutter] package is designed to handle notifications in @protocol apps.

## How it works

Like most applications built for the  @‎platform, we start with the [at_onboarding_flutter](https://pub.dev/packages/at_onboarding_flutter) widget which handles secure management of secret keys for an atsign as cryptographically secure replacement for usernames and passwords.

We use the [Onboarding()] widget in our [main.dart] and navigate to our [second_screen.dart] after successfully onboarding.

If you want to remove any already paired atsign, use the `Clear paired atsigns` button, it will remove all the paired atsigns for this example package.

As the [at_notify_flutter] package has to be initialised, so we initialise it in the [init()] of `second_screen.dart` by calling
```dart
    initializeNotifyService(
      atClientManager,
      activeAtSign!,
      atClientPreference,
      rootDomain: MixedConstants.ROOT_DOMAIN,
    );
```

The [second_screen.dart] consists of the following functions:
 - @atsign - Type in the receiver atsign.
 - Enter message - Type in the message.
 - Notify Text - Send the typed in message to the atsign. If you want to use this functionality then call [notifyText()] with the required parameters.
 - Get past notifications - Navigate to a new screen, to see past notifications of the selected number of days. I you want to use this functionality then navigate to the [NotifyService()] screen.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.