import 'dart:async';
import 'dart:convert';

import 'package:at_auth/at_auth.dart';
import 'package:at_auth/src/auth_constants.dart' as auth_constants;
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_enrollment_flutter/models/enrollment.dart';
import 'package:at_enrollment_flutter/models/enrollment_config.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:device_info_plus/device_info_plus.dart';

class EnrollmentServiceWrapper {
  static final EnrollmentServiceWrapper _singleton =
      EnrollmentServiceWrapper._internal();

  EnrollmentServiceWrapper._internal();

  factory EnrollmentServiceWrapper.getInstance() {
    return _singleton;
  }

  String otp = '';
  late AtAuthService _atAuthService;
  final EnrollmentConfig _enrollmentConfig = EnrollmentConfig();

  AtAuthService get getAtEnrollmentServiceImpl => _atAuthService;
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

  final Completer<EnrollmentAppStatus> enrollmentCompleter =
      Completer<EnrollmentAppStatus>();

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
    _atAuthService = AtClientMobile.authService(
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
    EnrollmentRequest enrollmentRequest = EnrollmentRequest(
      appName: _enrollmentConfig.namespace!,
      deviceName: await getDeviceModel(),
      otp: _enrollmentConfig.otp!,
      namespaces: _enrollmentConfig.namespaceActionmap!,
    );

    try {
      return _atAuthService.enroll(enrollmentRequest);
    } catch (e) {
      throw Exception(e);
    }
  }

  AtClientPreference getAtClientPreferences() {
    return _atClientPreference;
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
    EnrollmentListRequestParam enrollmentListRequestParam =
        EnrollmentListRequestParam();
    enrollmentListRequestParam.enrollmentListFilter = [
      EnrollmentStatus.pending
    ];
    List<Enrollment> pendingRequests = await atClientImpl.enrollmentService!
        .fetchEnrollmentRequests(
            enrollmentListParams: enrollmentListRequestParam);

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

    AtEnrollmentResponse atEnrollmentResponse;
    if (enrollOperationEnum == EnrollOperationEnum.approve) {
      ApprovedRequestDecisionBuilder approvedRequestDecisionBuilder =
          ApprovedRequestDecisionBuilder(
        enrollmentId: enrollmentData.enrollmentKey,
        encryptedAPKAMSymmetricKey: enrollmentData.encryptedAPKAMSymmetricKey,
      );

      EnrollmentRequestDecision enrollmentRequestDecision =
          EnrollmentRequestDecision.approved(approvedRequestDecisionBuilder);

      atEnrollmentResponse = await atClientImpl.enrollmentService!
          .approve(enrollmentRequestDecision);

      if (atEnrollmentResponse.enrollStatus == EnrollmentStatus.approved) {
        updateEnrollmentRecord(atEnrollmentResponse.enrollmentId);
      }
    } else {
      EnrollmentRequestDecision enrollmentRequestDecision =
          EnrollmentRequestDecision.denied(enrollmentData.enrollmentKey);
      atEnrollmentResponse =
          await atClientImpl.enrollmentService!.deny(enrollmentRequestDecision);

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
    var res = await _atAuthService.getSentEnrollmentRequest();
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
    return deviceInfo.data['model'] ?? 'default-device';
  }

  Future<AtOnboardingResponseStatus> authenticateEnrollment() async {
    final OnboardingService onboardingService = OnboardingService.getInstance();
    onboardingService.setAtClientPreference = getAtClientPreferences();
    var authResponse = await onboardingService.authenticate(currentAtsign);
    return authResponse;
  }

  Future<AtOnboardingResponseStatus> authenticate(
      EnrollmentInfo enrollmentInfo) async {
    final OnboardingService _onboardingService =
        OnboardingService.getInstance();
    _onboardingService.setAtClientPreference = getAtClientPreferences();

    var fileContent = enrollmentInfo.atAuthKeys.toMap();
    var aesKey = fileContent[auth_constants.defaultEncryptionPublicKey];

    var authResponse = await _onboardingService.authenticate(
      currentAtsign,
      jsonData: jsonEncode(fileContent),
      decryptKey: aesKey,
    );

    return authResponse;
  }
}
