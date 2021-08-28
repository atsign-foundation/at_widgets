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
  String? activeAtSign;
  GlobalKey<ScaffoldState>? scaffoldKey;
  String? chatWithAtSign = '';
  bool showOptions = false;

  // for goup chat
  String? groupId = '';
  String? member1 = '';
  String? member2 = '';

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
      body: SingleChildScrollView(
        child: Column(
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
            Text('Enter an atsign to chat with'),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                autofocus: true,
                onChanged: (value) {
                  chatWithAtSign = value;
                  if (showOptions) {
                    setState(() {
                      showOptions = false;
                    });
                  }
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
                      TextButton(
                        onPressed: () {
                          scaffoldKey!.currentState!
                              .showBottomSheet((context) => ChatScreen());
                        },
                        child: Container(
                          height: 40,
                          child: Text(
                            'Open chat in bottom sheet',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ThirdScreen()));
                        },
                        child: Container(
                          height: 40,
                          child: Text(
                            'Navigate to chat screen',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (chatWithAtSign != null &&
                              chatWithAtSign!.trim() != '') {
                            setAtsignToChatWith();
                            setState(() {
                              showOptions = true;
                            });
                          } else {
                            showAtsignErrorDialog(context);
                          }
                        },
                        child: Container(
                          height: 40,
                          child: Text(
                            'Chat options',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
            Divider(
              thickness: 2,
              height: 20,
            ),
            Text('Group chat:'),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                autofocus: false,
                onChanged: (value) {
                  groupId = value;
                },
                // validator: Validators.validateAdduser,
                decoration: InputDecoration(
                  hintText: '\tEnter the group ID',
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                autofocus: false,
                onChanged: (value) {
                  member1 = value;
                },
                // validator: Validators.validateAdduser,
                decoration: InputDecoration(
                  prefixText: '@',
                  prefixStyle: TextStyle(color: Colors.grey),
                  hintText: '\tEnter first user atsign',
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                autofocus: false,
                onChanged: (value) {
                  member2 = value;
                },
                // validator: Validators.validateAdduser,
                decoration: InputDecoration(
                  prefixText: '@',
                  prefixStyle: TextStyle(color: Colors.grey),
                  hintText: '\tEnter second user atsign',
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              onPressed: () {
                setGroupToChatWith(context);
              },
              child: Text(
                'Show group chat',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getAtSignAndInitializeChat() async {
    var currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeChatService(
        clientSdkService.atClientServiceInstance!.atClient!, activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  void setAtsignToChatWith() {
    setChatWithAtSign(chatWithAtSign);
  }

  void setGroupToChatWith(BuildContext context) {
    print('setGroupToChatWith');
    if (member1 != null &&
        member1!.trim() != '' &&
        member2 != null &&
        member2!.trim() != '' &&
        groupId != null &&
        groupId != '') {
      setChatWithAtSign(null, isGroup: true, groupId: groupId, groupMembers: [
        activeAtSign!,
        member1!.startsWith('@') ? member1! : '@' + member1!,
        member2!.startsWith('@') ? member2! : '@' + member2!
      ]);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ThirdScreen()));
    } else {
      showAtsignErrorDialog(context);
    }
  }

  void showAtsignErrorDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [Text('Some details are missing!')],
            ),
            content: Text('Please enter all fields'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Close',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          );
        });
  }
}
