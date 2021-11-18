
import 'package:at_analytics_flutter/screens/bug_report_dialog.dart';
import 'package:flutter/material.dart';

/// Show Bug Report Dialog
showBugReportDialog(BuildContext context, String? atSign, String? authorAtSign,
    String? errorDetail,
    {Function()? isSuccessCallback}) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return BugReportDialog(
        atSign: atSign,
        authorAtSign: authorAtSign,
        errorDetail: errorDetail,
        isSuccessCallback: isSuccessCallback,
      );
    },
  );
}
