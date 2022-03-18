import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:at_server_status/at_server_status.dart';

import 'app_constants.dart';

class ConvertErrorToString {
  String getErrorMessage(dynamic error) {
    OnboardingService _onboardingService = OnboardingService.getInstance();
    switch (error.runtimeType) {
      case AtClientException:
        return 'Unable to perform this action. Please try again.';
      case UnAuthenticatedException:
        return 'Unable to authenticate. Please try again.';
      case NoSuchMethodError:
        return 'Failed in processing. Please try again.';
      case AtConnectException:
        return 'Unable to connect server. Please try again later.';
      case AtIOException:
        return 'Unable to perform read/write operation. Please try again.';
      case AtServerException:
        return 'Unable to activate server. Please contact admin.';
      case SecondaryNotFoundException:
        return 'Server is unavailable. Please try again later.';
      case SecondaryConnectException:
        return 'Unable to connect. Please check with network connection and try again.';
      case InvalidAtSignException:
        return 'Invalid atsign is provided. Please contact admin.';
      case ServerStatus:
        return _getServerStatusMessage(error);
      case OnboardingStatus:
        return error.toString();
      case ResponseStatus:
        if (error == ResponseStatus.authFailed) {
          if (_onboardingService.isPkam!) {
            return 'Please provide valid backupkey file to continue.';
          } else {
            return _onboardingService.serverStatus == ServerStatus.activated
                ? 'Please provide a relevant backupkey file to authenticate.'
                : 'Please provide a valid QRcode to authenticate.';
          }
        } else if (error == ResponseStatus.timeOut) {
          return 'Server response timed out!\nPlease check your network connection and try again. Contact ${AppConstants.contactAddress} if the issue still persists.';
        } else {
          return '';
        }
      case String:
        return error;
      default:
        return 'Unknown error.';
    }
  }

  String _getServerStatusMessage(ServerStatus? message) {
    switch (message) {
      case ServerStatus.unavailable:
      case ServerStatus.stopped:
        return 'Server is unavailable. Please try again later.';
      case ServerStatus.error:
        return 'Unable to connect. Please check with network connection and try again.';
      default:
        return '';
    }
  }
}