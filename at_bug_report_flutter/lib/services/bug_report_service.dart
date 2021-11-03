/// A service to handle save and retrieve operation on chat

import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_bug_report_flutter/utils/strings.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_commons/at_commons.dart';
import 'package:intl/intl.dart';

class BugReportService {
  BugReportService._();

  static final BugReportService _instance = BugReportService._();

  factory BugReportService() => _instance;

  // final String storageKey = 'bugReport.';
  final String bugReportKey = 'bug_report_key';
  final String dateKey = DateFormat('dd-MM-yyy – hh:mm a')
      .format(DateTime.parse(DateTime.now().toString()));

  String? authorAtSign;

  late AtClientManager atClientManager;
  late AtClient atClient;

  String? rootDomain;
  int? rootPort;
  String? currentAtSign;
  String getAtSignError = '';
  String atSignFilter = '';
  bool filterList = false;
  List<BugReport> allBugReports = [];
  List<dynamic>? allBugReportsJson = [];

  List<BugReport> bugReports = [];
  List<dynamic> bugReportsJson = [];

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
      AtClientManager atClientManagerFromApp,
      AtClientPreference atClientPreference,
      String authorAtSignFromApp,
      String currentAtSignFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    authorAtSign = authorAtSignFromApp;
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atClientManager = atClientManagerFromApp;
    atClientManager.setCurrentAtSign(
        currentAtSignFromApp, '', atClientPreference);

    atClient = atClientManager.atClient;

    // notificationService.subscribe(regex: '.wavi').listen((notification) {
    //   _notificationCallback(notification);
    // });

    //   await startMonitor();
    atClientManager.notificationService.subscribe().listen((notification) {
      _notificationCallback(notification);
    });
  }

  /// Listen Notification
  void _notificationCallback(AtNotification atNotification) async {
    // AtNotification atNotification = notification;
    print('atNotification : ${atNotification.toJson()}');
    var notificationKey = atNotification.key;
    var fromAtsign = atNotification.from;

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey = notificationKey.replaceFirst(fromAtsign, '').trim();
    print('notificationKey = $notificationKey');
    if ((notificationKey.startsWith(bugReportKey.toLowerCase()))) {
      print('atNotification.value : ${atNotification.value}');
      var message = atNotification.value ?? '';
      print('value = $message');
      var decryptedMessage = await atClient.encryptionService!
          .decrypt(message, fromAtsign)
          .catchError((e) {
        print('error in decrypting notify $e');
        return '';
      });
      print('notify message => $decryptedMessage $fromAtsign');
      BugReport bugReport = BugReport.fromJson(decryptedMessage);
      allBugReports.insert(0, bugReport);
      allBugReportSink.add(allBugReports);
    }
  }

  /// Get List Bug Report of this AtSign
  Future<void> getBugReports({String? atsign}) async {
    try {
      bugReports = [];
      var allKeys = await atClientManager.atClient.getAtKeys(
          regex: bugReportKey.toLowerCase(), sharedBy: currentAtSign);
      Future.forEach(allKeys, (AtKey atKey) async {
        if (currentAtSign!
            .toLowerCase()
            .contains(atKey.sharedBy!.toLowerCase())) {
          var successValue =
              await AtClientManager.getInstance().atClient.get(atKey);
          BugReport bugReport = BugReport.fromJson(successValue.value);
          bugReports.insert(0, bugReport);
        }
      });
      bugReportSink.add(bugReports);
    } catch (error) {
      print('Error in getting bug Report -> $error');
    }
  }

  /// Get All Bug Report of App
  Future<void> getAllBugReports({String? atsign}) async {
    try {
      if (filterList == true) {
        print('**********FILTER APPLIED*****');
        bugReports = [];
        var allKeys = await atClientManager.atClient.getAtKeys(
            regex: bugReportKey.toLowerCase(), sharedBy: '@meatpattypleasant');
        Future.forEach(allKeys, (AtKey atKey) async {
          if (atsign!.toLowerCase().contains(atKey.sharedBy!.toLowerCase())) {
            var successValue =
                await AtClientManager.getInstance().atClient.get(atKey);
            BugReport bugReport = BugReport.fromJson(successValue.value);
            bugReports.insert(0, bugReport);
            print(bugReport);
          }
        });
        bugReportSink.add(bugReports);
      } else {
        allBugReports = [];
        var allKeys = await atClientManager.atClient
            .getAtKeys(regex: bugReportKey.toLowerCase());
        Future.forEach(allKeys, (AtKey atKey) async {
          var successValue =
              await AtClientManager.getInstance().atClient.get(atKey);
          BugReport bugReport = BugReport.fromJson(successValue.value);
          allBugReports.insert(0, bugReport);
        });
        allBugReportSink.add(allBugReports);
      }
    } catch (error) {
      print('Error in getting allBugReport -> $error');
    }
  }

  AtKey getAtKey(String regexKey) {
    var atKey = AtKey.fromString(regexKey);
    atKey.metadata!.ttr = -1;
    // atKey.metadata.ttl = MixedConstants.maxTTL; // 7 days
    atKey.metadata!.ccd = true;
    return atKey;
  }

  void setAuthorAtSign(String? authorAtSign) {
    this.authorAtSign = authorAtSign!;
  }

  // ignore: always_declare_return_types
  resetData() {
    getAtSignError = '';
  }

  // Filter atsign
  Future<dynamic> filterAtSign(context, String atSign) async {
    if (atSign == null || atSign == '') {
      getAtSignError = Strings.emptyAtsign;
      return true;
    } else if (atSign[0] != '@') {
      atSign = '@' + atSign;
    }
    getAtSignError = '';
  }

  /// Add New Bug Report to AtClient
  Future<bool> setBugReport(BugReport bugReport) async {
    try {
      var key = AtKey()
        ..key = bugReportKey +
            '_' +
            DateTime.now().microsecondsSinceEpoch.toString()
        ..sharedBy = currentAtSign
        ..sharedWith = authorAtSign
        ..metadata = Metadata()
        ..metadata!.ttr = -1;

      var res = await atClient.put(key, bugReport.toJson());
      if (res) {
        bugReports.insert(0, bugReport);
        bugReportSink.add(bugReports);
      }
      return true;
    } catch (e) {
      print('Error in setting bugReport => $e');
      return false;
    }
  }
}
