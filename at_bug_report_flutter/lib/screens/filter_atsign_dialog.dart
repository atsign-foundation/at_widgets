import 'package:at_bug_report_flutter/services/bug_report_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  const FilterDialog({
    Key? key,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String atsignName = '';
  void initState() {
    super.initState();
    BugReportService().resetData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var _bugReportService = BugReportService();
    var deviceTextFactor = MediaQuery.of(context).textScaleFactor;
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.toWidth)),
      titlePadding: EdgeInsets.only(
        top: 20.toHeight,
        left: 15.toWidth,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text('Filter By AtSign',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(0xff131219),
                  fontSize: 16.toFont,
                  fontWeight: FontWeight.w700,
                )),
          )
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: (_bugReportService.getAtSignError == '')
                ? 110.toHeight * deviceTextFactor
                : 150.toHeight * deviceTextFactor),
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              onChanged: (value) {
                atsignName = value.toLowerCase().replaceAll(' ', '');
              },
              decoration: InputDecoration(
                prefixText: '@',
                prefixStyle: TextStyle(color: Colors.grey, fontSize: 15.toFont),
                hintText: '\tEnter @Sign',
              ),
              style: TextStyle(fontSize: 15.toFont),
            ),
            (_bugReportService.getAtSignError == '')
                ? Container()
                : SizedBox(
                    height: 10.toHeight,
                  ),
            (_bugReportService.getAtSignError == '')
                ? Container()
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bugReportService.getAtSignError,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  ),
            SizedBox(
              height: 25.toHeight,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    _bugReportService.getAtSignError = '';
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 128.toWidth,
                    height: 40.toHeight,
                    padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.toWidth),
                        color: Colors.white),
                    child: Center(
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.toFont,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _bugReportService.filterList = true;
                    _bugReportService.filterAtSign(context, atsignName);
                    _bugReportService.getAllBugReports(
                        atsign: '@' + atsignName);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 128.toWidth,
                    height: 40.toHeight,
                    padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.toWidth),
                        color: Colors.black),
                    child: Center(
                      child: Text(
                        'Filter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.toFont,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
