import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:at_chat_flutter/utils/chat_theme.dart';
import 'package:flutter/material.dart';

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
        // incomingMessageColor: Colors.blue[100]!,
        // outgoingMessageColor: Colors.green[100]!,
        theme: Theme.of(context).brightness == Brightness.light
            ? DefaultChatTheme()
            : DarkChatTheme(),
        isScreen: true,
      ),
    );
  }
}
