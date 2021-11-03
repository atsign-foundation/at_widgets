import 'package:at_bug_report_flutter/screens/filter_atsign_dialog.dart';
import 'package:flutter/material.dart';

/// Show Filter AtSign Dialog
showFilterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return FilterDialog();
    },
  );
}
