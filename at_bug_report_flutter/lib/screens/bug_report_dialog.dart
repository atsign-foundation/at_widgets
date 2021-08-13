import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_bug_report_flutter/utils/strings.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

import 'list_bug_report_screen.dart';

class BugReportDialog extends StatefulWidget {
  final String? screen;
  final String? atSign;
  final String? authorAtSign;

  const BugReportDialog({
    Key? key,
    this.screen = '',
    this.atSign = '',
    this.authorAtSign = '',
  }) : super(key: key);

  @override
  _BugReportDialogState createState() => _BugReportDialogState();
}

class _BugReportDialogState extends State<BugReportDialog> {
  late BugReportService _bugReportService;
  ScrollController? _scrollController;
  bool isExpanded = false;

  @override
  void initState() {
    isExpanded = false;
    _scrollController = ScrollController();
    _bugReportService = BugReportService();
    _bugReportService.setAuthorAtSign(widget.authorAtSign);
    print('Show Error Dialog in ${widget.screen} of ${widget.atSign}');

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await _bugReportService.getBugReports(
        atsign: widget.atSign,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      title: Center(
        child: Text(
          Strings.bugReportTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      content: Container(
        constraints: BoxConstraints(
          minHeight: 110.toHeight,
          maxHeight: 400.toHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Strings.bugReportDescription,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Row(
                    children: [
                      Text(
                        Strings.showDetailsBugReport,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 13),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  onTap: () async {
                    isExpanded = !isExpanded;
                    setState(() {});
                  },
                ),
                Spacer(),
                GestureDetector(
                  child: Text(Strings.shareButtonTitle,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  onTap: () async {
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
                GestureDetector(
                  child: Text(
                    Strings.cancelButtonTitle,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 16.toHeight,
            ),
            StreamBuilder<List<BugReport>>(
              stream: _bugReportService.bugReportStream,
              initialData: _bugReportService.bugReports,
              builder: (context, snapshot) {
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : (snapshot.data == null || snapshot.data!.isEmpty)
                        ? Visibility(
                            visible: isExpanded,
                            child: Center(
                              child: Text('No bug report found'),
                            ),
                          )
                        : Visibility(
                            visible: isExpanded,
                            child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: snapshot.data?.length ?? 3,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.toHeight),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        snapshot.data?[index]?.screen ??
                                            'Screen',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 4.toHeight,
                                      // ),
                                      // Text(
                                      //   snapshot.data?[index]?.atSign ??
                                      //       'AtSign',
                                      //   style: TextStyle(
                                      //     color: Colors.grey,
                                      //     fontSize: 14,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
              },
            ),
          ],
        ),
      ),
    );
  }
}
