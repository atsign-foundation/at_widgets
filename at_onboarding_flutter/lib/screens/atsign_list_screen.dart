import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';

class AtsignListScreen extends StatefulWidget {
  final List<String> atsigns;
  final String? message;
  final String? newAtsign;

  const AtsignListScreen({required this.atsigns, this.message, this.newAtsign});

  @override
  _AtsignListScreenState createState() => _AtsignListScreenState();
}

class _AtsignListScreenState extends State<AtsignListScreen> {
  late final List<String>? pairedAtsignsList;
  var lastSelectedIndex;
  late String message;
  late int greyStartIndex;
  @override
  void initState() {
    super.initState();
    OnboardingService.getInstance().getAtsignList().then((value) {
      pairedAtsignsList = value!;
      setState(() {});
    });
    message = widget.message ??
        'You already have some existing atsigns. Please select an @sign or else continue with the new one.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.light,
      appBar: CustomAppBar(
        title: 'Select @signs',
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.toFont),
        child: this.pairedAtsignsList == null
            ? Center(
                child: Column(
                children: [
                  Text(
                    'Loading atsigns',
                    style: CustomTextStyles.fontBold16dark,
                  ),
                  CircularProgressIndicator(
                    color: ColorConstants.appColor,
                  )
                ],
              ))
            : Column(
                children: [
                  Text(this.message, style: CustomTextStyles.fontBold14primary),
                  SizedBox(height: 10),
                  if (widget.newAtsign != null) ...[
                    Divider(thickness: 0.8),
                    RadioListTile(
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: lastSelectedIndex,
                      onChanged: (value) {
                        setState(() {
                          lastSelectedIndex = value;
                        });
                        _showAlert(widget.newAtsign!, context);
                      },
                      value: 'new',
                      activeColor: ColorConstants.appColor,
                      title: Text('@${widget.newAtsign}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                  Divider(thickness: 0.8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.atsigns.length,
                      itemBuilder: (ctxt, index) {
                        var currentItem = '@' + widget.atsigns[index];
                        var isExist =
                            this.pairedAtsignsList!.contains(currentItem);
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0.toFont),
                          child: RadioListTile(
                            controlAffinity: ListTileControlAffinity.trailing,
                            groupValue: lastSelectedIndex,
                            onChanged: isExist
                                ? null
                                : (value) {
                                    setState(() {
                                      lastSelectedIndex = value;
                                    });
                                    _showAlert(
                                        widget.atsigns[lastSelectedIndex],
                                        context);
                                  },
                            value: index,
                            activeColor: ColorConstants.appColor,
                            title: Text('${currentItem}',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _showAlert(String atsign, BuildContext ctxt) {
    showDialog(
        context: ctxt,
        builder: (_) => AlertDialog(
              content: RichText(
                text:
                    TextSpan(style: CustomTextStyles.fontR14primary, children: [
                  TextSpan(text: 'You have selected  '),
                  TextSpan(
                      text: '$atsign ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'to pair with this device')
                ]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(_),
                  child: Text(
                    Strings.cancelButton,
                    style: TextStyle(
                        color: ColorConstants.lightBackgroundColor,
                        fontSize: 12.toFont),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(_);
                    Navigator.pop(ctxt, atsign);
                  },
                  child: Text(
                    'Yes, continue',
                    style: TextStyle(
                        color: ColorConstants.dark,
                        fontSize: 12.toFont,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ));
  }
}
