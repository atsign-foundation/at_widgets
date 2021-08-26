<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_bug_report_flutter

A flutter example to create bug report and show list bug report.

## Getting Started

This plugin provides a bug report widget.

### Sample Usage

Show Bug Report Dialog
```
showBugReportDialog(
   context,
   activeAtSign,
   '',
   'This is error from Bug Report Example Screen',
   isSuccessCallback: () {},
);
```

Navigate to List Bug Report Screen
```
await Navigator.push(
  context,
  MaterialPageRoute(
      builder: (context) => ListBugReportScreen(
         atSign: activeAtSign,
         authorAtSign: '',
      ),
  );
);
```