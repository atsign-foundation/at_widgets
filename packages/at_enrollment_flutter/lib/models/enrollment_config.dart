import 'package:at_client_mobile/at_client_mobile.dart';

class EnrollmentConfig {
  String? namespace;
  String? currentAtsign;
  String? device;
  String? otp;
  String? pin;
  Map<String, String>? namespaceActionmap;

  EnrollmentConfig({
    this.namespace,
    this.currentAtsign,
    this.otp,
    this.pin,
    this.namespaceActionmap,
  });
}

class EnrollmentAppStatus {
  EnrollmentStatus? enrollmentStatus;
  EnrollmentAppStatus({this.enrollmentStatus});
}
