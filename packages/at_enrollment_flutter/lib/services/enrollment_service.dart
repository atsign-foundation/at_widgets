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
  final EnrollmentConfig _enrollmentConfig = EnrollmentConfig();
  AtEnrollmentServiceImpl get getAtEnrollmentServiceImpl =>
      _atEnrollmentServiceImpl;
  late AtClientPreference _atClientPreference;

  /// otp streamController
  StreamController<String> otpStreamController =
      StreamController<String>.broadcast();
  Sink get otpControllerSink => otpStreamController.sink;
  Stream<String> get otpControllerStream => otpStreamController.stream;

  /// enrollment status streamController
  StreamController<Map<String, dynamic>> enrollmentStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  Sink get enrollmentStatusControllerSink => enrollmentStatusController.sink;
  Stream<Map<String, dynamic>> get enrollmentStatusControllerStream =>
      enrollmentStatusController.stream;

  /// pending enrollment requests controller
  StreamController<List<EnrollmentData>> pendingEnrollmentController =
      StreamController<List<EnrollmentData>>.broadcast();
  Sink<List<EnrollmentData>> get pendingEnrollmentControllerSink =>
      pendingEnrollmentController.sink;
  Stream<List<EnrollmentData>> get pendingEnrollmentControllerStream =>
      pendingEnrollmentController.stream;

  set setAtClientPreference(AtClientPreference atClientPreference) {
    _atClientPreference = atClientPreference;
  }

  EnrollmentConfig get enrollmentConfig => _enrollmentConfig;

  /// Stream of contacts' list

  /// enrollment id -> EnrollmentStatus
  Map<String, dynamic> enrollmentDataStatus = {};
  late String currentAtsign;

  init() {
    if (_enrollmentConfig.currentAtsign != null) {
      currentAtsign = _enrollmentConfig.currentAtsign!;
    } else {
      currentAtsign =
          AtClientManager.getInstance().atClient.getCurrentAtSign() ?? '';
    }

    _atEnrollmentServiceImpl = AtEnrollmentServiceImpl(
      currentAtsign,
      getAtClientPreferences(),
    );
  }

  updateEnrollmentConfig(EnrollmentConfig enrollmentConfig) {
    _enrollmentConfig.currentAtsign =
        enrollmentConfig.currentAtsign ?? _enrollmentConfig.currentAtsign;

    _enrollmentConfig.namespace =
        enrollmentConfig.namespace ?? _enrollmentConfig.namespace;

    _enrollmentConfig.device =
        enrollmentConfig.device ?? _enrollmentConfig.device;

    _enrollmentConfig.otp = enrollmentConfig.otp ?? _enrollmentConfig.otp;

    _enrollmentConfig.pin = enrollmentConfig.pin ?? _enrollmentConfig.pin;

    _enrollmentConfig.namespaceActionmap =
        enrollmentConfig.namespaceActionmap ??
            _enrollmentConfig.namespaceActionmap;
  }

  sendEnrollmentRequest() async {
    AtNewEnrollmentRequestBuilder atEnrollmentRequestBuilder =
        AtNewEnrollmentRequestBuilder();

    AtEnrollmentServiceImpl atEnrollmentServiceImpl =
        EnrollmentService.getInstance().getAtEnrollmentServiceImpl;

    atEnrollmentRequestBuilder
      ..setAppName(_enrollmentConfig.namespace!)
      ..setDeviceName('iphone')
      ..setOtp(_enrollmentConfig.otp!)
      ..setNamespaces(_enrollmentConfig.namespaceActionmap!);
    AtEnrollmentRequest atEnrollmentRequest =
        atEnrollmentRequestBuilder.build();
    String enrollResponse = await OnboardingService.getInstance()
        .enroll(atEnrollmentServiceImpl, atEnrollmentRequest);
    print('enrollResponse : ${enrollResponse}');
  }

  AtClientPreference getAtClientPreferences() {
    return _atClientPreference..enableEnrollmentDuringOnboard = true;
  }

  Stream<AtNotification> fetchEnrollmentNotifications() {
    Stream<AtNotification> notificationStream = AtClientManager.getInstance()
        .atClient
        .notificationService
        .subscribe(regex: '__manage');

    notificationStream.listen((AtNotification event) {
      // create EnrollmentRequest and add to stream controller
      // EnrollmentData enrollmentRequest = EnrollmentData();

      // pendingEnrollmentControllerSink.add(enrollmentRequest);
    });

    return notificationStream;
  }

  Future<List<EnrollmentRequest>> fetchPendingRequests() async {
    var atClient = AtClientManager.getInstance().atClient;
    var pendingRequests = await atClient.fetchEnrollmentRequests(
      EnrollListRequestParam(),
    );

    List<EnrollmentData> enrollmentList = [];
    pendingRequests.forEach((EnrollmentRequest element) {
      var enrollmentData = EnrollmentData(
        currentAtsign,
        element.enrollmentKey,
        '',
        element.appName,
        element.deviceName,
        element.namespace,
      );

      enrollmentList.add(enrollmentData);
    });

    pendingEnrollmentControllerSink.add(enrollmentList);
    return pendingRequests;
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

  getEnrollmentStatus({String? enrollmentId}) async {
    var enrollmentStatusFuture =
        getAtEnrollmentServiceImpl.getFinalEnrollmentStatus();
    EnrollmentStatus enrollmentStatus = await enrollmentStatusFuture;
    // enrollmentStatus[res.enrollmentId] = null;
    if (enrollmentId != null) {
      enrollmentDataStatus['status'] = enrollmentStatus;
      enrollmentStatusControllerSink.add(enrollmentDataStatus);
    }
    print('enrollmentStatus : ${enrollmentStatus}');
    print('enrollmentStatusFuture : ${enrollmentStatusFuture}');
  }

  Future<EnrollmentInfo?> getSentEnrollmentData() async {
    var res = await _atEnrollmentServiceImpl.getSentEnrollmentRequest();
    if (res != null) {
      enrollmentDataStatus['id'] = res;
      enrollmentStatusControllerSink.add(enrollmentDataStatus);
      getEnrollmentStatus(enrollmentId: res.enrollmentId);
    }
    return res;
  }
}
