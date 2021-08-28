/// A bottom sheet widget to diaplay the number of contacts selected from
/// contact list and what to do of that list on press of [Done]
/// takes in @param [onPressed] which defines what to be executed on press of [Done]
/// @param [selectedList] is a [ValueChanged] function which return the selected contacts
/// to be used outside of package.

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';

class CustomBottomSheet extends StatelessWidget {
  final Function? onPressed;
  final ValueChanged<List<AtContact?>?>? selectedList;
  const CustomBottomSheet({Key? key, this.onPressed, this.selectedList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ContactService _contactServive = ContactService();
    return StreamBuilder<List<AtContact?>>(
      stream: _contactServive.selectedContactStream,
      initialData: _contactServive.selectedContacts,
      builder: (BuildContext context, AsyncSnapshot<List<AtContact?>> snapshot) => (snapshot.data!.isEmpty)
          ? Container(
              height: 0,
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
              height: 70.toHeight,
              decoration: const BoxDecoration(
                color: Color(0xffF7F7FF),
                boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      (snapshot.data!.length != 25)
                          ? '${snapshot.data!.length} Contacts Selected'
                          : '25 of 25 Contact Selected',
                      style: CustomTextStyles.primaryMedium14,
                    ),
                  ),
                  CustomButton(
                    buttonText: 'Done',
                    width: 120.toWidth,
                    height: 40.toHeight,
                    buttonColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                    fontColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                    onPressed: () {
                      onPressed!();
                      selectedList!(snapshot.data);
                    },
                  )
                ],
              ),
            ),
    );
  }
}
