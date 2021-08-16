<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for a little internet optimism
[![Pub Package](https://img.shields.io/pub/v/at_follows_flutter)](https://pub.dev/packages/at_follows_flutter)

# at_follows_flutter

A flutter plugin project to integrate follows feature for @signs.

### Android
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


### iOS
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
### Plugin description
Supports for single @sign follows feature. This plugin provides two screens:

### Follows screen
Displays all the @signs that are being followed and followers of the given @sign. Unfollow button will remove the particular @sign from following whereas follow button adds the @sign to following list.

### Add @sign to follow
Scan the QR code of an @sign or type the @sign to follow.

### Sample usage
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





