<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## [at_sync_ui_flutter] example
The [at_sync_ui_flutter] package is designed to make it easy for displaying status of sync process in @protocol apps.

## How it works

Like most applications built for the  @‎platform, we start with the [at_onboarding_flutter](https://pub.dev/packages/at_onboarding_flutter) widget which handles secure management of secret keys for an atsign as cryptographically secure replacement for usernames and passwords.

We use the [Onboarding()] widget in our [main.dart] and navigate to our [second_screen.dart] after successfully onboarding.

If you want to remove any already paired atsign, use the `Clear paired atsigns` button, it will remove all the paired atsigns for this example package.

As the [at_sync_ui_flutter] package has to be initialised, so we initialise it in the [init()] of `second_screen.dart` by calling
```dart
    AtSyncUIService().init(
        appNavigator: NavService.navKey,
        onSuccessCallback: _onSuccessCallback,
        onErrorCallback: _onErrorCallback,
    );
```

The [second_screen.dart] consists of the following functions:
 - Default Sync - Will call the sync function and show the UI selected in the `init()` of `AtSyncUIService()`.
 - Sync with dialog overlay -  Will call the sync function and show the dialog with an overlay. The background will not be responsive.
 - Sync with snackbar - Will call the sync function and show the snackbar with an overlay. The background will be responsive.
 - See all UI options - Will navigate to `UIOptions()` screen which displays all type of UI options available in the package.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.