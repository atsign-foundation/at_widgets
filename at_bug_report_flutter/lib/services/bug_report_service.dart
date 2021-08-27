/// A service to handle save and retrieve operation on chat

import 'dart:async';
import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_commons/at_commons.dart';

class BugReportService {
  BugReportService._();

  static final BugReportService _instance = BugReportService._();

  factory BugReportService() => _instance;

  final String storageKey = 'bugReport.';
  final String bugReportKey = 'bugReportKey';

  String authorAtSign = '';

  late AtClientImpl atClientInstance;
  String? rootDomain;
  int? rootPort;
  String? currentAtSign;

  List<BugReport> allBugReports = [];
  List<dynamic>? allBugReportsJson = [];

  List<BugReport> bugReports = [];
  List<dynamic>? bugReportsJson = [];

  StreamController<List<BugReport>> bugReportStreamController =
      StreamController<List<BugReport>>.broadcast();
  Sink get bugReportSink => bugReportStreamController.sink;
  Stream<List<BugReport>> get bugReportStream =>
      bugReportStreamController.stream;

  StreamController<List<BugReport>> allBugReportStreamController =
  StreamController<List<BugReport>>.broadcast();
  Sink get allBugReportSink => allBugReportStreamController.sink;
  Stream<List<BugReport>> get allBugReportStream =>
      allBugReportStreamController.stream;

  void disposeControllers() {
    bugReportStreamController.close();
    allBugReportStreamController.close();
  }

  void initBugReportService(
      AtClientImpl atClientInstanceFromApp,
      String currentAtSignFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    await startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    var privateKey = await getPrivateKey(currentAtSign!);
    await atClientInstance.startMonitor(privateKey, _notificationCallback);
    print('Monitor started');
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    var str = await atClientInstance.getPrivateKey(atsign);
    return str!;
  }

  /// Listen Notification
  void _notificationCallback(dynamic notification) async {
    notification = notification.replaceFirst('notification:', '');
    var responseJson = jsonDecode(notification);
    var notificationKey = responseJson['key'];
    var fromAtsign = responseJson['from'];

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey.replaceFirst(fromAtsign, '');
    notificationKey.trim();

    if ((notificationKey.startsWith(bugReportKey) &&
        fromAtsign == currentAtSign)) {
      var message = responseJson['value'];
      var decryptedMessage = await atClientInstance.encryptionService!
          .decrypt(message, fromAtsign)
          .catchError((e) {
        print('error in decrypting bugReport ${e.errorCode} ${e.errorMessage}');
      });
      print('chat message => $decryptedMessage $fromAtsign');
      await setBugReport(
        BugReport(
          errorDetail: decryptedMessage,
          atSign: fromAtsign,
          time: responseJson['epochMillis'],
        ),
      );
    }
  }

  /// Get List Bug Report
  Future<void> getBugReports({String? atsign}) async {
    try {
      bugReports = [];
      var key = AtKey()
        ..key = storageKey + (atsign ?? currentAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign!
        ..metadata = Metadata();

      var keyValue = await atClientInstance.get(key).catchError((e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });

      // ignore: unnecessary_null_comparison
      if (keyValue != null && keyValue.value != null) {
        bugReportsJson = json.decode((keyValue.value) as String) as List?;
        bugReportsJson!.forEach((value) {
          var bugReport = BugReport.fromJson((value));
          bugReports.insert(0, bugReport);
        });
        bugReportSink.add(bugReports);
      } else {
        bugReportsJson = [];
        bugReportSink.add(bugReports);
      }
    } catch (error) {
      print('Error in getting bug Report -> $error');
    }
  }

  /// Get All Bug Report of App
  Future<void> getAllBugReports({String? atsign}) async {
    try {
      allBugReports = [];
      var key = AtKey()
        ..key = storageKey + (atsign ?? currentAtSign ?? ' ').substring(1)
        ..sharedWith = authorAtSign
        ..metadata = Metadata();

      var keyValue = await atClientInstance.get(key).catchError((e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });

      // ignore: unnecessary_null_comparison
      if (keyValue != null && keyValue.value != null) {
        allBugReportsJson = json.decode((keyValue.value) as String) as List?;
        allBugReportsJson!.forEach((value) {
          var bugReport = BugReport.fromJson((value));
          allBugReports.insert(0, bugReport);
        });
        allBugReportSink.add(allBugReports);
      } else {
        allBugReportsJson = [];
        allBugReportSink.add(allBugReports);
      }
    } catch (error) {
      print('Error in getting allBugReport -> $error');
    }
  }

  void setAuthorAtSign(String? authorAtSign) {
    this.authorAtSign = authorAtSign!;
  }

  /// Add New Bug Report to AtClient
  Future<bool> setBugReport(BugReport bugReport) async {
    try {
      var key = AtKey()
        ..key = storageKey + (currentAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign
        ..metadata = Metadata();

      bugReports.insert(0, bugReport);
      bugReportSink.add(bugReports);
      bugReportsJson!.add(bugReport.toJson());
      await atClientInstance.put(key, json.encode(bugReportsJson));
      return true;
    } catch (e) {
      print('Error in setting bugReport => $e');
      return false;
    }
  }
}
