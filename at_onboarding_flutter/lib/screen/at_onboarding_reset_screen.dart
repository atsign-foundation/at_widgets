import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_error_util.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:flutter/material.dart';

import '../services/at_onboarding_config.dart';
import '../services/sdk_service.dart';

enum AtOnboardingResetResult {
  canceled,
  success,
}

class AtOnboardingResetScreen extends StatefulWidget {
  final AtOnboardingConfig config;

  const AtOnboardingResetScreen({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<AtOnboardingResetScreen> createState() =>
      _AtOnboardingResetScreenState();
}

class _AtOnboardingResetScreenState extends State<AtOnboardingResetScreen> {
  List<String> atsignsList = [];
  Map<String, bool?> atsignMap = <String, bool>{};
  bool isSelectAll = false;

  @override
  void initState() {
    setup();
    super.initState();
  }

  void setup() async {
    atsignsList = await SDKService().getAtsignList() ?? [];
    for (String atsign in atsignsList) {
      atsignMap[atsign] = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reset'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              Navigator.of(context).pop(AtOnboardingResetResult.canceled);
            },
          ),
        ),
        // title: Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: const <Widget>[
        //     Text(Strings.resetDescription,
        //         textAlign: TextAlign.center,
        //         style: TextStyle(fontSize: AtOnboardingDimens.fontLarge)),
        //     Divider()
        //   ],
        // ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
              child: const Text(AtOnboardingStrings.resetDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: AtOnboardingDimens.fontNormal)),
            ),
            Expanded(
                child: atsignsList.isEmpty
                    ? _buildEmptyWidget()
                    : _buildAtSignsWidget())
          ],
        ));
  }

  Widget _buildEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const <Widget>[
        Text(
          AtOnboardingStrings.noAtsignToReset,
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildAtSignsWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CheckboxListTile(
          onChanged: (bool? value) {
            isSelectAll = value!;
            if (atsignMap.isNotEmpty) {
              atsignMap
                  .updateAll((String? key, bool? value1) => value1 = value);
            }
            // atsignMap[atsign] = value;
            setState(() {});
          },
          value: isSelectAll,
          activeColor: Theme.of(context).primaryColor,
          title: const Text('Select All',
              style: TextStyle(
                // fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AtOnboardingDimens.paddingNormal),
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (String atsign in atsignsList)
                CheckboxListTile(
                  onChanged: (bool? value) {
                    if (atsignMap.isNotEmpty) {
                      atsignMap[atsign] = value;
                    }
                    setState(() {});
                  },
                  value: atsignMap.isNotEmpty ? atsignMap[atsign] : true,
                  activeColor: Theme.of(context).primaryColor,
                  title: Text(atsign),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AtOnboardingDimens.paddingNormal),
                )
            ],
          ),
        )),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AtOnboardingDimens.paddingNormal),
          child: Text(AtOnboardingStrings.resetWarningText,
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: AtOnboardingDimens.fontNormal)),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.only(
            left: AtOnboardingDimens.paddingNormal,
            right: AtOnboardingDimens.paddingNormal,
            bottom: AtOnboardingDimens.paddingNormal +
                MediaQuery.of(context).padding.bottom,
          ),
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: AtOnboardingPrimaryButton(
            height: 48,
            borderRadius: 24,
            onPressed: _onResetPressed,
            child: const Text(AtOnboardingStrings.removeButton),
          ),
        )
      ],
    );
  }

  void _onResetPressed() async {
    Map<String, bool?> tempAtsignMap = <String, bool>{};
    tempAtsignMap.addAll(atsignMap);
    tempAtsignMap.removeWhere((String? key, bool? value) => value == false);
    if (tempAtsignMap.keys.toList().isEmpty) {
      AtOnboardingDialog.showError(
          context: context, message: AtOnboardingStrings.resetErrorText);
    } else {
      _resetDevice(tempAtsignMap.keys.toList());
    }
  }

  Future<void> _resetDevice(List<String> checkedAtsigns) async {
    await SDKService().resetAtsigns(checkedAtsigns).then((void value) async {
      Navigator.pop(context, AtOnboardingResetResult.success);
    }).catchError((Object error) {
      showErrorDialog(error);
    });
  }

  Future<void> showErrorDialog(dynamic errorMessage, {String? title}) async {
    String? messageString =
        AtOnboardingErrorToString().getErrorMessage(errorMessage);
    return AtOnboardingDialog.showError(
        context: context, message: messageString);
  }
}
