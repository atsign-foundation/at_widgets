<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_follows_flutter)](https://pub.dev/packages/at_follows_flutter) [![pub points](https://badges.bar/at_follows_flutter/pub%20points)](https://pub.dev/packages/at_follows_flutter/score) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_follows_flutter

### Introduction
A Flutter plugin project that provides a basic social "follows" functionality for @‎signs. Provides a list of followers and following for @‎signs with the option to unfollow them. It also provides services to follow, unfollow, remove from follwers list, list of followers, and list of following.

## Get Started

Initially to get a basic overview of the @protocol packages, You must read the [atsign docs](https://atsign.dev/docs/overview/).

> To use this package you must be having a basic setup, Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


### Android
Add the following permissions to AndroidManifest.xml

```xml
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

```gradle
compileSdkVersion 29 // And above

minSdkVersion 24
targetSdkVersion 29 // And above
```


### iOS
Add the following permission string to info.plist

```xml
<key>NSCameraUsageDescription</key>
<string>The camera is used to scan QR code to pair your device with your @‎sign</string>
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
### Plugin description
Supports for single @‎sign follows feature. This plugin provides two screens:

### Follows screen
Displays all the @‎signs that are being followed and followers of the given @‎sign. Unfollow button will remove the particular @‎sign from following whereas follow button adds the @‎sign to following list.

### Add @‎sign to follow
Scan the QR code of an @‎sign or type the @‎sign to follow.

### Sample usage
The plugin will takes AtClientService instance to show the follows list of an @‎sign. 

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
1. atClientserviceInstance - to perform further actions for the given @‎sign.
2. appColor - applies to plugin screens to match the app's theme. This should be bright color as it takes white font over that. Defaults to orange.
3. followerAtsignTitle - follower @‎sign received from app's notification
4. followAtsignTitle - @‎sign followed from webapp.

### Follow a @‎sign
To follow an @‎sign, call the following method:
```dart
/// Get the AtFollowServices instance
AtFollowServices atFollowServices = AtFollowServices();
Future<bool> followAtSign(String atSign)async {
  /// ... YOUR CODE ... ///
  /// Call the follow() method to follow an @‎sign
  bool isFollowed = await atFollowServices.follow(atSign);
  return isFollowed;
}
```

### Unfollow a @‎sign
To unfollow an @‎sign, call the following method and pass the @‎sign to unfollow:

```dart
Future<bool> unfollowAtSign(String atSign)async {
  /// ... YOUR CODE ... ///
  /// Call the unfollow() method to unfollow an @‎sign
  bool isUnfollowed = await atFollowServices.unfollow(atSign);
  return isUnfollowed;
}
```

### Remove a @‎sign from following list
To remove an @‎sign from following list, call the following method and pass the @‎sign to remove:
```dart
Future<bool> removeFollower(String atSign)async {
  /// ... YOUR CODE ... ///
  /// Call the removeFollower() method to remove an @‎sign from following list
  bool isRemoved = await atFollowServices.removeFollower(atSign);
  return isRemoved;
}
```

### Get the list of followers
To get the list of followers, call the following method:
```dart
Future<AtFollowsList?> getFollowers()async {
  /// ... YOUR CODE ... ///
  /// Call the getFollowersList() method to get the list of followers
  AtFollowsList? followers = await atFollowServices.getFollowersList();
  return followers;
}
```

### Get the list of following
To get the list of following, call the following method:
```dart
Future<AtFollowsList?> getFollowings()async {
  /// ... YOUR CODE ... ///
  /// Call the getFollowingList() method to get the list of following
  AtFollowsList? following = await atFollowServices.getFollowingList();
  return following;
}
```
