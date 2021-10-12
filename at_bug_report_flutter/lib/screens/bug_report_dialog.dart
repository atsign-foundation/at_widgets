import 'package:at_bug_report_flutter/models/bug_report_model.dart';
import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_bug_report_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class BugReportDialog extends StatefulWidget {
  final String? errorDetail;
  final String? atSign;
  final String? authorAtSign;
  final Function()? isSuccessCallback;

  const BugReportDialog({
    Key? key,
    this.errorDetail = '',
    this.atSign = '',
    this.authorAtSign = '',
    this.isSuccessCallback,
  }) : super(key: key);

  @override
  _BugReportDialogState createState() => _BugReportDialogState();
}

class _BugReportDialogState extends State<BugReportDialog> {
  late BugReportService _bugReportService;
  bool isLoading = false;
  bool isError = false;
  @override
  void initState() {
    isLoading = false;
    isError = false;
    _bugReportService = BugReportService();
    _bugReportService.setAuthorAtSign(widget.authorAtSign);
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
          minHeight: 75.toHeight,
          maxHeight: 300.toHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                text: Strings.bugReportDescription,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.toFont),
                children: <TextSpan>[
                  TextSpan(
                      text: widget.authorAtSign,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 14.toFont)),
                  TextSpan(
                      text: ' ?',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.toFont)),
                ],
              ),
            ),
            SizedBox(height: 20.toHeight),
            Text(widget.errorDetail ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20.toHeight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Visibility(
                  visible: isLoading,
                  child: Container(
                    width: 16.toWidth,
                    height: 16.toHeight,
                    child: CircularProgressIndicator(),
                  ),
                ),
                SizedBox(
                  width: 24.toHeight,
                ),
                GestureDetector(
                  child: Text(Strings.shareButtonTitle,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  onTap: () async {
                    isLoading = true;
                    isError = false;
                    setState(() {});
                    var isSuccess = await _bugReportService.setBugReport(
                      BugReport(
                        time: DateTime.now().toString(),
                        atSign: widget.authorAtSign,
                        errorDetail: widget.errorDetail,
                      ),
                    );
                    if (isSuccess) {
                      if (widget.isSuccessCallback != null) {
                        widget.isSuccessCallback!();
                      }
                      Navigator.of(context).pop();
                    } else {
                      isLoading = false;
                      isError = true;
                      setState(() {});
                    }
                  },
                ),
                SizedBox(
                  width: 32.toHeight,
                ),
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
            Visibility(
              visible: isError,
              child: Container(
                margin: EdgeInsets.only(top: 12.toHeight),
                child: Text(
                  'Something errors',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
