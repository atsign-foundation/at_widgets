import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:at_server_status/at_server_status.dart';

class AtOnboardingErrorToString {
  String getErrorMessage(dynamic error) {
    OnboardingService onboardingService = OnboardingService.getInstance();
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
      case AtOnboardingResponseStatus:
        if (error == AtOnboardingResponseStatus.authFailed) {
          if (onboardingService.isPkam!) {
            return 'Please provide valid backupkey file to continue.';
          } else {
            return onboardingService.serverStatus == ServerStatus.activated
                ? 'Please provide a relevant backupkey file to authenticate.'
                : 'Please provide a valid QRcode to authenticate.';
          }
        } else if (error == AtOnboardingResponseStatus.timeOut) {
          return 'Server response timed out!\nPlease check your network connection and try again. Contact ${AtOnboardingConstants.contactAddress} if the issue still persists.';
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

  String pairedAtsign(String? atsign) =>
      '$atsign was already paired with this device. First delete/reset this atSign from device to add.';

  String atsignMismatch(String? givenAtsign, {bool isQr = false}) {
    if (isQr) {
      return 'atSign mismatches. Please provide the QRcode of $givenAtsign to pair.';
    } else {
      return 'atSign mismatches. Please provide the backup key file of $givenAtsign to pair.';
    }
  }
}
