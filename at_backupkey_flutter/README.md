<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for a little internet optimism

[![Pub Package](https://img.shields.io/pub/v/at_backupkey_flutter)](https://pub.dev/packages/at_backupkey_flutter)

# at_backupkey_flutter

A flutter plugin project to provide backup keys of an @sign generated during onboarding flow of @protocol.

### Android
Add the following permissions to AndroidManifest.xml

```
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

Also, the Android version support in app/build.gradle
```
compileSdkVersion 29

minSdkVersion 24
targetSdkVersion 29
```
### iOS
Update the Podfile with the following lines of code:

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
### macOS:
Go to your project folder, macOS/Runner/DebugProfile.entitlements

For release you need to open macOS/Runner/Release.entitlements

and add the following key:

```
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

### Plugin description
Provides backup keys for an @sign. Can be used as an icon or a button. Priorily an @sign should be authenticated through any of @protocol apps to make use of this widget.

### Sample usage
Provides '.atKeys' file to save it in iCloud/Gdrive.

Plugin as icon
```dart
BackupKeyWidget(
    atsign: atsign,
    atClientService: atClientServiceMap[atsign],
    isIcon: true,
)
```

Plugin as button
```dart
BackupKeyWidget(
    atsign: atsign,
    atClientService: atClientServiceMap[atsign],
    isButton: true,
    buttonText: 'BackupKeys',
)
```

Plugin with custom widget
```dart
ElevatedButton.icon(
    icon: Icon(
        Icons.file_copy,
        color: Colors.white,
    ),
    label: Text('Backup your key'),
    onPressed: () async {
        BackupKeyWidget(
            atsign: atsign,
            atClientService: atClientServiceMap[atsign],
        ).showBackupDialog(context);
    },
),
```