import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListBugReportTagUser extends StatefulWidget {
  final BugReportService? bugReportService;
  final bool isAuthorAtSign;
  final String? atSign;

  const ListBugReportTagUser({
    Key? key,
    this.bugReportService,
    this.isAuthorAtSign = false,
    this.atSign = '',
  }) : super(key: key);

  @override
  _ListBugReportTagUserState createState() => _ListBugReportTagUserState();
}

class _ListBugReportTagUserState extends State<ListBugReportTagUser>
    with AutomaticKeepAliveClientMixin {
  late DateTime bugReportTime;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if (!widget.isAuthorAtSign) {
        await widget.bugReportService!.getBugReports(
          atsign: widget.atSign,
        );
      } else {
        await widget.bugReportService!.getAllBugReports(
          atsign: widget.atSign,
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return StreamBuilder<List<BugReport>>(
      stream: widget.isAuthorAtSign
          ? widget.bugReportService!.allBugReportStream
          : widget.bugReportService!.bugReportStream,
      initialData: widget.isAuthorAtSign
          ? widget.bugReportService!.allBugReports
          : widget.bugReportService!.bugReports,
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : (snapshot.data == null || snapshot.data!.isEmpty)
                ? Center(
                    child: Text('No bug report found'),
                  )
                : Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 16.toWidth, vertical: 16.toHeight),
                    child: ListView.separated(
                      itemCount: snapshot.data?.length ?? 0,
                      separatorBuilder: (context, index) => SizedBox(
                        height: 10.toHeight,
                      ),
                      itemBuilder: (context, index) {
                        bugReportTime = DateTime.parse(
                            (snapshot.data?[index].time).toString());
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.toFont),
                          child: Container(
                            color: Colors.white,
                            child: Theme(
                              data: ThemeData(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Issue@ ${DateFormat('dd-MM-yyy – hh:mm a').format(bugReportTime)}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.toFont,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Icon(Icons.keyboard_arrow_down),
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.fromLTRB(
                                          16.toWidth,
                                          2.toHeight,
                                          16.toWidth,
                                          2.toHeight,
                                        ),
                                        child: Text(
                                          '${DateFormat('dd-MM-yyy – hh:mm a').format(bugReportTime)}',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 12.toFont,
                                            height: 1.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.fromLTRB(
                                          16.toWidth,
                                          7.toHeight,
                                          16.toWidth,
                                          16.toHeight,
                                        ),
                                        child: Text(
                                          snapshot.data?[index]?.errorDetail ??
                                              'Error',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Colors.blueGrey[900],
                                            fontSize: 13.toFont,
                                            height: 1.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
