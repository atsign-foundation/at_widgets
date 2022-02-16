<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for a little internet optimism

[![Pub Package](https://img.shields.io/pub/v/at_sync_ui_flutter)](https://pub.dev/packages/at_sync_ui_flutter)

# at_sync_ui_flutter

A flutter plugin project to provide UI widgets for displaying status of sync process in @protocol apps.

## Get started:

Initially to get a basic overview of the SDK, you must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).

### Manually add the package to a project:

Instructions on how to manually add this package to you project can be found on pub.dev [here](https://pub.dev/packages/at_sync_ui_flutter/install).

### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

 ### Initialising:
It is expected that the app will first authenticate an atsign using the Onboarding widget.

The `AtSyncUIService` needs to be initialised with a required GlobalKey<NavigatorState> parameter for
navigation purpose (make sure the key is passed to the parent [MaterialApp]), the rest being optional parameters.

```dart
    AtSyncUIService().init(
        appNavigator: navKey,
        style: _atSyncUIStyle,
        onSuccessCallback: _onSuccessCallback,
        onErrorCallback: _onErrorCallback,
      );
```

The app can select:

- the style of the UI either `Material` or `Cupertino` by passing the `style` param to [init()] call.
- the type of overlay to be shown while syncing either `Dialog` or `Snackbar` by passing the `atSyncUIOverlay` param to [init()] call.
- the `onSuccessCallback` will be called everytime sync completes with success.
- the `onErrorCallback` will be called everytime sync completes with failure.
- the `primaryColor`, `backgroundColor`, `labelColor` will be used while displaying overlay/snackbar.

### Usage

To call sync and show selected UI:

```dart
    AtSyncUIService().sync(
        atSyncUIOverlay: AtSyncUIOverlay.snackbar,
    );
```

### Plugin description
This plugin provides the following material and cuppertino widgets:
- AtSyncButton
- AtSyncIndicator
- AtSyncLinearProgressIndicator
- AtSyncText
- AtSyncDialog
- AtSyncSnackBar

### Sample usage

**AtSyncButton**
```dart
AtSyncButton(
    isLoading: isLoading,
    syncIndicatorColor: Colors.white,
    child: IconButton(
        icon: const Icon(Icons.android),
        onPressed: ...,
    ),
)
```

**AtSyncIndicator**
```dart
AtSyncIndicator(
    value: progress,
    color: _indicatorColor,
)
```

**AtSyncLinearProgressIndicator**
```dart
AtSyncLinearProgressIndicator(
    value: progress,
    color: _indicatorColor,
)
```

**AtSyncText**
```dart
AtSyncText(
    value: progress,
    child: const Text('completed'),
    indicatorColor: _indicatorColor,
)
```

**AtSyncDialog**
```dart
final dialog = material.AtSyncDialog(context: context);
dialog.show(message: 'Downloading ...');
dialog.update(value: _value, message: 'Downloading ...');
dialog.close();
```

**AtSyncSnackBar**
```dart
final snackBar = material.AtSyncSnackBar(context: context);
snackBar.show(message: 'Downloading ...');
snackBar.update(value: _value, message: 'Downloading ...');
snackBar.dismiss();
```

## Example

We have a good example with explanation in the [at_sync_ui_flutter](https://pub.dev/packages/at_sync_ui_flutter/example) package.

## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.