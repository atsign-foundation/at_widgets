import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_enrollment_app/models/enrollment_config.dart';

class EnrollmentService {
  static final EnrollmentService _singleton = EnrollmentService._internal();
  EnrollmentService._internal();
  factory EnrollmentService.getInstance() {
    return _singleton;
  }

  late AtEnrollmentServiceImpl _atEnrollmentServiceImpl;
  late EnrollmentConfig _enrollmentConfig;
  get getAtEnrollmentServiceImpl => _atEnrollmentServiceImpl;

  StreamController<String> otpStreamController =
      StreamController<String>.broadcast();

  /// Sink for the contacts' list stream
  Sink get otpControllerSink => otpStreamController.sink;

  /// Stream of contacts' list
  Stream<String> get otpControllerStream => otpStreamController.stream;

  init(EnrollmentConfig enrollmentConfig) {
    enrollmentConfig = _enrollmentConfig;
    _atEnrollmentServiceImpl = AtEnrollmentServiceImpl(
      AtClientManager.getInstance().atClient.getCurrentAtSign() ?? '',
      getAtClientPreferences(),
    );
  }

  getAtClientPreferences() {
    return AtClientPreference()
      ..rootDomain = _enrollmentConfig.rootDomain
      ..namespace = _enrollmentConfig.namespace
      ..isLocalStoreRequired = true
      ..enableEnrollmentDuringOnboard = true;
  }

  Stream<AtNotification> fetchEnrollmentNotifications() {
    Stream<AtNotification> notificationStream = AtClientManager.getInstance()
        .atClient
        .notificationService
        .subscribe(regex: '__manage');

    // notificationStream.listen((event) { });
    return notificationStream;
  }

  Future<String?> getOTPFromServer() async {
    String? tempOtp = await AtClientManager.getInstance()
        .atClient
        .getRemoteSecondary()
        ?.executeCommand('otp:get\n', auth: true);
    tempOtp = tempOtp?.replaceAll('data:', '');
    otpControllerSink.add(tempOtp);
    print('otp: $tempOtp');
    return tempOtp;
  }
}
