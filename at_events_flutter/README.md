<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_events_flutter

A flutter plugin project to manage events.

### Sample usage
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The event service needs to be initialised with the `atClient` from the `AtClientService` and the root server.

```
initialiseEventService(
  clientSdkService.atClientServiceInstance.atClient,
  NavService.navKey,
  rootDomain: MixedConstants.ROOT_DOMAIN,
  mapKey: 'xxxx',
  apiKey: 'xxxx');
```

To create a new event:
```
await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: StadiumBorder(),
    builder: (BuildContext context) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12.0),
            topRight: const Radius.circular(12.0),
          ),
        ),
        child: CreateEvent(),
      );
    });
```

Navigating to the events list is done simply by using:
```
Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventList(),
      ),
    );
```

### Steps to get mapKey

  - Go to https://cloud.maptiler.com/maps/streets/
  - Click on `sign in` or `create a free account`
  - Come back to https://cloud.maptiler.com/maps/streets/ if not redirected automatically
  - Get your key from your `Embeddable viewer` input text box 
    - Eg : https://api.maptiler.com/maps/streets/?key=<YOUR_MAP_KEY>#-0.1/-2.80318/-38.08702
  - Copy <YOUR_MAP_KEY> and use it.

### Steps to get apiKey

  - Go to https://developer.here.com/tutorials/getting-here-credentials/ and follow the steps
