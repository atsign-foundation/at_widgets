class AtFollowsException implements Exception {
  String? errorMessage;
  String? errorDescription;
}

class ResponseTimeOutException extends AtFollowsException {}
