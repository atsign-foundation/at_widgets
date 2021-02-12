import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_location_flutter/common_components/pop_button.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class ShareLocationSheet extends StatefulWidget {
  @override
  _ShareLocationSheetState createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  bool isLoading;
  String selectedOption;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.5,
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Share Location', style: CustomTextStyles().black18),
              PopButton(label: 'Cancel')
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Text('Share with', style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          CustomInputField(
            width: 330.toWidth,
            height: 50,
            isReadOnly: true,
            hintText: 'Type @sign or search from contact',
            icon: Icons.contacts_rounded,
            onTap: () {},
          ),
          SizedBox(height: 25),
          Text(
            'Duration',
            style: CustomTextStyles().greyLabel14,
          ),
          SizedBox(height: 10),
          Container(
            color: AllColors().INPUT_GREY_BACKGROUND,
            width: 330.toWidth,
            padding: EdgeInsets.only(left: 10, right: 10),
            child: DropdownButton(
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down),
              underline: SizedBox(),
              elevation: 0,
              dropdownColor: AllColors().INPUT_GREY_BACKGROUND,
              value: selectedOption,
              hint: Text("Occurs on"),
              items: ['30 mins', '2 hours', '24 hours', 'Until turned off']
                  .map((String option) {
                return new DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
            ),
          ),
          Expanded(child: SizedBox()),
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    buttonText: 'Share',
                    onPressed: onShareTap,
                    width: 164,
                    height: 48,
                  ),
          ),
        ],
      ),
    );
  }

  onShareTap() async {}
}
