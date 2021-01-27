// import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_client/at_client.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:at_commons/at_commons.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDialog extends StatelessWidget {
  ///will display the dialog with the [title] and the error details if set to true else displays the [message]. By default it is set to true.
  final bool isErrorDialog;

  ///if set to true will display the close button.
  final bool showClose;

  ///This is mandate field to display in the dialog.
  final dynamic message;

  ///if set to true will displays the textfield for atsign.
  final bool isAtsignForm;

  ///title of the dialog.
  final String title;

  ///Returns a valid atsign if atsignForm is made true.
  final Function onAtsign;

  ///The context to open this widget.
  final context;

  ///function call on close button press.
  final Function onClose;

  CustomDialog(
      {this.isErrorDialog = false,
      this.message,
      this.title,
      this.isAtsignForm = false,
      this.showClose = false,
      this.onAtsign,
      this.onClose,
      this.context});
  @override
  Widget build(BuildContext context) {
    final TextEditingController _atsignController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    return AlertDialog(
      title: isErrorDialog
          ? Row(
              children: [
                Text(
                  title ?? Strings.errorTitle,
                  style: CustomTextStyles.fontR16primary,
                ),
                Icon(Icons.sentiment_dissatisfied)
              ],
            )
          : isAtsignForm
              ? Text(
                  Strings.enterAtsignTitle,
                  style: CustomTextStyles.fontR16primary,
                )
              : this.title != null
                  ? Text(
                      title,
                      style: CustomTextStyles.fontR16primary,
                    )
                  : this.title,
      content: isAtsignForm
          ? Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value == '') {
                    return '@sign cannot be empty';
                  }
                  return null;
                },
                controller: _atsignController,
                decoration: InputDecoration(
                    hintText: Strings.atsignHintText,
                    prefixText: '@',
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: ColorConstants.appColor))),
              ),
            )
          : _getMessage(this.message, isErrorDialog),
      actions: [
        if (showClose)
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
              this.onClose();
            },
            child: Text(
              Strings.closeTitle,
              style: TextStyle(
                  color: ColorConstants.appColor, fontSize: 14.toFont),
            ),
          ),
        if (isAtsignForm)
          FlatButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context);
                var isExisting = await OnboardingService.getInstance()
                    .isExistingAtsign(_atsignController.text);
                var atsignStatus = await OnboardingService.getInstance()
                    .checkAtsignStatus(atsign: _atsignController.text);
                this.onAtsign(atsignStatus, isExisting, _atsignController.text);
              }
            },
            child: Text(
              Strings.submitButton,
              style: TextStyle(
                  color: ColorConstants.appColor, fontSize: 14.toFont),
            ),
          ),
      ],
    );
  }

  ///Returns corresponding errorMessage for [error].
  String _getErrorMessage(var error) {
    var _onboardingService = OnboardingService.getInstance();
    switch (error.runtimeType) {
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
      case ServerStatus:
        return _getServerStatusMessage(error);
        break;
      case OnboardingStatus:
        return error.message;
        break;
      case ResponseStatus:
        if (error == ResponseStatus.AUTH_FAILED) {
          if (_onboardingService.isPkam) {
            return 'Please provide valid backup zip file to continue.';
          } else {
            return _onboardingService.serverStatus == ServerStatus.activated
                ? 'Please provide a relevant backupzip file to authenticate.'
                : 'Please provide a valid QRcode available on ${AppConstants.website} website to authenticate.';
          }
        } else {
          return '';
        }
        break;
      case String:
        return error;
        break;
      default:
        return 'Unknown error.';
        break;
    }
  }

  String _getServerStatusMessage(ServerStatus message) {
    switch (message) {
      case ServerStatus.unavailable:
      case ServerStatus.stopped:
        return 'Server is unavailable. Please try again later.';
        break;
      case ServerStatus.error:
        return 'Unable to connect. Please check with network connection and try again.';
        break;
      default:
        return '';
        break;
    }
  }

  Widget _getMessage(var message, bool isErrorDialog) {
    if (message == null) {
      return null;
    }
    if (isErrorDialog) {
      message = _getErrorMessage(this.message);
    }
    if (!message.contains(AppConstants.website)) {
      return Text(message, style: CustomTextStyles.fontR16primary);
    }
    int startIndex = message.indexOf(AppConstants.website);
    var text1 = message.substring(0, startIndex),
        text3 = message.substring(startIndex + AppConstants.website.length);

    return RichText(
      // textAlign: TextAlign.center,
      text: TextSpan(style: CustomTextStyles.fontR16primary, children: [
        TextSpan(
          text: text1,
        ),
        TextSpan(
            text: AppConstants.website,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.appColor,
                decoration: TextDecoration.underline),
            recognizer: new TapGestureRecognizer()
              ..onTap = () async {
                var url = AppConstants.website;
                String errorMessage = 'Cannot launch $url';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          isErrorDialog: true,
                          showClose: true,
                          context: context,
                          message: errorMessage,
                        );
                      });
                }
              }),
        TextSpan(text: text3, style: TextStyle(color: Colors.black)),
      ]),
    );
  }
}
