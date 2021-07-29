<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_invitation_flutter

A flutter plugin to share data and invite contacts using SMS or email.

## Getting Started

This plugin can be added to the project as git dependency in pubspec.yaml

```
dependencies:
  at_invitation_flutter: ^0.0.1
```

### Sample usage
It is expected that the app will first create an AtClientService instance and authenticate an atsign.

The invitation service needs to be initialised with the `AtClientService` instance, current atsign, a global navigator key and a url of web page to use for launching and redirection.

```
initializeInvitationService(
        navkey: scaffoldKey,
        atClientInstance: clientSdkService.atClientServiceInstance?.atClient,
        currentAtSign: activeAtSign,
        webPage: 'https://xxxx',
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

The app also needs to handle deep links and handle incoming link with parameters.
The [uni_links](https://pub.dev/packages/uni_links) package can be used for this.