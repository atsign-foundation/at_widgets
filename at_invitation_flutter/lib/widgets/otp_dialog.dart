import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_invitation_flutter/utils/text_styles.dart'
    as invitation_text_styles;
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';

class OTPDialog extends StatefulWidget {
  final String? uniqueID;
  final String? passcode;
  final String? webPageLink;
  OTPDialog({Key? key, this.uniqueID, this.passcode, this.webPageLink})
      : super(key: key);

  @override
  _OTPDialogState createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  TextEditingController newTextEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    // newTextEditingController.dispose();
    // focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
            children: <Widget>[
              Expanded(
                child: Text(
                  'Invite confirmation',
                  textAlign: TextAlign.center,
                  style: invitation_text_styles.CustomTextStyles.primaryBold18,
                ),
              )
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200.toHeight),
            child: Column(children: <Widget>[
              const Text(
                'Please enter the OTP that you have recieved with the invite link',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20.toHeight,
              ),
              PinCodeFields(
                length: 4,
                controller: newTextEditingController,
                focusNode: focusNode,
                fieldBorderStyle: FieldBorderStyle.Square,
                responsive: false,
                fieldHeight: 50.0,
                fieldWidth: 30.0,
                borderWidth: 1.0,
                activeBorderColor: Colors.black,
                borderRadius: BorderRadius.circular(2.0),
                keyboardType: TextInputType.number,
                autoHideKeyboard: true,
                borderColor: Colors.grey,
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                onComplete: (String result) {
                  // Your logic with code
                  print(result);
                  Navigator.pop(context, result);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
