import 'dart:async';
import 'dart:convert';

import 'package:at_auth/at_auth.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_enrollment_flutter/models/enrollment.dart';
import 'package:at_enrollment_flutter/models/enrollment_config.dart';
import 'package:at_onboarding_flutter/localizations/generated/intl/messages_en.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:device_info_plus/device_info_plus.dart';

class EnrollmentApp {
  static final EnrollmentApp _singleton = EnrollmentApp._internal();
  EnrollmentApp._internal();
  factory EnrollmentApp.getInstance() {
    return _singleton;
  }

  String otp = '';
  late AtAuthService _atEnrollmentServiceImpl;
  final EnrollmentConfig _enrollmentConfig = EnrollmentConfig();
  AtAuthService get getAtEnrollmentServiceImpl => _atEnrollmentServiceImpl;
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

  List<EnrollmentData> pendingEnrollmentRequest = [];

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
    _atEnrollmentServiceImpl = AtClientMobile.authService(
      currentAtsign,
      _atClientPreference,
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

  Future<AtEnrollmentResponse?> sendEnrollmentRequest() async {
    EnrollmentRequest enrollrollmentRequest = EnrollmentRequest(
      appName: _enrollmentConfig.namespace!,
      deviceName: await getDeviceModel(),
      otp: _enrollmentConfig.otp!,
      namespaces: _enrollmentConfig.namespaceActionmap!,
    );

    try {
      AtEnrollmentResponse enrollResponse =
          await OnboardingService.getInstance().enroll(
        getAtEnrollmentServiceImpl,
        enrollrollmentRequest,
      );
      print('enrollResponse : ${enrollResponse}');
      return enrollResponse;
    } catch (e) {
      throw Exception(e);
      print('error in sending enrollment request : $e');
    }
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
      var notificationValue = jsonDecode(event.value!);
      // create EnrollmentRequest and add to stream controller
      EnrollmentData enrollmentRequest = EnrollmentData(
          event.from,
          event.key,
          notificationValue['encryptedApkamSymmetricKey'] ?? '',
          notificationValue['appName'] ?? '',
          notificationValue['deviceName'] ?? '',
          notificationValue['namespace'] ?? {});

      pendingEnrollmentRequest = [
        enrollmentRequest,
        ...pendingEnrollmentRequest
      ];

      pendingEnrollmentControllerSink.add(pendingEnrollmentRequest);
    });

    return notificationStream;
  }

  Future<List<EnrollmentData>> fetchPendingRequests() async {
    // If data is already fetched
    if (pendingEnrollmentRequest.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        pendingEnrollmentControllerSink.add(pendingEnrollmentRequest);
      });
      return pendingEnrollmentRequest;
    }

    var atClient = AtClientManager.getInstance().atClient;
    var atClientImpl = atClient as AtClientImpl;
    List<PendingEnrollmentRequest> pendingRequests =
        await atClientImpl.enrollmentService.fetchEnrollmentRequests();

    List<EnrollmentData> enrollmentList = [];
    for (var element in pendingRequests) {
      var enrollmentData = EnrollmentData(
        currentAtsign,
        element.enrollmentId ?? '',
        element.encryptedAPKAMSymmetricKey ?? '',
        element.appName ?? '',
        element.deviceName ?? '',
        element.namespace ?? {},
      );
      enrollmentList.add(enrollmentData);
    }

    pendingEnrollmentControllerSink.add(enrollmentList);
    pendingEnrollmentRequest = enrollmentList;
    return enrollmentList;
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
    var atClient = AtClientManager.getInstance().atClient;
    var atClientImpl = atClient as AtClientImpl;

    ApprovedRequestDecisionBuilder approvedRequestDecisionBuilder =
        ApprovedRequestDecisionBuilder(
      enrollmentId: enrollmentData.enrollmentKey,
      encryptedAPKAMSymmetricKey: enrollmentData.encryptedAPKAMSymmetricKey,
    );

    EnrollmentRequestDecision enrollmentRequestDecision =
        enrollOperationEnum == EnrollOperationEnum.approve
            ? EnrollmentRequestDecision.approved(approvedRequestDecisionBuilder)
            : EnrollmentRequestDecision.denied(enrollmentData.enrollmentKey);

    AtEnrollmentResponse atEnrollmentResponse;
    if (enrollOperationEnum == EnrollOperationEnum.approve) {
      atEnrollmentResponse = await atClientImpl.enrollmentService
          .approve(enrollmentRequestDecision);

      if (atEnrollmentResponse.enrollStatus == EnrollmentStatus.approved) {
        updateEnrollmentRecord(atEnrollmentResponse.enrollmentId);
      }
    } else {
      atEnrollmentResponse =
          await atClientImpl.enrollmentService.deny(enrollmentRequestDecision);

      if (atEnrollmentResponse.enrollStatus == EnrollmentStatus.denied) {
        updateEnrollmentRecord(atEnrollmentResponse.enrollmentId);
      }
    }

    print(
        'Enrollment Id: ${atEnrollmentResponse.enrollmentId} | Enrollment Status ${atEnrollmentResponse.enrollStatus}');
    return atEnrollmentResponse;
  }

  updateEnrollmentRecord(String id) {
    pendingEnrollmentRequest
        .removeWhere((element) => element.enrollmentKey == id);
    pendingEnrollmentControllerSink.add(pendingEnrollmentRequest);
  }

  getEnrollmentStatus({String? enrollmentId}) async {
    var enrollmentStatusFuture =
        getAtEnrollmentServiceImpl.getFinalEnrollmentStatus();
    EnrollmentStatus enrollmentStatus = await enrollmentStatusFuture;
    // enrollmentStatus[res.enrollmentId] = null;
    if (enrollmentId != null) {
      enrollmentDataStatus['status'] = enrollmentStatus;
      enrollmentStatusControllerSink.add(enrollmentDataStatus);
      return enrollmentDataStatus;
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

  Future<String> getDeviceModel() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    BaseDeviceInfo deviceInfo = await deviceInfoPlugin.deviceInfo;
    deviceInfo.data;
    print('deviceInfo : ${deviceInfo.data['model']}');
    return deviceInfo.data['model'] ?? '';
  }
}
