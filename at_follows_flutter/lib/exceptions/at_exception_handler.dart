import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_follows_flutter/exceptions/at_follows_exceptions.dart';
import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:at_follows_flutter/services/size_config.dart';

class AtExceptionHandler {
  handle(var exception, BuildContext context) {
    var message = this.errorMessage(exception)!;

    return Center(
        child: Padding(
      padding: EdgeInsets.only(top: SizeConfig().screenHeight * 0.15),
      child: Text(
        message,
        style: CustomTextStyles.fontR14primary,
        textAlign: TextAlign.center,
      ),
    ));
  }

  String? errorMessage(var exception) {
    switch (exception.runtimeType) {
      case AtClientException:
        return 'Unable to perform this action. Please try again.';
        break;
      case UnAuthenticatedException:
        return 'Unable to authenticate. Please try again.';
        break;
      case NoSuchMethodError:
        return 'Failed in processing. Please try again.';
        break;
      case AtConnectException:
        return 'Unable to connect server. Please try again later.';
        break;
      case AtIOException:
        return 'Unable to perform read/write operation. Please try again.';
        break;
      case AtServerException:
        return 'Unable to activate server. Please contact admin.';
        break;
      case SecondaryNotFoundException:
        return 'Server is unavailable. Please try again later.';
        break;
      case SecondaryConnectException:
        return 'Unable to connect. Please check with network connection and try again.';
        break;
      case InvalidAtSignException:
        return 'Invalid atsign is provided. Please contact admin.';
        break;
      case String:
        return exception;
        break;
      case ResponseTimeOutException:
        return 'Server response timed out!\nPlease check your network connection and try again. Contact support@atsign.com if the issue still persists.';
      default:
        return 'Unknown error.';
        break;
    }
  }
}
