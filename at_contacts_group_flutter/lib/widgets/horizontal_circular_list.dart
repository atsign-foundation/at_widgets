// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/widgets/circular_contacts.dart';
import 'package:flutter/material.dart';

class HorizontalCircularList extends StatefulWidget {
  final List<AtContact>? list;

  const HorizontalCircularList({Key? key, this.list}) : super(key: key);

  @override
  _HorizontalCircularListState createState() => _HorizontalCircularListState();
}

class _HorizontalCircularListState extends State<HorizontalCircularList> {
  late GroupService _groupService;
  @override
  void initState() {
    _groupService = GroupService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupContactsModel?>>(
        initialData: _groupService.selectedGroupContacts,
        stream: _groupService.selectedContactsStream,
        builder: (BuildContext context, AsyncSnapshot<List<GroupContactsModel?>> snapshot) {
          // ignore: omit_local_variable_types
          List<GroupContactsModel?> selectedContacts = snapshot.data!;

          return Container(
            height: (selectedContacts.isEmpty) ? 0 : 150.toHeight,
            child: ListView.builder(
              itemCount: selectedContacts.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
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
