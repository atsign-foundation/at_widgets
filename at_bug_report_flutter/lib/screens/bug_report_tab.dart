import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class ListBugReportTab extends StatefulWidget {
  final BugReportService? bugReportService;
  final bool isAuthorAtSign;
  final String? atSign;

  const ListBugReportTab({
    Key? key,
    this.bugReportService,
    this.isAuthorAtSign = false,
    this.atSign = '',
  }) : super(key: key);

  @override
  _ListBugReportTabState createState() => _ListBugReportTabState();
}

class _ListBugReportTabState extends State<ListBugReportTab>
    with AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;

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
                : ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 3,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 10.toHeight),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              snapshot.data?[index]?.screen ?? 'Screen',
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
                  );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
