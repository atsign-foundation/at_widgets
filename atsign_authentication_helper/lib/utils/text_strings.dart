class TextStrings {
  TextStrings._();
  static final TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  // onboarding flow texts
  String saveKeyTitle = 'Save your Private Key';
  String importantTitle = 'IMPORTANT!';
  String saveKeyDescription =
      "Please save your private key. For security reasons, it's highly recommended to save it in GDrive/iCloudDrive.";
  String buttonSave = 'SAVE';
  String buttonContinue = 'CONTINUE';

  // scan qr texts
  String scanQrTitle = 'Scan QR Code';
  String scanQrMessage = 'Just scan the QR code displayed at www.atsign.com';
  String scanQrFooter = 'Don’t have an @sign? Get now.';
  String websiteTitle = 'Atsign';
  String upload = 'Upload QR code image';
  String uploadKey = 'Upload key file';
}
