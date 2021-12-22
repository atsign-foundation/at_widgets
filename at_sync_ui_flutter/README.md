<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for a little internet optimism

[![Pub Package](https://img.shields.io/pub/v/at_sync_ui_flutter)](https://pub.dev/packages/at_sync_ui_flutter)

# at_sync_ui_flutter

A flutter plugin project to provide UI widgets for displaying status of sync process in @protocol apps.

## Get started:

### Installation:
To use this library in your app, add it to your pubspec.yaml

```yaml  
dependencies:
  ...
  at_sync_ui_flutter: ^1.0.0
```
Import package.
```dart  
//If you want to use Material style
import 'package:at_sync_ui_flutter/at_sync_material.dart';

//If you want to use Cupertino style
import 'package:at_sync_ui_flutter/at_sync_cupertino.dart';
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