import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_location_flutter/common_components/pop_button.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

class RequestLocationSheet extends StatefulWidget {
  @override
  _RequestLocationSheetState createState() => _RequestLocationSheetState();
}

class _RequestLocationSheetState extends State<RequestLocationSheet> {
  bool isLoading;
  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig().screenHeight * 0.4,
      padding: EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Request Location', style: CustomTextStyles().black18),
              PopButton(label: 'Cancel')
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Text('Request From', style: CustomTextStyles().greyLabel14),
          SizedBox(height: 10),
          CustomInputField(
            width: 330.toWidth,
            height: 50,
            isReadOnly: true,
            hintText: 'Type @sign or search from contact',
            icon: Icons.contacts_rounded,
            onTap: () {},
          ),
          Expanded(child: SizedBox()),
          Center(
            child: CustomButton(
              buttonText: 'Request',
              onPressed: onRequestTap,
              width: 164,
              height: 48,
            ),
          )
        ],
      ),
    );
  }

  onRequestTap() async {}
}
