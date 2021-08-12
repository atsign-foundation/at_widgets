import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_bug_report_flutter/utils/strings.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';

import 'list_bug_report_screen.dart';

class BugReportDialog extends StatefulWidget {
  final String screen;
  final String? atSign;

  const BugReportDialog({
    Key? key,
    this.screen = '',
    this.atSign = '',
  }) : super(key: key);

  @override
  _BugReportDialogState createState() => _BugReportDialogState();
}

class _BugReportDialogState extends State<BugReportDialog> {
  late BugReportService _bugReportService;

  @override
  void initState() {
    super.initState();
    _bugReportService = BugReportService();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          Strings.shareTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(Strings.shareDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                child: Text(
                  Strings.goToListBugReport,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ListBugReportScreen(
                                atSign: widget.atSign,
                              )));
                },
              ),
              Spacer(),
              TextButton(
                child: Text(Strings.shareButtonTitle,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  await _bugReportService.setBugReport(
                    BugReport(
                      time: DateTime.now().millisecondsSinceEpoch,
                      atSign: widget.atSign,
                      screen: widget.screen,
                    ),
                  );
                },
              ),
              Spacer(),
              TextButton(
                child: Text(Strings.cancelButtonTitle,
                    style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
