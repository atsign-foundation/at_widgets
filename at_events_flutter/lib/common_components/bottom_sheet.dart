import 'package:at_events_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

Future<void> bottomSheet(BuildContext context, Widget? T, double height, {Function? onSheetCLosed}) async {
  dynamic future = await showModalBottomSheet(
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
      });

  future!.then((dynamic value) {
    if (onSheetCLosed != null) onSheetCLosed();
  });
}
