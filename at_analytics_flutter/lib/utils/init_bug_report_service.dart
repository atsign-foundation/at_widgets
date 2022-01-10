// ignore: import_of_legacy_library_into_null_safe

import 'package:at_analytics_flutter/screens/bug_report_dialog.dart';
import 'package:at_analytics_flutter/services/bug_report_service.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The bug report service needs to be initialised.
/// It is expected that the app will first create an AtClientService instance using the preferences
/// and then use it to initialise the bug report service.
void initializeBugReportService(
    AtClientManager atClientManager,
    String authorAtSign,
    String currentAtSign,
    AtClientPreference atClientPreference,
    {rootDomain = 'root.atsign.wtf',
    rootPort = 64}) {
  BugReportService().initBugReportService(atClientManager, atClientPreference,
      authorAtSign, currentAtSign, rootDomain, rootPort);
}

void disposeContactsControllers() {
  BugReportService().disposeControllers();
}

/// Used by the app to share error with author.
Future sendErrorReport(String errorDetail, BuildContext context,
    String authorAtsign, Function successCallback) async {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return BugReportDialog(
        atSign: AtClientManager.getInstance().atClient.getCurrentAtSign(),
        authorAtSign: authorAtsign,
        errorDetail: errorDetail,
        isSuccessCallback: successCallback,
      );
    },
  );
}
