import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/widgets/circular_contacts.dart';
import 'package:flutter/material.dart';

class HorizontalCircularList extends StatefulWidget {
  final List<AtContact> list;

  const HorizontalCircularList({Key key, this.list}) : super(key: key);

  @override
  _HorizontalCircularListState createState() => _HorizontalCircularListState();
}

class _HorizontalCircularListState extends State<HorizontalCircularList> {
  GroupService _groupService;
  @override
  void initState() {
    _groupService = GroupService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupContactsModel>>(
        initialData: _groupService.selectedGroupContacts,
        stream: _groupService.selectedContactsStream,
        builder: (context, snapshot) {
          List<GroupContactsModel> selectedContacts = snapshot.data;

          return Container(
            height: (selectedContacts.isEmpty) ? 0 : 140.toHeight,
            child: ListView.builder(
              itemCount: selectedContacts.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return CircularContacts(
                  groupContact: selectedContacts[index],
                  onCrossPressed: () {
                    setState(() {
                      _groupService.removeGroupContact(selectedContacts[index]);
                    });
                  },
                );
              },
            ),
          );
        });
  }
}
