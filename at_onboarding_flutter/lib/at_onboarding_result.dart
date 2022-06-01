enum AtOnboardingResultStatus {
  success, //Authenticate success
  error, //Authenticate error
  cancel, //User canceled
}

class AtOnboardingResult {
  AtOnboardingResultStatus status;
  String? message;
  String? errorCode;
  String? atsign;

  AtOnboardingResult._({
    required this.status,
    this.message,
    this.errorCode,
    this.atsign,
  });

  factory AtOnboardingResult.success({
    required String atsign,
  }) {
    return AtOnboardingResult._(
      status: AtOnboardingResultStatus.success,
      atsign: atsign,
    );
  }

  factory AtOnboardingResult.error({
    String? message,
    String? errorCode,
  }) {
    return AtOnboardingResult._(
      status: AtOnboardingResultStatus.error,
      message: message,
      errorCode: errorCode,
    );
  }

  factory AtOnboardingResult.cancelled() {
    return AtOnboardingResult._(
      status: AtOnboardingResultStatus.cancel,
    );
  }
}
