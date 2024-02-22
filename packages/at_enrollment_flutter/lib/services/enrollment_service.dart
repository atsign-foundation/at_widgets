import 'dart:async';

import 'package:at_auth/at_auth.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_enrollment_flutter/models/enrollment.dart';
import 'package:at_enrollment_flutter/models/enrollment_config.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';

class EnrollmentService {
  static final EnrollmentService _singleton = EnrollmentService._internal();
  EnrollmentService._internal();
  factory EnrollmentService.getInstance() {
    return _singleton;
  }

  String otp = '';
  late AtEnrollmentServiceImpl _atEnrollmentServiceImpl;
  late EnrollmentConfig _enrollmentConfig;
  AtEnrollmentServiceImpl get getAtEnrollmentServiceImpl =>
      _atEnrollmentServiceImpl;

  StreamController<String> otpStreamController =
      StreamController<String>.broadcast();

  /// Sink for the contacts' list stream
  Sink get otpControllerSink => otpStreamController.sink;

  /// Stream of contacts' list
  Stream<String> get otpControllerStream => otpStreamController.stream;

  init(EnrollmentConfig enrollmentConfig) {
    _enrollmentConfig = enrollmentConfig;
    // TODO: replace with actual atsign
    _atEnrollmentServiceImpl = AtEnrollmentServiceImpl(
      // AtClientManager.getInstance().atClient.getCurrentAtSign() ?? '',
      '@46honest',
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

  Future<String?> getOTPFromServer({bool refresh = false}) async {
    if (!refresh && otp != '') {
      otpControllerSink.add(otp);
      return otp;
    }

    String? tempOtp = await AtClientManager.getInstance()
        .atClient
        .getRemoteSecondary()
        ?.executeCommand('otp:get\n', auth: true);
    tempOtp = tempOtp?.replaceAll('data:', '');
    otp = tempOtp ?? '';
    otpControllerSink.add(otp);
    print('otp: $otp');
    return otp;
  }

  sendEnrollmentRequest() async {
    AtNewEnrollmentRequestBuilder atEnrollmentRequestBuilder =
        AtNewEnrollmentRequestBuilder();

    AtEnrollmentServiceImpl atEnrollmentServiceImpl =
        EnrollmentService.getInstance().getAtEnrollmentServiceImpl;

    atEnrollmentRequestBuilder
      ..setAppName('wavi')
      ..setDeviceName('iphone')
      ..setOtp('2JWC2T')
      ..setNamespaces({'wavi': 'rw'});
    AtEnrollmentRequest atEnrollmentRequest =
        atEnrollmentRequestBuilder.build();
    String enrollResponse = await OnboardingService.getInstance()
        .enroll(atEnrollmentServiceImpl, atEnrollmentRequest);
    print('enrollResponse : ${enrollResponse}');
    // EnrollResponse enrollResponse =
    //     await OnboardingService.getInstance().enroll(
    //   atEnrollmentServiceImpl,
    //   atEnrollmentRequest,
    // );
  }

// approves or denies the enrollment request
  manageEnrollmentRequest(EnrollmentData enrollmentData,
      EnrollOperationEnum enrollOperationEnum) async {
    AtEnrollmentServiceImpl atEnrollmentServiceImpl = AtEnrollmentServiceImpl(
      enrollmentData.atSign,
      EnrollmentService.getInstance().getAtClientPreferences(),
    );
    String enrollmentId = enrollmentData.enrollmentKey
        .substring(0, enrollmentData.enrollmentKey.indexOf('.'));
    AtEnrollmentNotificationRequestBuilder atEnrollmentRequestBuilder =
        AtEnrollmentNotificationRequestBuilder();

    atEnrollmentRequestBuilder.setEnrollmentId(enrollmentId);
    atEnrollmentRequestBuilder.setEnrollOperationEnum(
      enrollOperationEnum,
    );
    atEnrollmentRequestBuilder.setEncryptedApkamSymmetricKey(
        enrollmentData.encryptedAPKAMSymmetricKey);
    AtEnrollmentNotificationRequest atEnrollmentRequest =
        atEnrollmentRequestBuilder.build();

    AtEnrollmentResponse atEnrollmentResponse =
        await atEnrollmentServiceImpl.approve(atEnrollmentRequest);
    print(
        'Enrollment Id: ${atEnrollmentResponse.enrollmentId} | Enrollment Status ${atEnrollmentResponse.enrollStatus}');
    return atEnrollmentResponse;
  }

  getEnrollmentStatus() async {
    var enrollmentStatusFuture =
        getAtEnrollmentServiceImpl.getFinalEnrollmentStatus();
    print('enrollmentStatus : ${enrollmentStatusFuture}');
    EnrollmentStatus enrollmentStatus = await enrollmentStatusFuture;
    print('enrollmentStatus : ${enrollmentStatus}');
    print('enrollmentStatusFuture : ${enrollmentStatusFuture}');
  }
}
