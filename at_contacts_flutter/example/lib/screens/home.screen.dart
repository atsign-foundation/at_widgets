import 'package:at_client/at_client.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:eg/services/client.sdk.services.dart';
import 'package:eg/widgets/prompt.widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AtClient atClientInstance = AtClientManager.getInstance().atClient;
  late AtContactsImpl _atContact;
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign, pickedAtSign;
  @override
  void initState() {
    _atContact =
        AtContactsImpl(atClientInstance, atClientInstance.getCurrentAtSign()!);
    Future.microtask(() async {
      var currentAtSign =
          await clientSdkService.getAtSignAndInitializeContacts();
      setState(() {
        activeAtSign = currentAtSign;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    disposeContactsControllers();
    super.dispose();
  }

Future<void> addContactDialog(BuildContext context) async {
  await Dialogs.customDialog(
    context,
    'Add contact?',
    'Enter the @sign to add as a contact',
    () async {
      await clientSdkService.addContact(pickedAtSign!, _atContact);
      Navigator.pop(context);
    },
    childContent: TextField(
      onChanged: (value) {
        setState(() {
          pickedAtSign = value;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '@sign',
      ),
    ),
    buttonText: 'Add',
  );
}

Future<void> deleteContactDialog(BuildContext context) async {
  await Dialogs.customDialog(
    context,
    'Delete contact?',
    'Enter the @sign to delete as a contact',
    () async {
      await clientSdkService.deleteContact(pickedAtSign!, _atContact);
      Navigator.pop(context);
    },
    childContent: TextField(
      onChanged: (value) {
        setState(() {
          pickedAtSign = value;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '@sign',
      ),
    ),
    buttonText: 'Delete',
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Welcome $activeAtSign!',
                style: const TextStyle(fontSize: 20),
              ),
            ),
ElevatedButton(
  onPressed: () async => addContactDialog(context),
  child: const Text('Add contact'),
),
ElevatedButton(
  onPressed: () async => deleteContactDialog(context),
  child: const Text('Delete contact'),
),
ElevatedButton(
  onPressed: () {
    // any logic
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => const ContactsScreen(),
    ));
  },
  child: const Text('Show contacts'),
),
ElevatedButton(
  onPressed: () {
    // any logic
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => const BlockedScreen(),
    ));
  },
  child: const Text('Show blocked contacts'),
),
          ],
        ),
      ),
    );
  }
}
