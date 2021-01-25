import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_group_flutter/widgets/contacts_initials.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class ConfirmationDialog extends StatefulWidget {
  final String heading, title, subtitle;
  final Function onYesPressed;
  ConfirmationDialog(
      {@required this.heading,
      @required this.title,
      @required this.onYesPressed,
      this.subtitle});

  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool isLoading;

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // contentPadding: EdgeInsets.only(top: 0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.toWidth)),
      content: Container(
        height: 300.toHeight,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          // padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.heading,
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.toHeight),
              ContactInitial(initials: widget.title.substring(1, 3), size: 60),
              // CustomCircleAvatar(
              //   image: AllImages().PERSON2,
              //   size: 74,
              // ),
              SizedBox(height: 15.toHeight),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headline3,
              ),
              widget.subtitle != null
                  ? Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.headline3,
                    )
                  : SizedBox(),
              SizedBox(height: 20.toHeight),
              isLoading
                  ? CircularProgressIndicator()
                  : CustomButton(
                      height: 60,
                      width: double.infinity,
                      buttonText: 'Yes',
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });

                        if (widget.onYesPressed != null)
                          await widget.onYesPressed();

                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      isInverted:
                          Theme.of(context).primaryColor == Color(0xFF000000)
                              ? false
                              : true,
                    ),
              SizedBox(height: 5.toHeight),
              InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: !isLoading
                      ? Text(
                          'No',
                          style: TextStyle(
                              fontSize: 14.toFont,
                              color: Theme.of(context).primaryColor),
                        )
                      : SizedBox())
            ],
          ),
        ),
      ),
    );
  }
}
