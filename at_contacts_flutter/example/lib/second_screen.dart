import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_flutter/utils/contact_theme.dart';
import 'package:at_contacts_flutter_example/constants.dart';
import 'package:at_contacts_flutter_example/main.dart';
import 'package:flutter/material.dart';
import 'package:at_contacts_flutter_example/client_sdk_service.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_flutter/screens/blocked_screen.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign;
  @override
  void initState() {
    getAtSignAndInitializeContacts();
    super.initState();
  }

  @override
  void dispose() {
    disposeContactsControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
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
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Welcome $activeAtSign!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ContactsScreen(
                    theme: Theme.of(context).brightness == Brightness.light
                        ? DefaultContactTheme()
                        : DarkContactTheme(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            primaryColor: Theme.of(context).primaryColor,
                          ),
                  ),
                ));
              },
              child: Text('Show contacts'),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => BlockedScreen(
                    theme: Theme.of(context).brightness == Brightness.light
                        ? DefaultContactTheme()
                        : DarkContactTheme(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            primaryColor: Theme.of(context).primaryColor,
                          ),
                  ),
                ));
              },
              child: Text('Show blocked contacts'),
            ),
          ],
        ),
      ),
    );
  }

  void getAtSignAndInitializeContacts() async {
    var currentAtSign = await (clientSdkService.getAtSign());
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeContactsService(
        clientSdkService.atClientServiceInstance!.atClient!, currentAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}
