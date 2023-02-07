/// A popup to ask the [AtSign] which is to be added

import 'package:at_common_flutter/at_common_flutter.dart';

// ignore: library_prefixes
import 'package:at_contacts_flutter/utils/text_strings.dart' as contactStrings;

import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_styles.dart'
// ignore: library_prefixes
    as contactTextStyles;
import 'package:flutter/material.dart';

/// A dialog to validate and add a contact
class AddContactDialog extends StatefulWidget {
  const AddContactDialog({
    Key? key,
  }) : super(key: key);

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  /// atsign to add to contacts
  String atsignName = '';

  /// nickname for the contact to add
  String nickName = '';
  TextEditingController atSignController = TextEditingController();

  @override
  void dispose() {
    atSignController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ContactService().resetData();
  }

  /// Boolean indicator to show loading in progress
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var contactService = ContactService();
    var deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return SizedBox(
      height: 140.toHeight * deviceTextFactor,
      width: 100.toWidth,
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.toWidth)),
          titlePadding: EdgeInsets.only(
              top: 20.toHeight, left: 25.toWidth, right: 25.toWidth),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  contactStrings.TextStrings().addContact,
                  textAlign: TextAlign.center,
                  style: contactTextStyles.CustomTextStyles.primaryBold18,
                ),
              )
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: (contactService.getAtSignError == '')
                    ? 325.toHeight
                    : 370.toHeight * deviceTextFactor),
            child: Column(
              children: [
                SizedBox(
                  height: 20.toHeight,
                ),
                TextFormField(
                  autofocus: true,
                  onChanged: (value) {
                    atsignName = value.toLowerCase().replaceAll(' ', '');
                  },
                  // validator: Validators.validateAdduser,
                  decoration: InputDecoration(
                    // prefixText: '@',
                    prefix: const Text("@", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    prefixStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.toFont,
                      fontWeight: FontWeight.normal,
                    ),
                    hintText: '\tEnter atsign',
                  ),
                  style: TextStyle(
                    fontSize: 15.toFont,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                (contactService.getAtSignError == '')
                    ? Container()
                    : SizedBox(
                        height: 10.toHeight,
                      ),
                (contactService.getAtSignError == '')
                    ? Container()
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              contactService.getAtSignError,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                SizedBox(
                  height: 10.toHeight,
                ),
                TextFormField(
                  autofocus: true,
                  onChanged: (value) {
                    nickName = value;
                  },
                  // validator: Validators.validateAdduser,
                  decoration: const InputDecoration(
                    hintText: 'Enter nickname',
                  ),
                  style: TextStyle(
                    fontSize: 15.toFont,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 45.toHeight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (isLoading)
                        ? const CircularProgressIndicator()
                        : CustomButton(
                            height: 50.toHeight * deviceTextFactor,
                            buttonText:
                                contactStrings.TextStrings().addtoContact,
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              var response = await contactService.addAtSign(
                                atSign: atsignName,
                                nickName: nickName,
                              );

                              setState(() {
                                isLoading = false;
                              });
                              if (contactService.checkAtSign != null &&
                                  contactService.checkAtSign! &&
                                  response) {
                                if (!mounted) return;
                                Navigator.pop(context);
                              }
                            },
                            buttonColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                            fontColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                          )
                  ],
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      height: 50.toHeight * deviceTextFactor,
                      buttonText: contactStrings.TextStrings().buttonCancel,
                      onPressed: () {
                        contactService.getAtSignError = '';
                        Navigator.pop(context);
                      },
                      buttonColor: Colors.white,
                      fontColor: Colors.black,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
