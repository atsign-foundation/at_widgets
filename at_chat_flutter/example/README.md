# at_chat_flutter_example

Demonstrates how to use the at_chat_flutter plugin.

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
