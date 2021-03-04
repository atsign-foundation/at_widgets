# at_onboarding_flutter

A flutter plugin project to cover the onboarding flow of @protocol apps.

## Getting Started

To use this plugin in app, first add it to pubspec.yaml

```
dependencies:
  at_onboarding_flutter: ^1.0.0
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
Supports for single and multiple @signs onboarding. This plugin provides two screens:

#### Pair @sign screen
The user have to enter the @sign to pair. Based on the @sign status user can either pair their @sign with the QRcode or backup zip file.

1. Pair with QRcode
The user can scan a QR code using the camera or upload the image file of the QR code

2. Pair with Backup Key file
Click on `Upload backup key file` to upload a zip file of the restore keys or providing both the backup files of AtKeys (multiple select) will work.

#### Screen to save keys
This screen will help to save the restore keys generated after a successful CRAM authentication in a zip format. The continue option navigates to the screen provided in the `nextScreen` parameter.

### Sample usage
The plugin will return a Map<String, AtClientService> on successful onboarding and  throws an error if encounters any. Also, the navigation decision can be covered in the app logic.

```
FlatButton(
  color: Colors.black12,
  onPressed: () async {
    Onboarding(
      context: context,
      logo: Icon(Icons.ac_unit),
      atClientPreference: atClientPrefernce,
      domain: AppConstants.rootDomain,
      appColor: Color.fromARGB(255, 240, 94, 62),
      onboard: (atClientServiceMap, atsign) {
      //assign this atClientServiceMap in the app.
      },
      onError: (error) {
       //handle the error
      },
      nextScreen: DashBoard(),
      fistTimeAuthNextScreen: Details()
    )
  },
  child: Text('Onboard my @sign'))
```