import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ListBugReportScreen extends StatefulWidget {
  final String title;
  final String? atSign;
  final String? authorAtSign;

  const ListBugReportScreen({
    Key? key,
    this.title = 'List Bug Report',
    this.atSign = '',
    this.authorAtSign = '',
  }) : super(key: key);

  @override
  _ListBugReportScreenState createState() => _ListBugReportScreenState();
}

class _ListBugReportScreenState extends State<ListBugReportScreen> {
  GlobalKey<ScaffoldState>? scaffoldKey;
  ScrollController? _scrollController;
  late BugReportService _bugReportService;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    scaffoldKey = GlobalKey<ScaffoldState>();
    _bugReportService = BugReportService();
    _bugReportService.setAuthorAtSign(widget.authorAtSign);

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await _bugReportService.getBugReports(
        atsign: widget.atSign,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.toHeight),
          topRight: Radius.circular(10.toHeight),
        ),
        child: Container(
          height: SizeConfig().screenHeight,
          margin: EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.toHeight),
              topRight: Radius.circular(10.toHeight),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black87
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: StreamBuilder<List<BugReport>>(
            stream: _bugReportService.bugReportStream,
            initialData: _bugReportService.bugReports,
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
                              padding: EdgeInsets.symmetric(vertical: 10.0),
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
                                  SizedBox(
                                    height: 4.toHeight,
                                  ),
                                  Text(
                                    snapshot.data?[index]?.atSign ?? 'AtSign',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
            },
          ),
        ),
      ),
    );
  }
}
