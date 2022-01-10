
<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

### Now for a little internet optimism
[![Pub Package](https://img.shields.io/pub/v/at_follows_flutter)](https://pub.dev/packages/at_follows_flutter) [![pub points](https://badges.bar/at_follows_flutter/pub%20points)](https://pub.dev/packages/at_follows_flutter/score)  [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_follows_flutter 

A flutter package for implementing the **follow** feature. 

Built to work with the @platform, this package can be used to implement the "follows" and "following" features for flutter applications.

---

### Features 

The at_follows_flutter package implements the follow/unfollow feature just like on popular social media. Add this package to your flutter app to:
- Implement the "follows" and "following" feature for your flutter application.
- Follow/unfollow any active @sign from our @sign
- Collect and show the @signs *followed by* and *following* a particular @sign.

---

## Get started
There are three options to get started using this package.

<!---
If the package has a template that at_app uses to generate a skeleton app,
that is the quickest way for a developer to assess it and get going with
their app.
-->
### 1. Quick start - generate a skeleton app with at_app
This package includes a working sample application in the
[Example](./example) directory that you can use to create a personalized copy using ```at_app create``` in four commands.

```sh
$ flutter pub global activate at_app 
$ at_app create --sample=<package ID> <app name> 
$ cd <app name>
$ flutter run
```
Notes: 
1. You only need to run ```flutter pub global activate``` once
2. Use ```at_app.bat``` for Windows


<!---
Cloning the repo and example app from GitHub is the next option for a
developer to get started.
-->
### 2. Clone it from GitHub
<!---
Make sure to edit the link below to refer to your package repo.
-->
Feel free to fork a copy the source from the [GitHub repo](https://github.com/atsign-foundation/at_client_sdk). The example code contained there is the same as the template that is used by at_app above.

```sh
$ git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY
```

<!---
The last option is to use the traditionaL instructions for adding the package to a project. This is basically the content generated on pub.dev under the "Installing" tab.
-->
### 3. Manually add the package to a project

#### Add it to to your project
Run the following command:
```sh
$ flutter pub add at_client_mobile
```
-or-

Add the package to the pubspec.yaml at the root of the project.
```yaml
dependencies:
  at_client_mobile: ^3.1.2
```
And then run
```sh
$ flutter pub get
```

#### Import it
Now in your Dart code, you can use:

```dart
import 'package:at_client_mobile/at_client_mobile.dart';
``` 

#### How it works

<!---
Add details on how to setup the package
-->
## Setup

<!---
Add details on how to use the package in an application
-->

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
targetSdkVersion 30
```
</details>

<details>
<summary>iOS</summary>


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

### Plugin description
Supports for single @sign follows feature. This plugin provides two screens:

### Follows screen
Displays all the @signs that are being followed and followers of the given @sign. Unfollow button will remove the particular @sign from following whereas follow button adds the @sign to following list.

### Add @sign to follow
Scan the QR code of an @sign or type the @sign to follow.



## Sample usage
The plugin will takes AtClientService instance to show the follows list of an @sign. 

```
TextButton(
  color: Colors.black,
  onPressed: () {
    Navigator.push(
          ctxt,
          MaterialPageRoute(
              builder: (context) => Connections(
                  atClientserviceInstance: atClientServiceInstance,
                  appColor: Colors.blue)));
  },
  child: Text('AtFollows')
)
```

##### Plugin parameters
1. atClientserviceInstance - to perform further actions for the given @sign.
2. appColor - applies to plugin screens to match the app's theme. This should be bright color as it takes white font over that. Defaults to orange.
3. followerAtsignTitle - follower @sign received from app's notification
4. followAtsignTitle - @sign followed from webapp.

## Open source usage and contributions
This is  open source code, so feel free to use it as is, suggest changes or 
enhancements or create your own version. See [CONTRIBUTING.md](CONTRIBUTING.md) 
for detailed guidance on how to setup tools, tests and make a pull request.


<!---
Make sure your source code annotations are clear and comprehensive.
-->
For more information, please see the API documentation listed on pub.dev.

<!---
If we have any pages for these docs on atsign.dev site, it would be 
good to add links.(optional)
-->
### Learn More
To learn more about this package or the @platform, visit [atsign.dev](https://atsign.dev/)

Get Started with the @platform by [setting up a project](https://atsign.dev/docs/get-started/create-a-project/).

<!---
You should include language like below if you would like others to contribute
to your package.
-->


<!---
Have we correctly acknowledged the work of others (and their Trademarks etc.)
where appropriate (per the conditions of their LICENSE?
-->

<!--- ## Acknowledgement/attribution

-->

<!---
Who created this?  
Do they have complete GitHub profiles?  
How can they be contacted?  
Who is going to respond to pull requests?  
-->

<!---
## Maintainers

-->

<!--- Add SEO researched keywords here for the package 
-->
*Tags*

Making follows and unfollows button in Flutter using @platform, 
How to create a follow and unfollow feature in Flutter, 
Follow, 
Follows, 
Followers, 
Following, 
Unfollow, 
Atsign, 
@sign, 





