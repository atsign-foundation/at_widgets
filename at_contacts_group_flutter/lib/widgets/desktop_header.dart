import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopHeader extends StatelessWidget {
  final String? title;
  final ValueChanged<bool>? onFilter;
  List<Widget>? actions;
  List<String> options = [
    'By type',
    'By name',
    'By size',
    'By date',
    'add-btn'
  ];
  bool showBackIcon, isTitleCentered;
  DesktopHeader(
      {this.title,
      this.showBackIcon = true,
      this.onFilter,
      this.actions,
      this.isTitleCentered = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig().screenWidth - TextConstants.SIDEBAR_WIDTH,
      child: Row(
        children: <Widget>[
          SizedBox(width: 20),
          showBackIcon
              ? InkWell(
                  onTap: () {
                    // DesktopSetupRoutes.nested_pop();
                  },
                  child: Icon(Icons.arrow_back),
                )
              : SizedBox(),
          SizedBox(width: 15),
          title != null && isTitleCentered
              ? Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Center(
                      child: Text(
                        title!,
                        style: CustomTextStyles.primaryRegular20,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          title != null && !isTitleCentered
              ? Container(
                  child: Center(
                    child: Text(
                      title!,
                      style: CustomTextStyles.primaryRegular20,
                    ),
                  ),
                )
              : SizedBox(),
          SizedBox(width: 15),
          !isTitleCentered ? Expanded(child: SizedBox()) : SizedBox(),
          actions != null
              ? Row(
                  children: actions!,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
