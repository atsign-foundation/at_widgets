import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class ErrorScreen extends StatelessWidget {
  final Function onPressed;
  final String msg;
  ErrorScreen(
      {this.onPressed, this.msg = 'Something went wrong, please retry.'});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(msg,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
          SizedBox(height: 10),
          onPressed != null
              ? CustomButton(
                  buttonText: 'Retry',
                  width: 120.toWidth,
                  height: 40.toHeight,
                  onPressed: () async {
                    if (this.onPressed != null) {
                      onPressed();
                    }
                  },
                  buttonColor: Theme.of(context).brightness == Brightness.light
                      ? AllColors().Black
                      : AllColors().WHITE,
                  fontColor: Theme.of(context).brightness == Brightness.light
                      ? AllColors().WHITE
                      : AllColors().Black,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
