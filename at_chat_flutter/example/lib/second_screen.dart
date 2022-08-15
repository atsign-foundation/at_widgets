import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_chat_flutter_example/main.dart';
import 'package:at_chat_flutter/utils/chat_theme.dart';
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'third_screen.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  AtClientService? atClientService;
  String? activeAtSign;
  GlobalKey<ScaffoldState>? scaffoldKey;
  String chatWithAtSign = '';
  bool showOptions = false;

  // for goup chat
  String groupId = '';
  String member1 = '';
  String member2 = '';

  /// Get the AtClientManager instance
  var atClientManager = AtClientManager.getInstance();
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
      appBar: AppBar(
        title: const Text('Second Screen'),
        actions: [
          IconButton(
            onPressed: () {
              updateThemeMode.sink.add(
                  Theme.of(context).brightness == Brightness.light
                      ? ThemeMode.dark
                      : ThemeMode.light);
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Welcome $activeAtSign!',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text('Enter an atsign to chat with'),
            const SizedBox(
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
                decoration: const InputDecoration(
                  prefixText: '@',
                  prefixStyle: TextStyle(color: Colors.grey),
                  hintText: '\tEnter user atsign',
                ),
              ),
            ),
            showOptions
                ? Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          scaffoldKey!.currentState!.showBottomSheet(
                            (context) => ChatScreen(
                              theme: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const DefaultChatTheme()
                                  : DarkChatTheme(
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                            ),
                          );
                        },
                        child: Text(
                          'Open chat in bottom sheet',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ThirdScreen()));
                        },
                        child: Text(
                          'Navigate to chat screen',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          if (chatWithAtSign.trim() != '') {
                            setAtsignToChatWith();
                            setState(() {
                              showOptions = true;
                            });
                          } else {
                            showAtsignErrorDialog(context);
                          }
                        },
                        child: const SizedBox(
                          height: 40,
                          child: Text(
                            'Chat options',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
            const SizedBox(
              height: 50.0,
            ),
            const Divider(
              thickness: 2,
              height: 20,
            ),
            const Text('Group chat:'),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                autofocus: false,
                onChanged: (value) {
                  groupId = value;
                },
                // validator: Validators.validateAdduser,
                decoration: const InputDecoration(
                  hintText: '\tEnter the group ID',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                autofocus: false,
                onChanged: (value) {
                  member1 = value;
                },
                // validator: Validators.validateAdduser,
                decoration: const InputDecoration(
                  prefixText: '@',
                  prefixStyle: TextStyle(color: Colors.grey),
                  hintText: '\tEnter first user atsign',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextFormField(
                autofocus: false,
                onChanged: (value) {
                  member2 = value;
                },
                // validator: Validators.validateAdduser,
                decoration: const InputDecoration(
                  prefixText: '@',
                  prefixStyle: TextStyle(color: Colors.grey),
                  hintText: '\tEnter second user atsign',
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).accentColor),
              ),
              onPressed: () {
                setGroupToChatWith(context);
              },
              child: const Text(
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
    var currentAtSign = atClientManager.atClient.getCurrentAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeChatService(atClientManager, activeAtSign!,
        rootDomain: AtEnv.rootDomain);
  }

  void setAtsignToChatWith() {
    setChatWithAtSign(chatWithAtSign);
  }

  void setGroupToChatWith(BuildContext context) {
    if (member1.trim() != '' && member2.trim() != '' && groupId != '') {
      setChatWithAtSign(null, isGroup: true, groupId: groupId, groupMembers: [
        activeAtSign!,
        member1.startsWith('@') ? member1 : '@' + member1,
        member2.startsWith('@') ? member2 : '@' + member2
      ]);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ThirdScreen()));
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
            children: const [Text('Some details are missing!')],
          ),
          content: const Text('Please enter all fields'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
              ),
            )
          ],
        );
      },
    );
  }
}
