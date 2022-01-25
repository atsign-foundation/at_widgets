import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_contacts_group_flutter_example/constants.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  /// Get the AtClientManager instance
  var atClientManager = AtClientManager.getInstance();

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
                    context: context,
                    selectedList: (s) {
                      print('selected list: $s');
                    },
                  ),
                ));
              },
              child: Text('Show contacts'),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => GroupContactView(
                      showContacts: true,
                      showGroups: true,
                      asSelectionScreen: true,
                      selectedList: (List<GroupContactsModel?> s) {
                        print('selected list: $s');
                      }),
                ));
              },
              child: Text('Show Group view contacts'),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => BlockedScreen(),
                ));
              },
              child: Text('Show blocked contacts'),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => GroupList(),
                ));
              },
              child: Text('Show groups screen'),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: always_declare_return_types
  getAtSignAndInitializeContacts() async {
    var currentAtSign = atClientManager.atClient.getCurrentAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeContactsService(rootDomain: MixedConstants.ROOT_DOMAIN);
    initializeGroupService(rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}
