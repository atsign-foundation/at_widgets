<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

## at_backupkey_flutter example
The at_backupkey_flutter package is designed to make it easy to take backup of secret keys in any Flutter app on the atPlatform.

### Give it a try
This package includes a working sample application in the [example](https://github.com/atsign-foundation/at_widgets/tree/trunk/packages/at_backupkey_flutter/example) directory that demonstrates the key feature of this package. To create a personalized copy, use ```at_app create``` as shown below or check it out on GitHub.

```sh
$ flutter pub global activate at_app 
$ at_app create --sample=<package ID> <app name> 
$ cd <app name>
$ flutter run
```
Notes: 
1. You only need to run ```flutter pub global activate``` once
2. Use ```at_app.bat``` for Windows


## How it works

Like most applications built for the atPlatform, we start with the [at_onboarding_flutter](https://pub.dev/packages/at_onboarding_flutter) widget which handles secure management of secret keys for an atsign as cryptographically secure replacement for usernames and passwords.

After onboarding, the UI widget provided in this package can be placed in the app.

The package includes the following UI widgets:
- BackupKeyWidget icon button
- A dialog to prompt backup

You don't have to do anything to customize the theme as it is already designed to pick up the theme from parent app.

The package also manages all the data it needs for you.

The sample usage of these widgets are as follows:
#### BackupKeyWidget icon
```
BackupKeyWidget(
    atsign: this.atsign,
    atClientService: this.atClientServiceMap[atsign],
),                        
```

#### BackupKeyWidget dialog
```
BackupKeyWidget(
    atsign: atsign,
    atClientService: atClientServiceMap[atsign],
).showBackupDialog(context);
```


Like everything else we do, this package and even the sample application are open source software which means we love it when you gift us with your feedback, contributions and even any bugs that you help us to discover. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.