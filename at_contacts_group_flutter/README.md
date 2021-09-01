<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_contacts_group_flutter

A flutter plugin to provide group functionality for atsign contacts. Helps to manage contacts.

### Sample usage
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The groups service needs to be initialised with the `atClient` from the `AtClientService`, current atsign and the root server.

```
initializeGroupService(
        clientSdkService.atClientServiceInstance.atClient, currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

Navigating to the groups list is done simply by using:
```
Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => GroupList(),
    ));
```
