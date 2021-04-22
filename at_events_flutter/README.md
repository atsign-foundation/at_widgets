<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_events_flutter

A flutter plugin project to manage events.

## Getting Started

This plugin can be added to the project as git dependency in pubspec.yaml

```
dependencies:
  at_events_flutter: ^1.0.0
```

### Sample usage
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The event service needs to be initialised with the `atClient` from the `AtClientService` and the root server.

```
initialiseEventService(clientSdkService.atClientServiceInstance.atClient,
    rootDomain: MixedConstants.ROOT_DOMAIN);
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
