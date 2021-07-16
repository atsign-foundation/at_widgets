import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:flutter/material.dart';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Show Snackbar',
            onPressed: () async {
              bool result = await deleteMessages();
              String message = result ? 
                'Messages are deleted' : 'Failed to delete';
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(message)));
            },
          ),
        ]),
      body: ChatScreen(
        height: MediaQuery.of(context).size.height,
        incomingMessageColor: Colors.blue[100]!,
        outgoingMessageColor: Colors.green[100]!,
        isScreen: true,
      ),
    );
  }
}
