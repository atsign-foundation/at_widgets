import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/common_components/pop_button.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:flutter/material.dart';

class ShareLocationSheet extends StatefulWidget {
  final Function? onTap;
  ShareLocationSheet({this.onTap});
  @override
  _ShareLocationSheetState createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  AtContact? selectedContact;
  late bool isLoading;
  String? selectedOption, textField;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.5,
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text('Share Location', style: CustomTextStyles().black18), PopButton(label: 'Cancel')],
          ),
          const SizedBox(
            height: 25,
          ),
          Text('Share with', style: CustomTextStyles().greyLabel14),
          const SizedBox(height: 10),
          CustomInputField(
            width: 330.toWidth,
            height: 50,
            hintText: 'Type @sign ',
            initialValue: textField ?? '',
            value: (String str) {
              if (!str.contains('@')) {
                str = '@' + str;
              }
              textField = str;
            },
            icon: Icons.contacts_rounded,
            onTap: widget.onTap,
          ),
          const SizedBox(height: 25),
          Text(
            'Duration',
            style: CustomTextStyles().greyLabel14,
          ),
          const SizedBox(height: 10),
          Container(
            color: AllColors().INPUT_GREY_BACKGROUND,
            width: 330.toWidth,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: DropdownButton<String>(
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              underline: const SizedBox(),
              elevation: 0,
              dropdownColor: AllColors().INPUT_GREY_BACKGROUND,
              value: selectedOption,
              hint: const Text('Occurs on'),
              items: <String>['30 mins', '2 hours', '24 hours', 'Until turned off'].map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (dynamic value) {
                setState(() {
                  textField = textField;
                  selectedOption = value;
                });
              },
            ),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    buttonText: 'Share',
                    onPressed: onShareTap,
                    fontColor: AllColors().WHITE,
                    width: 164,
                    height: 48,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> onShareTap() async {
    setState(() {
      isLoading = true;
    });
    bool validAtSign = await checkAtsign(textField);

    if (!validAtSign) {
      setState(() {
        isLoading = false;
      });
      CustomToast().show('Atsign not valid', context);
      return;
    }

    if (selectedOption == null) {
      CustomToast().show('Select time', context);
      return;
    }

    int? minutes = (selectedOption == '30 mins'
        ? 30
        : (selectedOption == '2 hours' ? (2 * 60) : (selectedOption == '24 hours' ? (24 * 60) : null)));

    bool? result = await SharingLocationService().sendShareLocationEvent(textField, false, minutes: minutes);

    if (result == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }

    if (result == true) {
      CustomToast().show('Share Location Request sent', context);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      CustomToast().show('some thing went wrong , try again.', context);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> checkAtsign(String? atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    String? checkPresence = await AtLookupImpl.findSecondary(atSign, AtLocationNotificationListener().rootDomain, 64);
    return checkPresence != null;
  }
}
