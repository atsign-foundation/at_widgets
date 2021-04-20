<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_contacts_flutter

A flutter plugin project for CRUD operations on contacts.

## Getting Started

This plugin can be added to the project as git dependency in pubspec.yaml

```
dependencies:
  at_contacts_flutter: ^1.0.0
```

### Plugin description
This plugin provides two screens:
#### Contacts
This lists the contacts. From this screen a new contact can be added. Also, an existing contact can be blocked or deleted.
#### Blocked Contacts
This screen lists the blocked contacts. It also gives the option to unblock a contact in it.

### Sample usage
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The contacts service needs to be initialised with the `atClient` from the `AtClientService`, current atsign and the root server.

```
initializeContactsService(
        clientSdkService.atClientServiceInstance.atClient, currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

Navigating to the contacts or blocked contacts is done simply by using:
```
Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ContactsScreen(),
    ));
```
or
```
Navigator.of(context).push(MaterialPageRoute(
    builder: (BuildContext context) => BlockedScreen(),
));
```