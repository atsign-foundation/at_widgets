<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_notify_flutter

A flutter plugin to handle notify.

## Getting Started

This plugin handles notify.

### Initialising
The notify service needs to be initialised. It is expected that the app will first create an AtClientService instance using the preferences and then use it to initialise the notify service.

```
initializeNotifyService(
        clientSdkService.atClientServiceInstance.atClient, activeAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
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