/// A popup to ask the [AtSign] which is to be added

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart' as contactStrings;
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_styles.dart'
    as contactTextStyles;
import 'package:flutter/material.dart';

class AddContactDialog extends StatefulWidget {
  AddContactDialog({
    Key key,
  }) : super(key: key);

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  String atsignName = '';
  TextEditingController atSignController = TextEditingController();
  @override
  void dispose() {
    atSignController.dispose();
    super.dispose();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    ContactService _contactService = ContactService();
    double deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return Container(
      height: 100.toHeight * deviceTextFactor,
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
                maxHeight: (_contactService.getAtSignError == '')
                    ? 255.toHeight
                    : 310.toHeight * deviceTextFactor),
            child: Column(
              children: [
                SizedBox(
                  height: 20.toHeight,
                ),
                TextFormField(
                  autofocus: true,
                  onChanged: (value) {
                    atsignName = value;
                  },
                  // validator: Validators.validateAdduser,
                  decoration: InputDecoration(
                    prefixText: '@',
                    prefixStyle: TextStyle(color: Colors.grey),
                    hintText: '\tEnter user atsign',
                  ),
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                (_contactService.getAtSignError == '')
                    ? Container()
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              _contactService.getAtSignError,
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        ],
                      ),
                SizedBox(
                  height: 45.toHeight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (isLoading)
                        ? CircularProgressIndicator()
                        : CustomButton(
                            height: 50.toHeight * deviceTextFactor,
                            buttonText:
                                contactStrings.TextStrings().addtoContact,
                            fontColor: Colors.white,
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await _contactService.addAtSign(context,
                                  atSign: atsignName);

                              setState(() {
                                isLoading = false;
                              });
                              if (_contactService.checkAtSign) {
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
                        buttonColor: Colors.white,
                        onPressed: () {
                          _contactService.getAtSignError = '';
                          Navigator.pop(context);
                        })
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
