# Examples

## Using AtEnv

Loading the environment

```dart
AtEnv.load();
```

Get the root domain

```dart
var rootDomain = AtEnv.rootDomain;
```

Get the app namespace

```dart
var namespace = AtEnv.appNamespace;
```

Get the app api key

```dart
var apiKey = AtEnv.appApiKey;
```

## Using AtContext

### Get the AtContext instance from the BuildContext

```dart
AtContext atContext = AtContext.of(context);
```

### Using the AtContext instance

Get the AtClientService

```dart
AtClientService atClientService = atContext.atClientService;
```

Get the AtClientInstance

```dart
AtClientImpl? atClientInstance = atContext.atClient;
```

Get the Currently Onboarded AtSign

```dart
String? currentAtSign = atContext.currentAtSign;
```

Get the AtClientPreference

```dart
AtClientPreference atClientPreference = atContext.atClientPreference;
```

Onboard with another Atsign

```dart
atContext.switchAtsign("@example");
```
