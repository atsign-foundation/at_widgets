import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
// ignore: import_of_legacy_library_into_null_safe

/// The bug report service needs to be initialised.
/// It is expected that the app will first create an AtClientService instance using the preferences
/// and then use it to initialise the bug report service.
void initializeBugReportService(
    AtClientManager atClientManager,
    String currentAtSign, AtClientPreference atClientPreference,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  BugReportService().initBugReportService(
      atClientManager, atClientPreference, currentAtSign, rootDomain, rootPort);
}

void disposeContactsControllers() {
  BugReportService().disposeControllers();
}
