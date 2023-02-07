class AtOnboardingStrings {
  //atsign texts
  static const String enterAtsignTitle = 'Enter your atSign';
  static const String freeAtsignTitle = 'Free atSign';
  static const String atsignHintText = 'alice';
  static const String submitButton = 'Submit';
  static const String cancelButton = 'Cancel';
  static const String closeButton = 'Close';
  static const String removeButton = 'Remove';

  //atsignStatus texts
  static String atsignNotFound =
      'Your atSign is not registered yet. Please try with the registered one.';
  static String atsignNull =
      'Your atSign and the server is unreachable. Please try again or contact support@atsign.com';
  static const String scanQr = '';

  //Qrscan texts
  static const String scanQrMessage = 'Just scan the QR code displayed at ';
  static const String pairAtsignTitle = 'Pair your atSign';
  static const String uploadQRTitle = 'Upload activation QR code';
  static const String recurrServerCheck =
      'Trying to reach server to perform authentication. Click to stop rigorous server check';
  static const String stopButtonTitle = 'stop';
  //backuzip file save texts
  static const String backupKeyDescription =
      ' upload your backup key file from stored location which was generated during the pairing process of your atSign.';
  static const String uploadZipTitle = 'Upload backup key file';
  static const String saveBackupKeyTitle = 'Save your key';
  static const String saveImportantTitle = 'IMPORTANT!';
  static const String saveBackupDescription =
      'Please save your key in a secure location (we recommend Google Drive or iCloud Drive). You will need it to sign back in AND use other atPlatform apps.';
  static const String saveButtonTitle = 'SAVE';
  static const String declaration = 'Yes I\'ve saved my backupkey file';
  static const String continueButtonTitle = 'CONTINUE';
  static const String emailNote =
      'Note: We do not share your personal information or use it for financial gain.';

  //custom dialog texts
  static const String errorTitle = 'Error';
  static const String closeTitle = 'Close';
  static const String mailUrlquery = 'subject=Issue from @persona app';
  static const String mailUrlScheme = 'mailto';

  //custom reset button texts
  static const String resetButton = 'Reset';
  static const String resetDescription =
      'This will remove the selected atSign and its details from this app only.';
  static const String noAtsignToReset = 'No atSigns are paired to reset. ';
  static const String resetErrorText =
      'Please select atleast one atSign to reset';
  static const String resetWarningText =
      'Warning: This action cannot be undone';

  //loading messages
  static const String loadingAtsignReady =
      'Getting your atSign ready. Please wait...';
  static const String loadingAtsignStatus =
      'Please wait while fetching atSign status';

  static String backupFileName(String atsign) {
    return '${atsign}_encrypt_keys.atKeys';
  }

  static const String faqTitle = 'FAQ';
  static const String faqUrl = 'https://atsign.com/faqs/#atsigns';

  static const String _basepath = 'assets/images';
  static const String backupZip = '$_basepath/backup_key.png';
}
