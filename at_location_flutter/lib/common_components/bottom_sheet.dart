import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:flutter/material.dart';

Future<void> bottomSheet(BuildContext context, Widget? T, double height, {Function? onSheetCLosed}) async {
  await showModalBottomSheet<Widget>(
      context: context,
      isScrollControlled: true,
      shape: const StadiumBorder(),
      builder: (BuildContext context) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light ? AllColors().WHITE : AllColors().Black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: T,
        );
      }).then((dynamic value) {
    if (onSheetCLosed != null) onSheetCLosed();
  });
}
