class EnrollmentData {
  late String atSign;
  late String enrollmentKey;
  late String encryptedAPKAMSymmetricKey;
  late String appName;
  late String deviceName;
  late Map<String, dynamic> namespace;

  EnrollmentData(
      this.atSign,
      this.enrollmentKey,
      this.encryptedAPKAMSymmetricKey,
      this.appName,
      this.deviceName,
      this.namespace);
}
