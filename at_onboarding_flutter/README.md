<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for a little internet optimism



[![pub package](https://img.shields.io/pub/v/at_onboarding_flutter)](https://pub.dev/packages/at_onboarding_flutter) [![pub points](https://badges.bar/at_onboarding_flutter/pub%20points)](https://pub.dev/packages/at_onboarding_flutter/score)
 [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)



# at_onboarding_flutter
## Introduction
This at_onboarding_flutter package handles secure management of secret keys for authenticating an atsign as cryptographically secure replacement for usernames and passwords.

This open source package is written in Dart, supports Flutter and follows the @‎platform's decentralized, edge computing model with the following features :

- Takes care all the painstakingly difficult mechanisms of authentication of @sign.
- Supports Generate free @sign.
- Supports multiple @sign onboarding.
- Flexibility of either pair @sign with QRCode or Atkey file.
- Reset/Sign out button.

We call giving people control of access to their data “flipping the internet”
and you can learn more about how it works by reading this
[overview](https://atsign.dev/docs/overview/).


## Get Started
There are three options to get started using this package.

### 1. Quick start - generate a skeleton app with at_app
This package includes a working sample application in the
[Example](./example) directory that you can use to create a personalized
copy using ```at_app create``` in four commands.

```sh
$ flutter pub global activate at_app 
$ at_app create --sample=<package ID> <app name> 
$ cd <app name>
$ flutter run
```
Notes: 
1. You only need to run ```flutter pub global activate``` once
2. Use ```at_app.bat``` for Windows


### 2. Clone it from GitHub
<!---
Make sure to edit the link below to refer to your package repo.
-->
Feel free to fork a copy the source from the [GitHub repo](https://github.com/atsign-foundation/at_widgets). The example code contained there is the same as the template that is used by at_app above.

```sh
$ git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY
```


### 3. Manually add the package to a project

#### Setup

<details>
<summary>Android</summary>

Add the following permissions to AndroidManifest.xml

```
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    <uses-feature android:name="android.hardware.camera.flash" />
```

Also, the Android version support in app/build.gradle
```
compileSdkVersion 29

minSdkVersion 24
targetSdkVersion 29
```
</details>

<details>
<summary>IOS</summary>

Add the following permission string to info.plist

```
  <key>NSCameraUsageDescription</key>
  <string>The camera is used to scan QR code to pair your device with your @sign</string>
```

Also, update the Podfile with the following lines of code:

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        ## dart: PermissionGroup.calendar
        'PERMISSION_EVENTS=0',

        ## dart: PermissionGroup.reminders
        'PERMISSION_REMINDERS=0',

        ## dart: PermissionGroup.contacts
        'PERMISSION_CONTACTS=0',

        ## dart: PermissionGroup.microphone
        'PERMISSION_MICROPHONE=0',

        ## dart: PermissionGroup.speech
        'PERMISSION_SPEECH_RECOGNIZER=0',

        ## dart: [PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse]
        'PERMISSION_LOCATION=0',

        ## dart: PermissionGroup.notification
        'PERMISSION_NOTIFICATIONS=0',

        ## dart: PermissionGroup.sensors
        'PERMISSION_SENSORS=0'
      ]
    end
  end
end
```
</details>

<details>
<summary>macOS</summary>

Go to your project folder, macOS/Runner/DebugProfile.entitlements

For release you need to open macOS/Runner/Release.entitlements

and add the following key:

```
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```
</details>







#### Add it to to your project
Run the following command:
```sh
$ flutter pub add at_onboarding_flutter
```
-or-

Add the package to the pubspec.yaml at the root of the project.
```yaml
dependencies:
  at_onboarding_flutter: ^3.1.2
```
And then run
```sh
$ flutter pub get
```

#### Import it
Now in your Dart code, you can use:

```dart
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
```






## Usage




| Parameters              | Description                                                                                                                      |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| domain                  | Domain can differ based on the environment you are using.Default the plugin connects to 'root.atsign.org' to perform onboarding. |
| atClientPreference      | The atClientPreference to continue with the onboarding.                                                                          |
| onboard                 | Function returns atClientServiceMap on successful onboarding along with onboarded @sign.                                         |
| logo                    | This widget display in the left side of appbar if nothing given then displays nothing..                                          |
| appcolor                | The color of the screens to match with the app's aesthetics. the default value is black.                                         |
| nextScreen              | After successful onboarding will gets redirected to this screen if it is not null.                                               |
| firstTimeAuthNextScreen | After first time succesful onboarding it will get redirected to this screen if not null else it will redirects to nextScreen.    |
| rootEnvironment         | Permission to access the device's location is allowed even when the App is running in the background.                            |
| appAPIKey               | API authentication key for getting free atsigns.                                                                                 |


```dart
TextButton(
  color: Colors.black12,
  onPressed: () async {
    Onboarding(
      context: context,
      // This domain parameter is optional.
      domain: AppConstants.rootDomain,
      logo: Icon(Icons.ac_unit),
      atClientPreference: atClientPrefernce,
      appColor: Color.fromARGB(255, 240, 94, 62),
      onboard: (atClientServiceMap, atsign) {
      //assign this atClientServiceMap in the app.
      },
      onError: (error) {
       //handle the error
      },
      nextScreen: DashBoard(),
      fistTimeAuthNextScreen: Details(),
      // rootEnviroment is a required parameter for setting the environment 
      // for the onboarding flow.
      rootEnviroment: RootEnviroment.Staging,
      // API Key is mandatory for production environment.
      // appAPIKey: YOUR_API_KEY_HERE
    )
  },
  child: Text('Onboard my @sign'))
```
## Open source usage and contributions
This is open source code, so feel free to use it as is, suggest changes or 
enhancements or create your own version. See [Contribution Guideline](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md)
for detailed guidance on how to setup tools, tests and make a pull request.