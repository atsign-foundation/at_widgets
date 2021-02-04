import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_group_flutter/screens/new_group/new_group.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class EmptyGroup extends StatefulWidget {
  @override
  _EmptyGroupState createState() => _EmptyGroupState();
}

class _EmptyGroupState extends State<EmptyGroup> {
  List<AtContact> selectedContactList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AllImages().EMPTY_GROUP,
              width: 181.toWidth,
              height: 181.toWidth,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 15.toHeight,
            ),
            Text('No Groups!', style: CustomTextStyles().primaryBold18),
            SizedBox(
              height: 5.toHeight,
            ),
            Text(
              'Would you like to create a group?',
              style: CustomTextStyles().primaryMedium14,
            ),
            SizedBox(
              height: 20.toHeight,
            ),
            CustomButton(
              height: 40.toHeight,
              width: 120.toWidth,
              buttonText: 'Create',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactsScreen(
                      asSelectionScreen: true,
                      context: context,
                      selectedList: (selectedList) {
                        print('in selectedList => selectedList');
                        // selectedContactList = selectedList;

                        // if (selectedContactList?.length > 0) {
                        //   GroupService()
                        //       .setSelectedContacts(selectedContactList);

                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => NewGroup(),
                        //     ),
                        //   );
                        // }
                      },
                    ),
                  ),
                );
              },
              // isInverted: Theme.of(context).primaryColor == Color(0xFF000000)
              //     ? false
              //     : true,
            )
          ],
        ),
      ),
    );
  }
}
