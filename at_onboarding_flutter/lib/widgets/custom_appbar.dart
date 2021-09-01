import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String? title;
  final double elevation;
  final bool showBackButton;
  final List<Widget> actionItems;

  CustomAppBar(
      {this.title,
      this.elevation = 0.0,
      this.showBackButton = false,
      this.actionItems = const <Widget>[]});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              })
          : OnboardingService.getInstance().logo,
      automaticallyImplyLeading: showBackButton,
      backgroundColor: ColorConstants.appColor,
      centerTitle: true,
      title: Text(title!, style: CustomTextStyles.fontR16secondary),
      actions: actionItems.isEmpty ? null : actionItems,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);
}
