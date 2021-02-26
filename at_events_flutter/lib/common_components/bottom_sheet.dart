import 'package:at_events_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

bottomSheet(BuildContext context, T, double height, {Function onSheetCLosed}) {
  Future<void> future = showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: StadiumBorder(),
      builder: (BuildContext context) {
        return Container(
          height: height,
          decoration: new BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AllColors().WHITE
                : AllColors().Black,
            borderRadius: new BorderRadius.only(
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
