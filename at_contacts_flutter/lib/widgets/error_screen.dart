import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class ErrorScreen extends StatelessWidget {
  final Function onPressed;
  ErrorScreen({this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Something went wrong.'),
          SizedBox(height: 10),
          CustomButton(
            buttonText: 'Retry',
            width: 120.toWidth,
            height: 40.toHeight,
            onPressed: () async {
              if (this.onPressed != null) {
                onPressed();
              }
            },
            buttonColor: Theme.of(context).brightness == Brightness.light
                ? ColorConstants.fontPrimary
                : ColorConstants.scaffoldColor,
            fontColor: Theme.of(context).brightness == Brightness.light
                ? ColorConstants.scaffoldColor
                : ColorConstants.fontPrimary,
          )
        ],
      ),
    );
  }
}
