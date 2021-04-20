<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_chat_flutter

A flutter plugin to provide chat feature between two atsigns.

## Getting Started

This plugin provides a chat screen - ChatScreen that can be accessed as a bottom sheet or as a navigated screen.

### Initialising
The chat service needs to be initialised. It is expected that the app will first create an AtClientService instance using the preferences and then use it to initialise the chat service.

```
initializeChatService(
        clientSdkService.atClientServiceInstance.atClient, activeAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

### Sample Usage

As a bottom sheet
```
FlatButton(
    onPressed: () {
        scaffoldKey.currentState
        .showBottomSheet((context) => ChatScreen());
    },
    child: Container(
        height: 40,
        child: Text('Open chat in bottom sheet'),
    ),
),
```

As a screen
```
class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Screen')),
      body: ChatScreen(
        height: MediaQuery.of(context).size.height,
        incomingMessageColor: Colors.blue[100],
        outgoingMessageColor: Colors.green[100],
        isScreen: true,
      ),
    );
  }
}
```