# atsign_authentication_helper

A flutter plugin project to cover the onboarding flow of @protocol.

## Getting Started

This plugin can be added to the project as git dependency in pubspec.yaml

```
dependencies:
  atsign_authentication_helper:
    git:
        url: git@github.com:atsign-foundation/at_widgets.git
	      path: atsign_authentication_helper
	      ref: dev_env
```


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
This plugin provides two screens:
## QR scanner screen
This helps in CRAM authentication. The user can scan a QR code using the camera or upload the image file of the QR code
There is also an option to pair the AtSign using the `Upload key file` option. A zip file of the restore keys or providing both the backup files of AtKeys (multiple select) will work.
## Screen to save keys
This screen will help to save the restore keys generated after a successful CRAM authentication in a zip format. The continue option navigates to the screen provided in the `nextScreen` parameter.

It is expected that the app will first create an AtClientService instance using the preferences and pass it to the plugin in the `atClientServiceInstance` parameter. Also, the navigation decision can be covered in the app logic.

Sample usage:
```
FlatButton(
  color: Colors.black12,
  onPressed: () async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQrScreen(
          atClientServiceInstance: clientSdkService
            .atClientServiceInstance,
          nextScreen: SecondScreen())));
  },
  child: Text('Show QR scanner screen')))
```
