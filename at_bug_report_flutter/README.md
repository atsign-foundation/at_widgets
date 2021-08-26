<img src="https://atsign.dev/assets/img/@developersmall.png?sanitize=true">

### Now for some internet optimism.

# at_bug_report_flutter

A flutter plugin to create bug report and show list bug report.

## Getting Started

This plugin provides a bug report widget.

### Initialising
The bug report service needs to be initialised. It is expected that the app will first create an AtClientService instance using the preferences and then use it to initialise the bug report service.

```
initializeBugReportService(
        clientSdkService.atClientServiceInstance.atClient, activeAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
```

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