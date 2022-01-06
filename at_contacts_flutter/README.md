<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

## Now for some internet optimism.

[![pub package](https://img.shields.io/pub/v/at_contacts_flutter)](https://pub.dev/packages/at_contacts_flutter) [![pub points](https://badges.bar/at_contacts_flutter/pub%20points)](https://pub.dev/packages/at_contacts_flutter/score) [![gitHub license](https://img.shields.io/badge/license-BSD3-blue.svg)](./LICENSE)

# at_contacts_flutter

### Introduction

at_contacts_flutter library persists contacts across different @platform applications. This is a Flutter plugin project that provides an ease of managing contacts for an @‎sign built on the @‎platform.

## Get Started

To get a basic overview of the @protocol packages, Please visit the [atsign docs](https://atsign.dev/docs/overview/).

> A basic setup is required to use this package. Follow here to [get started](https://atsign.dev/docs/get-started/setup-your-env/).


This plugin provides two screens:

## Usage

Initialize the contact services initially by calling    `initializeContactsService()` function.

```dart
@override
void initState() {
    super.initState();
    initializeContactsService(rootDomain: AppConstants.rootDomain);
}
```

- Dispose any dispose stream controllers of the pacakge from the app level.

```dart
@override
void dispose(){
    disposeContactsControllers();
    super.dispose();
}
```

- Get an atSign details.

```dart
TextButton(
    onPressed: () async {
        AtContact _userContact = await getAtSignDetails(_atSign);
        print(_userContact);
    },
    child: Text('Get Details'), 
),
```

- Get cached contact details

```dart
TextButton(
    onPressed: () async {
        AtContact? _userContact = await getCachedContactDetail(_atSign);
        print(_userContact ?? 'No cached contact found');
    },
    child: Text('Get Cached Details'), 
),
```

### Contacts

This lists the contacts. From this screen a new contact can be added. This screen is exposed from the library for displaying, adding, selecting and deleting Contacts.

- If the user wants to go to the contacts list screen, call `ContactsScreen()` Widget in Navigator.

```dart
TextButton(
    onPressed: () async {
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (BuildContext context) => ContactsScreen(),
            ),
        );
    },
    child: Text('Contacts'), 
),
```

### Blocked Contacts

This screen lists the blocked contacts. It also gives the option to unblock a contact in it.

- If the user wants to go to the block list screen, call `BlockedScreen()` Widget in Navigator.

```dart
TextButton(
    onPressed: () async {
        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (BuildContext context) => BlockedScreen(),
            ),
        );
    },
    child: Text('Blocked List'), 
),
```
