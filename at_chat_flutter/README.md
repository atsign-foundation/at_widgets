<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_chat_flutter

## Overview:

A flutter plugin to provide chat feature between two atsigns.
This plugin provides a chat screen - ChatScreen that can be accessed as a bottom sheet or as a navigated screen.

## Get Started:

### Installation:

 To use this library in your app, add it to your pubspec.yaml

``` 
  dependencies:
    at_chat_flutter: ^3.0.2
```
#### Add to your project

 ```dart
 flutter pub get 
 ```
 #### Import in your application code

 ```dart
 import 'package:at_chat_flutter/at_chat_flutter.dart';
 ```
### Clone it from github

 Feel free to fork a copy of the source from the [GitHub Repo](https://github.com/atsign-foundation/at_widgets)

### Initialising:
The chat service needs to be initialised. It is expected that the app will first create an AtClientService instance using the preferences and then use it to initialise the chat service.

```dart
initializeChatService(
        clientSdkService.atClientServiceInstance!.atClientManager,
        activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

### Usage

### As a bottom sheet
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

### As a screen
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
## Open source usage and contributions

 This is freely licensed open source code, so feel free to use it as is, suggest changes or enhancements or create your
 own version. See [CONTRIBUTING.md](https://github.com/atsign-foundation/at_widgets/blob/trunk/CONTRIBUTING.md) for detailed guidance on how to setup tools, tests and make a pull request.