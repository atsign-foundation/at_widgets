<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

## at_contacts_group_flutter example

The at_contacts_group_flutter is designed to make it easy to add groups to a flutter app with the following features:
- Create Group
- List Groups
- Edit and Delete Groups


### Give it a try
This package includes a working sample application in the [example](https://github.com/atsign-foundation/at_widgets/tree/trunk/at_contacts_group_flutter/example) directory that demonstrates the key features of the package. To create a personalized copy, use ```at_app create``` as shown below or check it out on GitHub.

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

After onboarding, the menu screen is presented using which one can access the different functionalities offered by this package.

The package includes the following UI components:
- Group List Screen
- Group Create & Edit Screen

The package also manages all the data it needs for you.

### Initialization
The services have to be initialized by calling the init functions:
```
initializeContactsService(rootDomain: AtEnv.rootDomain);
initializeGroupService(rootDomain: AtEnv.rootDomain);
```

### Sample Usage

```
Navigator.of(context).push(MaterialPageRoute(
	builder: (BuildContext context) => GroupList(),
));
```

Like everything else we do, this package and even the sample application are open source software which means we love it when you gift us with your feedback, contributions and even any bugs that you help us to discover. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.
