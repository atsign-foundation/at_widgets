import 'package:flutter/material.dart';
import 'package:at_client/at_client.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_server_status/at_server_status.dart';

class AtErrorDialog {
  static AlertDialog getAlertDialog(Object error, BuildContext context) {
    String errorMessage = _getErrorMessage(error);
    String title = 'Error';
    return AlertDialog(
      title: Row(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          const Icon(Icons.sentiment_dissatisfied)
        ],
      ),
      content: Text('$errorMessage'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        )
      ],
    );
  }

  ///Returns corresponding errorMessage for [error].
  static String _getErrorMessage(Object error) {
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
      // case ServerStatus:
      //   return _getServerStatusMessage(error);
      // case OnboardingStatus:
      //   return _message(error);
      default:
        return 'unable to connect. Please refresh the page';
    }
  }

  static String _getServerStatusMessage(ServerStatus message) {
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

  static String _message(OnboardingStatus status) {
    switch (status) {
      case (OnboardingStatus.ENCRYPTION_PRIVATE_KEY_NOT_FOUND):
      case (OnboardingStatus.ENCRYPTION_PUBLIC_KEY_NOT_FOUND):
      case (OnboardingStatus.PKAM_PRIVATE_KEY_NOT_FOUND):
      case (OnboardingStatus.PKAM_PUBLIC_KEY_NOT_FOUND):
        return 'Fatal error occurred. Please contact support@atsign.com';
      case (OnboardingStatus.RESTORE):
        return 'Please restore it with the available backup zip file as the local keys were missing.';
      default:
        return '';
    }
  }
}

extension customMessages on OnboardingStatus {}
