import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:flutter/material.dart';

void bottomSheet(BuildContext context, T, double height,
    {Function onSheetCLosed}) {
  var future = showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: StadiumBorder(),
      builder: (BuildContext context) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AllColors().WHITE
                : AllColors().Black,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12.0),
              topRight: const Radius.circular(12.0),
            ),
          ),
          child: T,
        );
      });

  future.then((value) {
    if (onSheetCLosed != null) onSheetCLosed();
  });
}
