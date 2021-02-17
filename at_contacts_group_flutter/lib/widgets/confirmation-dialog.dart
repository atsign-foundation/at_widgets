import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
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
      contentPadding: EdgeInsets.only(top: 0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.toWidth)),
      content: Container(
        height: 410.toHeight,
        width: 200.toWidth,
        color: Theme.of(context).brightness == Brightness.light
            ? AllColors().WHITE
            : AllColors().Black,
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.heading,
                style: CustomTextStyles().grey16,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.toHeight),
              widget.title.length > 2
                  ? ContactInitial(
                      initials: widget.title.substring(1, 3), size: 60)
                  : ContactInitial(
                      initials: widget.title
                          .substring(0, widget.title.length >= 1 ? 1 : 0),
                      size: 60),
              SizedBox(height: 15.toHeight),
              Text(
                widget.title,
                style: CustomTextStyles().grey16,
              ),
              widget.subtitle != null
                  ? Text(
                      widget.subtitle,
                      style: CustomTextStyles().grey16,
                    )
                  : SizedBox(),
              SizedBox(height: 20.toHeight),
              isLoading
                  ? CircularProgressIndicator()
                  : CustomButton(
                      height: 60.toHeight,
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
                      // isInverted:
                      //     Theme.of(context).primaryColor == Color(0xFF000000)
                      //         ? false
                      //         : true,
                      buttonColor:
                          Theme.of(context).brightness == Brightness.light
                              ? AllColors().Black
                              : AllColors().WHITE,
                      fontColor:
                          Theme.of(context).brightness == Brightness.light
                              ? AllColors().WHITE
                              : AllColors().Black,
                    ),
              SizedBox(height: 10.toHeight),
              InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: !isLoading
                      ? Text(
                          'No',
                          style: TextStyle(
                              fontSize: 14.toFont,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? AllColors().Black
                                  : AllColors().WHITE),
                        )
                      : SizedBox())
            ],
          ),
        ),
      ),
    );
  }
}
