# at_analytics_flutter_example

In this example app we demo at_analytics_flutter - A Flutter plugin project to provide a bug reporting feature feature to any Flutter application.


### Generate a new at_app

  ```bash
  at_app create --sample=<package ID> -n=<YOUR NAME SPACE> <APP NAME>
  ```

  > There are 2 more arguments called root-domain (-r) and api-key (-k) which are currently not required. For more details head over to [at_app Flags](https://pub.dev/packages/at_app#executable) documentation.

**What will be this doing?**
  - This command will generate a simple skeleton of your at_app.
  - Go to the `.env` file and add your namespace if you haven't passed it as an argument.


### Run your project

  ```bash
  flutter run
  ```


### Start Coding

  By default, there will be at_onboarding_flutter widget implemented in your project. But, we need to make little changes to it.

#### Login Screen

  - Select the whole Scaffold widget (including body) and hit `Ctrl + .`(Windows/Linux) or `⌘ + .`(Mac) and select **Extract Widget**.
  - Name that widget `LoginScreen` and hit Enter.
  - Now, you will see a new widget called `LoginScreen` in your project.
  - Now let us add some properties values to onboarding widget.

  > **NOTE :** If you using [VisualStudio Code](https://code.visualstudio.com/), You will be catching an Exception called *AtSign not found*. This is because, `Uncaught Exceptions` is checked by default.
  > Ignore this line in debug console - `I/flutter (20332): SEVERE|2021-12-20 19:21:25.593804|AtClientService|Atsign not found`

  ```dart
  AtClientPreference? atClientPreference;
  String? atSign;
  /// Login Screen
  Widget build(context){
  /// ... other widgets ... ///
    Onboarding(
      context: context,
      atClientPreference: atClientPreference!,
      domain: AtEnv.rootDomain,
      appColor: const Color(0xFFF05E3E),
      onboard: (Map<String?, AtClientService> value, String? atsign) {
        atSign = atsign;
        _logger.finer('Successfully onboarded $atsign');
      },
      onError: (Object? error) {
        _logger.severe('Onboarding throws $error error');
      },
      nextScreen: HomeScreen(),
      appAPIKey: AtEnv.appApiKey,
      rootEnvironment: AtEnv.rootEnvironment,
    );
    /// ... ///
  }
  ```
  
### Sample Usage

Initialize Bug Report Service

```dart
initializeBugReportService(atClientService!.atClientManager,
        MixedConstants.authorAtsign, activeAtSign!, atClientPreference!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

Bug Report Dialog

```dart
     showBugReportDialog(
                      context,
                      activeAtSign,
                      MixedConstants.authorAtsign,
                      bugReport,
                      isSuccessCallback: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'Share Successfully',
                            ),
                          ),
                        );
                      },
                    );
```

To Send Error Report

```dart
sendErrorReport(
                        'custom error', context, MixedConstants.authorAtsign,
                        () {
                      print('success in sending report');
                    });
``` 

To Display list of bug reports

```dart
ListBugReportScreen(
                          atSign: activeAtSign,
                          authorAtSign: MixedConstants.authorAtsign,
                        ),
```