# at_theme_flutter_example

Demonstrates how to use the at_theme_flutter plugin.

### Sample Usage

To get saved theme
```dart
AppTheme? appTheme = await getThemeData();
```

To use custom theme
```dart
var appTheme = AppTheme.from();
var result = await setAppTheme(appTheme);
```

