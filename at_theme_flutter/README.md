<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for a little internet optimism

# at_theme_flutter

A Flutter plugin project to provide theme selection in @‎platform apps with ease.

## Initialising
The theme service needs to be initialised. The root domain has to be specified.

```
initializeThemeService(
    rootDomain: MixedConstants.ROOT_DOMAIN
);
```

## Sample usage

### To get saved theme
```
AppTheme? appTheme = await getThemeData();
```

### To use custom theme
```
var appTheme = AppTheme.from();
var result = await setAppTheme(appTheme);
```