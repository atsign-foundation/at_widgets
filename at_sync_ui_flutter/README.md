<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for a little internet optimism

[![Pub Package](https://img.shields.io/pub/v/at_sync_ui_flutter)](https://pub.dev/packages/at_sync_ui_flutter)

# at_sync_ui_flutter

A flutter plugin project to provide UI widgets for displaying status of sync process in @protocol apps.

### Plugin description
This plugin provides the following material and cuppertino widgets:
- AtSyncButton
- AtSyncIndicator
- AtSyncLinearProgressIndicator
- AtSyncText
- AtSyncDialog
- AtSyncSnackBar

### Sample usage

```dart
material.AtSyncButton(
    isLoading: isLoading,
    syncIndicatorColor: Colors.white,
    child: IconButton(
        icon: const Icon(Icons.android),
        onPressed: _startLoading,
    ),
),

cupertino.AtSyncButton(
    isLoading: isLoading,
    syncIndicatorColor: Colors.white,
    child: IconButton(
        icon: const Icon(Icons.phone_iphone),
        onPressed: _startLoading,
    ),
),
```