<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_invitation_flutter

A Flutter package to share data and invite contacts using SMS or email to the @platform.

## Getting Started

This package can be used to generate the invite link with passcode and handle connecting the invitee to the inviter on the @platform.
Please refer to [documentation](https://github.com/atsign-foundation/at_widgets/tree/trunk/at_invitation_flutter/website_content/overview.md).

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

### Webpage requirements
A webpage with app information like store links will be required. It also needs to have the javascript functions provided in the [file](https://github.com/atsign-foundation/at_widgets/tree/trunk/at_invitation_flutter/webpage_content/cookieManager.js)
The function `checkAndWriteCookie` needs to be called on the `onLoad` event of the webpage.