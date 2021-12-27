# at_location_flutter_example_app

In this example app we demo at_location_flutter - A flutter plugin project to share location between @‎signs built on the @‎platform to any Flutter application.


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
<!-- TODO - ADD SCREENSHOTS OF YOUR EXAMPLE APPLICATION -->

## Example app screen

<table>
<tr>
<td><img src="https://github.com/atsign-foundation/at_widgets/blob/feat/documentation/at_chat_flutter/example/onboarding_screen.png"  width="210" height="440" /></td>

<td><img src="https://github.com/atsign-foundation/at_widgets/blob/feat/documentation/at_chat_flutter/example/chat_screen.png"  width="210" height="440" /></td>
<td><img src="https://github.com/atsign-foundation/at_widgets/blob/feat/documentation/at_chat_flutter/example/chat_options.png"  width="210" height="440" /></td>
<td><img src="https://github.com/atsign-foundation/at_widgets/blob/feat/documentation/at_chat_flutter/example/chat_bottomsheet.png"  width="210" height="440" /></td>
<td><img src="https://github.com/atsign-foundation/at_widgets/blob/feat/documentation/at_chat_flutter/example/chat_screen_private.png"  width="210" height="440" /></td>
</tr>
</table>