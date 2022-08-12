import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_client/at_client.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_flutter/utils/contact_theme.dart';
import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:flutter/material.dart';
import 'package:at_contacts_flutter_example/main.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String? activeAtSign, pickedAtSign;
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

  String formatAtsign(String atsign) {
    if (atsign[0] == '@') {
      return atsign;
    } else {
      return '@' + atsign;
    }
  }

  Future<void> deleteContactDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text(
          'Delete contact?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the atSign to delete as a contact',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  pickedAtSign = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'atSign',
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if (pickedAtSign != null && pickedAtSign!.trim().isNotEmpty) {
                pickedAtSign = formatAtsign(pickedAtSign!);
                await deleteContact(pickedAtSign!);
              }

              pickedAtSign = '';
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.blue[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
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
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Welcome $activeAtSign!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              // onPressed: () async => addContactDialog(context),
              onPressed: () async => showDialog(
                context: context,
                builder: (context) => const AddContactDialog(),
              ),
              child: const Text('Add contact'),
            ),
            ElevatedButton(
              onPressed: () async => deleteContactDialog(context),
              child: const Text('Delete contact'),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ContactsScreen(
                      theme: Theme.of(context).brightness == Brightness.light
                          ? const DefaultContactTheme()
                          : DarkContactTheme(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              primaryColor: Theme.of(context).primaryColor,
                            ),
                    ),
                  ),
                );
              },
              child: const Text('Show contacts'),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => BlockedScreen(
                      theme: Theme.of(context).brightness == Brightness.light
                          ? const DefaultContactTheme()
                          : DarkContactTheme(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              primaryColor: Theme.of(context).primaryColor,
                            ),
                    ),
                  ),
                );
              },
              child: const Text('Show blocked contacts'),
            ),
          ],
        ),
      ),
    );
  }

  void getAtSignAndInitializeContacts() async {
    var currentAtSign =
        AtClientManager.getInstance().atClient.getCurrentAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeContactsService(rootDomain: AtEnv.rootDomain);
  }
}
