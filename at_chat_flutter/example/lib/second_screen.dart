import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:flutter/material.dart';
import 'client_sdk_service.dart';
import 'third_screen.dart';
import 'constants.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String activeAtSign;
  GlobalKey<ScaffoldState> scaffoldKey;
  String chatWithAtSign = '';
  bool showOptions = false;

  @override
  void initState() {
    getAtSignAndInitializeChat();
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Second Screen')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.0,
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: Text(
              'Welcome $activeAtSign!',
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text("Enter an atsign to chat with"),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextFormField(
              autofocus: true,
              onChanged: (value) {
                chatWithAtSign = value;
              },
              // validator: Validators.validateAdduser,
              decoration: InputDecoration(
                prefixText: '@',
                prefixStyle: TextStyle(color: Colors.grey),
                hintText: '\tEnter user atsign',
              ),
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          showOptions
              ? Column(
                  children: [
                    SizedBox(height: 20.0),
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
                    FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ThirdScreen()));
                      },
                      child: Container(
                        height: 40,
                        child: Text('Navigate to chat screen'),
                      ),
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      onPressed: () {
                        if (chatWithAtSign != null &&
                            chatWithAtSign.trim() != '') {
                          setAtsignToChatWith();
                          setState(() {
                            showOptions = true;
                          });
                        } else {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [Text('Atsign Missing!')],
                                  ),
                                  content: Text('Please enter an atsign'),
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Close'),
                                    )
                                  ],
                                );
                              });
                        }
                      },
                      child: Container(
                        height: 40,
                        child: Text('Chat options'),
                      ),
                    ),
                  ],
                ),
          FlatButton(
            onPressed: () {
              checkMonitorConnection();
            },
            child: Container(
              height: 40,
              child: Text('Check monitor connection'),
            ),
          )
        ],
      ),
    );
  }

  getAtSignAndInitializeChat() async {
    String currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeChatService(
        clientSdkService.atClientServiceInstance.atClient, activeAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  setAtsignToChatWith() {
    setChatWithAtSign(chatWithAtSign);
  }
}
