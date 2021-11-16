<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_notify_flutter

A flutter plugin project to handle notifications in @protocol apps.

### Initialising
The notify service needs to be initialised. It is expected that the app will first create an AtClientService instance using the preferences and then use it to initialise the notify service.

```
initializeNotifyService(
      clientSdkService.atClientServiceInstance!.atClientManager,
      activeAtSign!,
      clientSdkService.atClientPreference,
      rootDomain: MixedConstants.ROOT_DOMAIN,
    );
```

### Sample Usage

Call notify
```
notify(
   context,
   'activeAtSign',
   'toAtSign',
   'message',
);
```