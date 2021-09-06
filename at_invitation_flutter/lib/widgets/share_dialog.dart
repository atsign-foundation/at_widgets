// ignore: import_of_legacy_library_into_null_safe
import 'dart:io';

import 'package:at_common_flutter/at_common_flutter.dart';
// import 'package:at_common_flutter/services/size_config.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_invitation_flutter/services/invitation_service.dart';
import 'package:at_invitation_flutter/utils/text_styles.dart'
    as invitationTextStyles;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareDialog extends StatefulWidget {
  final String? uniqueID;
  final String? passcode;
  final String? webPageLink;
  final String currentAtsign;
  ShareDialog(
      {Key? key,
      this.uniqueID,
      this.passcode,
      this.webPageLink,
      required this.currentAtsign})
      : super(key: key);

  @override
  _ShareDialogState createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  String atsignName = '';
  TextEditingController atSignController = TextEditingController();
  bool emailError = false;
  bool phoneError = false;
  String? emailErrorMessage, phoneErrorMessage;
  String emailAddress = '';
  String phoneNumber = '';
  int activeOption = 0;
  @override
  void dispose() {
    atSignController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // ContactService().resetData();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var _invitationService = InvitationService();
    var deviceTextFactor = MediaQuery.of(context).textScaleFactor;
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
                  'Share information',
                  textAlign: TextAlign.center,
                  style: invitationTextStyles.CustomTextStyles.primaryBold18,
                ),
              )
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: (emailError || phoneError)
                    ? 530.toHeight * deviceTextFactor
                    : 500.toHeight),
            child: Column(
              children: [
                Text(
                  'Would you like to invite someone via',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      value: 0,
                      groupValue: activeOption,
                      onChanged: (e) {
                        setState(() {
                          activeOption = int.parse(e.toString());
                        });
                      },
                    ),
                    new Text(
                      'SMS',
                      style: new TextStyle(fontSize: 16.0),
                    ),
                    new Radio(
                      value: 1,
                      groupValue: activeOption,
                      onChanged: (e) {
                        setState(() {
                          activeOption = int.parse(e.toString());
                        });
                      },
                    ),
                    new Text(
                      'Email',
                      style: new TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  autofocus: true,
                  enabled: activeOption == 0,
                  onChanged: (value) {
                    phoneNumber = value.trim();
                    if (phoneNumber != '') {
                      if (RegExp(r"^[0-9]").hasMatch(phoneNumber)) {
                        if (phoneNumber.length >= 10) {
                          phoneError = false;
                          phoneErrorMessage = '';
                        } else {
                          phoneError = true;
                          phoneErrorMessage =
                              'Phone number can be less than 10 digits';
                        }
                      } else {
                        phoneError = true;
                        phoneErrorMessage = 'Invalid phone number';
                      }
                    } else {
                      phoneError = false;
                      phoneErrorMessage = '';
                    }
                    setState(() {});
                  },
                  // validator: Validators.validateAdduser,
                  decoration: InputDecoration(
                    labelText: 'Phone number:',
                    labelStyle: TextStyle(
                        color:
                            activeOption == 0 ? Colors.black : Colors.black26,
                        fontSize: 18.toFont),
                    prefixText: '+',
                    prefixStyle:
                        TextStyle(color: Colors.grey, fontSize: 15.toFont),
                    hintText: 'Please enter full international phone number',
                    hintMaxLines: 2,
                    errorText: phoneError ? phoneErrorMessage : null,
                    errorStyle:
                        TextStyle(color: Colors.red, fontSize: 10.toFont),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 15.toFont),
                ),
                TextFormField(
                  autofocus: true,
                  enabled: activeOption == 1,
                  onChanged: (value) {
                    emailAddress = value.trim();
                    if (emailAddress != '') {
                      if (RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(emailAddress)) {
                        emailError = false;
                        emailErrorMessage = '';
                      } else {
                        emailError = true;
                        emailErrorMessage = 'Invalid email address';
                      }
                    } else {
                      emailError = false;
                      emailErrorMessage = '';
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Email address:',
                    labelStyle: TextStyle(
                        color:
                            activeOption == 1 ? Colors.black : Colors.black26,
                        fontSize: 18.toFont),
                    prefixStyle:
                        TextStyle(color: Colors.grey, fontSize: 15.toFont),
                    hintText: 'Please enter valid email address',
                    hintMaxLines: 2,
                    errorText: emailError ? emailErrorMessage : null,
                    errorStyle:
                        TextStyle(color: Colors.red, fontSize: 12.toFont),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 15.toFont),
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
                            buttonText: 'Share',
                            onPressed: () async {
                              if (!(emailError || phoneError)) {
                                setState(() {
                                  isLoading = true;
                                });
                                await _sendInformation();
                                setState(() {
                                  isLoading = false;
                                });
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
                      buttonText: 'Cancel',
                      onPressed: () {
                        // _contactService.getAtSignError = '';
                        emailError = false;
                        phoneError = false;
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

  Future<void> _sendInformation() async {
    // construct message body
    String link = (widget.webPageLink ?? '') +
        '?key=${widget.uniqueID}&atsign=${widget.currentAtsign}';
    String inviteText =
        'Hi there, you have been invited to join this app. \n link: $link \n password: ${widget.passcode}';

    String messageBody = Uri.encodeComponent(inviteText);

    // send SMS
    if (phoneNumber != '') {
      if (Platform.isAndroid) {
        var uri = 'sms:' + phoneNumber + '?body=' + messageBody;
        if (await canLaunch(uri)) {
          await launch(uri);
          print('sent to $phoneNumber');
        }
      } else if (Platform.isIOS) {
        var uri = 'sms:' + phoneNumber + '&body=' + messageBody;
        if (await canLaunch(uri)) {
          await launch(uri);
        }
      }
    }
    // send email
    else if (emailAddress != '') {
      var uri =
          'mailto:' + emailAddress + '?subject=Invitation&body=' + messageBody;
      print(uri);
      if (await canLaunch(uri)) {
        await launch(uri);
        print('sent to $emailAddress');
      }
    }
  }
}
