import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class TextTile extends StatelessWidget {
  final String title;
  final IconData icon;
  TextTile({this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          icon != null ? Icon(icon) : SizedBox(),
          SizedBox(width: 10),
          title != null
              ? Text(title, style: CustomTextStyles().darkGrey16)
              : SizedBox()
        ],
      ),
    );
  }
}
