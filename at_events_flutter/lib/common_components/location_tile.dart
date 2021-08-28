import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class LocationTile extends StatelessWidget {
  final String? title, subTitle;
  final IconData? icon;

  LocationTile({this.title = '', this.subTitle = '', this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          icon != null ? Icon(icon, color: AllColors().ORANGE) : const SizedBox(),
          SizedBox(width: 15.toWidth),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title!, style: CustomTextStyles().greyLabel14),
                Text(subTitle!, style: CustomTextStyles().greyLabel12),
              ],
            ),
          )
        ],
      ),
    );
  }
}
