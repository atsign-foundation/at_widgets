import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:at_onboarding_flutter/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';

/// This screen shows the list of atsigns already available for the given email
class AtOnboardingAccountsScreen extends StatefulWidget {
  /// list of atsigns for the email
  final List<String> atsigns;

  /// message to display along with the atsign list
  final String? message;

  /// the new atsign selected in the free atsign generator
  final String? newAtsign;

  const AtOnboardingAccountsScreen({
    Key? key,
    required this.atsigns,
    this.message,
    this.newAtsign,
  }) : super(key: key);

  @override
  _AtOnboardingAccountsScreenState createState() =>
      _AtOnboardingAccountsScreenState();
}

class _AtOnboardingAccountsScreenState
    extends State<AtOnboardingAccountsScreen> {
  List<String>? pairedAtsignsList = <String>[];
  Object? lastSelectedIndex;
  late int greyStartIndex;

  Future<void> intifuture() async {
    pairedAtsignsList = await OnboardingService.getInstance().getAtsignList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    intifuture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select @signs'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.toFont),
        child: pairedAtsignsList == null
            ? Center(
                child: Column(
                children: <Widget>[
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.appColor)),
                  Text(
                    'Loading atsigns',
                    style: CustomTextStyles.fontBold16dark,
                  ),
                ],
              ))
            : Column(
                children: <Widget>[
                  Text(
                    widget.message ??
                        'You already have some existing atsigns. Please select an @sign or else continue with the new one.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AtOnboardingDimens.fontNormal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.newAtsign != null) ...<Widget>[
                    const Divider(thickness: 0.8),
                    RadioListTile<Object>(
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: lastSelectedIndex,
                      onChanged: (Object? value) {
                        setState(() {
                          lastSelectedIndex = value;
                        });
                        _showAlert(widget.newAtsign!, context);
                      },
                      value: 'new',
                      activeColor: Theme.of(context).primaryColor,
                      title: Text('@${widget.newAtsign}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                  const Divider(thickness: 0.8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.atsigns.length,
                      itemBuilder: (BuildContext context, int index) {
                        String currentItem = '@' + widget.atsigns[index];
                        bool isExist = pairedAtsignsList!.contains(currentItem);
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0.toFont),
                          child: RadioListTile<Object>(
                            controlAffinity: ListTileControlAffinity.trailing,
                            groupValue: lastSelectedIndex,
                            onChanged: isExist
                                ? null
                                : (Object? value) {
                                    setState(() {
                                      lastSelectedIndex = value;
                                    });
                                    _showAlert(
                                        widget.atsigns[int.parse(
                                            lastSelectedIndex.toString())],
                                        context);
                                  },
                            value: index,
                            activeColor: Theme.of(context).primaryColor,
                            title: Text(currentItem),
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

  Future<AlertDialog?> _showAlert(String atsign, BuildContext context) async {
    await showDialog<AlertDialog>(
        context: context,
        builder: (_) => AlertDialog(
          content: RichText(
            text: TextSpan(
                style: Theme.of(context).textTheme.bodyText1,
                children: <InlineSpan>[
                  const TextSpan(text: 'You have selected  '),
                  TextSpan(
                      text: '$atsign ',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: 'to pair with this device')
                ]),
          ),
          actions: <Widget>[
            AtOnboardingSecondaryButton(
              onPressed: () => Navigator.pop(_),
              child: const Text(
                Strings.cancelButton,
              ),
            ),
            AtOnboardingPrimaryButton(
              onPressed: () {
                Navigator.pop(_);
                Navigator.pop(context, atsign);
              },
              child: const Text('Yes, continue'),
            )
          ],
        ));
  }
}
