import 'package:at_bug_report_flutter/screens/bug_report_dialog.dart';
import 'package:flutter/material.dart';

showBugReportDialog(BuildContext context, String? atSign) {
  showDialog(
    context: context,
    builder: (BuildContext ctxt) {
      return BugReportDialog(atSign: atSign, screen: 'Bug Report Dialog',);
    },
  );
}
