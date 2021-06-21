import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/screens/atsign_list_screen.dart';
import 'package:at_onboarding_flutter/screens/web_view_screen.dart';
import 'package:at_onboarding_flutter/services/freeAtsignService.dart';
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
import 'package:pin_code_fields/pin_code_fields.dart';
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
  final Function(String) onSubmit;

  ///Returns a valid atsign if atsignForm is made true.
  final Function(String, String) onValidate;

  final Function(List<String>, String) onLimitExceed;

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
      this.onSubmit,
      this.onValidate,
      this.onLimitExceed,
      this.onClose,
      this.context});
  final _formKey = GlobalKey<FormState>();
  TextEditingController _atsignController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  final FreeAtsignService _freeAtsignService = FreeAtsignService();
  String freeAtsign;
  bool otp = false;
  bool pair = false;
  bool isfreeAtsign = false;
  String verificationCode;
  bool loading = false;
  bool wrongEmail = false;
  String oldEmail;
  String limitExceeded = 'limitExceeded';

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, stateSet) {
      return Stack(children: [
        Opacity(
            opacity: loading ? 0.3 : 1,
            child: AbsorbPointer(
                absorbing: loading,
                child: AlertDialog(
                  title: isErrorDialog
                      ? Row(
                          children: [
                            Text(
                              title ?? Strings.errorTitle,
                              style: CustomTextStyles.fontR16primary,
                            ),
                            this.message == ResponseStatus.TIME_OUT
                                ? Icon(Icons.access_time, size: 18.toFont)
                                : Icon(Icons.sentiment_dissatisfied,
                                    size: 18.toFont)
                          ],
                        )
                      : isAtsignForm
                          ? Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 4.0.toFont),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Setting up your account',
                                      style: TextStyle(
                                          color: ColorConstants.appColor,
                                          fontSize: 16.toFont),
                                    ),
                                    SizedBox(height: 15.toHeight),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            !isfreeAtsign
                                                ? Strings.enterAtsignTitle
                                                : !pair
                                                    ? 'Free @sign'
                                                    : !otp
                                                        ? 'Enter your email'
                                                        : 'Enter Verification Code',
                                            style:
                                                CustomTextStyles.fontR16primary,
                                          ),
                                        ),
                                        IconButton(
                                            icon: Icon(
                                              Icons.help,
                                              color: ColorConstants.appColor,
                                              size: 18.toFont,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WebViewScreen(
                                                            title: Strings
                                                                .faqTitle,
                                                            url: Strings.faqUrl,
                                                          )));
                                            })
                                      ],
                                    ),
                                    otp
                                        ? Text(
                                            'A verification code has been sent to ${_emailController.text}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13.toFont),
                                          )
                                        : Container()
                                  ]))
                          : this.title != null
                              ? Text(
                                  title,
                                  style: CustomTextStyles.fontR16primary,
                                )
                              : this.title,
                  content: isAtsignForm
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.toFont),
                          child: Container(
                            width: double.maxFinite,
                            // height:
                            //     MediaQuery.of(context).size.height * 0.6,
                            child: ListView(
                              shrinkWrap: true,
                              // mainAxisSize: MainAxisSize.min,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Form(
                                    key: _formKey,
                                    // autovalidateMode: AutovalidateMode.always,
                                    child: !otp
                                        ? TextFormField(
                                            enabled: isfreeAtsign & !pair
                                                ? false
                                                : true,
                                            style: TextStyle(
                                                fontSize: 14.toFont,
                                                height: 1.0.toHeight),
                                            validator: (value) {
                                              if (value == null ||
                                                  value == '') {
                                                return !pair
                                                    ? '@sign cannot be empty'
                                                    : 'Email cannot be empty';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              stateSet(() {});
                                            },
                                            controller: !pair
                                                ? _atsignController
                                                : _emailController,
                                            decoration: InputDecoration(
                                                fillColor: Colors.blueAccent,
                                                errorStyle: TextStyle(
                                                  fontSize: 12.toFont,
                                                ),
                                                hintText: !pair
                                                    ? Strings.atsignHintText
                                                    : '',
                                                prefixText: !pair ? '@' : '',
                                                prefixStyle: TextStyle(
                                                    color: ColorConstants
                                                        .appColor),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: ColorConstants
                                                            .appColor))),
                                          )
                                        : PinCodeTextField(
                                            animationType: AnimationType.none,
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            appContext: context,
                                            length: 4,
                                            onChanged: (value) {
                                              verificationCode = value;
                                            },
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w500),
                                            pinTheme: PinTheme(
                                              selectedColor: Colors.black,
                                              inactiveColor: Colors.grey[500],
                                              activeColor:
                                                  ColorConstants.appColor,
                                              shape: PinCodeFieldShape.box,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              fieldHeight: 50,
                                              fieldWidth: 45.toWidth,
                                            ),
                                            cursorHeight: 15.toFont,
                                            cursorColor: Colors.grey,
                                            // controller: _otpController,
                                            keyboardType: TextInputType.text,
                                            onCompleted: (v) {
                                              verificationCode = v;
                                            },
                                          )),
                                if (!isfreeAtsign) ...[
                                  SizedBox(height: 15.toHeight),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        key: Key('${Strings.cancelButton}'),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          Strings.cancelButton,
                                          style: TextStyle(
                                              color: ColorConstants.appColor,
                                              fontSize: 12.toFont),
                                        ),
                                      ),
                                      SizedBox(width: 15.toWidth),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    ColorConstants.appColor)),
                                        key: Key('${Strings.submitButton}'),
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            Navigator.pop(context);
                                            this.onSubmit(
                                                _atsignController.text);
                                          }
                                        },
                                        child: Text(
                                          Strings.submitButton,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.toFont),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.toHeight),
                                  Text('Need an @sign?'),
                                  SizedBox(height: 5.toHeight),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.grey[800])),
                                        // key: Key(''),
                                        onPressed: () async {
                                          loading = true;
                                          stateSet(() {});
                                          freeAtsign =
                                              await getFreeAtsign(context);
                                          if (freeAtsign != null) {
                                            _atsignController.text = freeAtsign;
                                            isfreeAtsign = true;
                                          }
                                          loading = false;
                                          stateSet(() {});
                                        },
                                        child: Text(
                                          'Generate Free @sign',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.toFont),
                                        ),
                                      )),
                                ],
                                if (isfreeAtsign) ...[
                                  SizedBox(height: 15.toHeight),
                                  !otp
                                      ? !pair
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .grey[800])),
                                                // key: Key(''),
                                                onPressed: () async {
                                                  loading = true;
                                                  stateSet(() {});
                                                  _atsignController.text =
                                                      await getFreeAtsign(
                                                          context);
                                                  loading = false;
                                                  stateSet(() {});
                                                },
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Center(
                                                          child: Text(
                                                        'Refresh',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                15.toFont),
                                                      )),
                                                      Icon(
                                                        Icons.refresh,
                                                        color: Colors.white,
                                                      )
                                                    ]),
                                              ))
                                          : Column(children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty
                                                            .all((_emailController
                                                                            .text !=
                                                                        '' &&
                                                                    _emailController
                                                                            .text !=
                                                                        null)
                                                                ? Colors
                                                                    .grey[800]
                                                                : Colors.grey[
                                                                    400])),
                                                    // key: Key(''),
                                                    onPressed: () async {
                                                      if (_emailController
                                                                  .text !=
                                                              '' &&
                                                          _emailController
                                                                  .text !=
                                                              null) {
                                                        loading = true;
                                                        stateSet(() {});
                                                        bool status = false;
                                                        if (!wrongEmail) {
                                                          status = await registerPersona(
                                                              _atsignController
                                                                  .text,
                                                              _emailController
                                                                  .text,
                                                              context);
                                                        } else {
                                                          status = await registerPersona(
                                                              _atsignController
                                                                  .text,
                                                              _emailController
                                                                  .text,
                                                              context,
                                                              oldEmail:
                                                                  oldEmail);
                                                        }
                                                        loading = false;
                                                        stateSet(() {});
                                                        if (status) {
                                                          otp = true;
                                                          stateSet(() {});
                                                        }
                                                      }
                                                    },
                                                    child: Center(
                                                        child: Text(
                                                      'Send Code',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.toFont),
                                                    )),
                                                  )),
                                              SizedBox(
                                                height: 10.toHeight,
                                              ),
                                              Text(
                                                Strings.emailNote,
                                                style: TextStyle(
                                                    fontSize: 13.toFont,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Center(
                                                  child: TextButton(
                                                      onPressed: () {
                                                        // isfreeAtsign = false;
                                                        pair = false;
                                                        stateSet(() {});
                                                      },
                                                      child: Text(
                                                        'Back',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[700]),
                                                      )))
                                            ])
                                      : Column(children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty
                                                        .all((_emailController
                                                                        .text !=
                                                                    '' &&
                                                                _emailController
                                                                        .text !=
                                                                    null)
                                                            ? Colors.grey[800]
                                                            : Colors
                                                                .grey[400])),
                                                onPressed: () async {
                                                  if (_emailController.text !=
                                                          '' &&
                                                      _emailController.text !=
                                                          null) {
                                                    loading = true;
                                                    stateSet(() {});
                                                    String result =
                                                        await validatePerson(
                                                            _atsignController
                                                                .text,
                                                            _emailController
                                                                .text,
                                                            verificationCode,
                                                            context);
                                                    loading = false;
                                                    stateSet(() {});
                                                    if (result != null &&
                                                        result !=
                                                            this.limitExceeded) {
                                                      List params =
                                                          result.split(':');
                                                      Navigator.pop(context);
                                                      this.onValidate(
                                                          params[0], params[1]);
                                                    }
                                                  }
                                                },
                                                child: Center(
                                                    child: Text(
                                                  'Verify & Login',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.toFont),
                                                )),
                                              )),
                                          SizedBox(height: 10.toHeight),
                                          TextButton(
                                              onPressed: () async {
                                                if (_emailController.text !=
                                                        '' &&
                                                    _emailController.text !=
                                                        null) {
                                                  loading = true;
                                                  stateSet(() {});
                                                  bool status =
                                                      await registerPersona(
                                                          _atsignController
                                                              .text,
                                                          _emailController.text,
                                                          context);

                                                  loading = false;
                                                  stateSet(() {});
                                                }
                                              },
                                              child: Text(
                                                'Resend Code',
                                                style: TextStyle(
                                                    color: ColorConstants
                                                        .appColor),
                                              )),
                                          SizedBox(height: 10.toHeight),
                                          TextButton(
                                              onPressed: () {
                                                otp = false;
                                                wrongEmail = true;
                                                oldEmail =
                                                    _emailController.text;
                                                stateSet(() {});
                                              },
                                              child: Text(
                                                'Wrong email?',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ))
                                        ]),
                                  if (!pair) ...[
                                    SizedBox(height: 15.toHeight),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      ColorConstants.appColor)),
                                          onPressed: () async {
                                            pair = true;
                                            _emailController.text = '';
                                            stateSet(() {});
                                          },
                                          child: Center(
                                              child: Text(
                                            'Pair',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.toFont),
                                          )),
                                        )),
                                    Center(
                                        child: TextButton(
                                            onPressed: () {
                                              isfreeAtsign = false;
                                              _atsignController.text = '';
                                              stateSet(() {});
                                            },
                                            child: Text(
                                              'Back',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            )))
                                  ]
                                ]
                              ],
                            ),
                          ))
                      : _getMessage(this.message, isErrorDialog),
                  actions: showClose
                      ? [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              this.onClose();
                            },
                            child: Text(
                              Strings.closeTitle,
                              style: TextStyle(
                                  color: ColorConstants.appColor,
                                  fontSize: 14.toFont),
                            ),
                          ),
                        ]
                      : null,
                ))),
      ]);
    });
  }

  //to get free atsign from the server
  Future<String> getFreeAtsign(BuildContext context) async {
    var data;
    String atsign;
    dynamic response = await _freeAtsignService.getFreeAtsigns();
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
      atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      showErrorDialog(context, errorMessage);
    }
    return atsign;
  }

  //To register the person with the provided atsign and email
//It will send an OTP to the registered email
  Future<bool> registerPersona(
      String atsign, String email, BuildContext context,
      {String oldEmail}) async {
    var data;
    bool status = false;
    // String atsign;
    dynamic response = await _freeAtsignService.registerPerson(atsign, email,
        oldEmail: oldEmail);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
      print(data);
      status = true;
      // atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      if (errorMessage.contains('Invalid Email')) {
        oldEmail = email;
      }
      if (errorMessage.contains('maximum number of free @signs')) {
        showlimitDialog(context);
      } else {
        showErrorDialog(context, errorMessage);
      }
    }
    return status;
  }

  //It will validate the person with atsign, email and the OTP.
  //If the validation is successful, it will return a cram secret for the user to login
  Future<String> validatePerson(
      String atsign, String email, String otp, BuildContext context,
      {bool isConfirmation = false}) async {
    var data;
    String cramSecret;
    List<String> atsigns = [];
    // String atsign;

    dynamic response = await _freeAtsignService
        .validatePerson(atsign, email, otp, confirmation: isConfirmation);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
      print(data['data']);
      //check for the atsign list and display them.
      if (data['data'] != null &&
          data['data'].length == 2 &&
          data['status'] != 'error') {
        var responseData = data['data'];
        atsigns.addAll(List<String>.from(responseData['atsigns']));

        if (responseData['newAtsign'] == null) {
          Navigator.pop(context);

          this.onLimitExceed(atsigns, responseData['message']);
          return this.limitExceeded;
        }
        //displays list of atsign along with newAtsign
        else {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AtsignListScreen(
                        atsigns: atsigns,
                        newAtsign: responseData['newAtsign'],
                      ))).then((value) async {
            if (value == responseData['newAtsign']) {
              cramSecret = await this.validatePerson(value, email, otp, context,
                  isConfirmation: true);
              return cramSecret;
            } else {
              Navigator.pop(context);

              this.onSubmit(value);
              return null;
            }
          });
        }
      } else if (data['status'] != 'error') {
        cramSecret = data['cramkey'];
      } else {
        String errorMessage = data['message'];
        showErrorDialog(context, errorMessage);
      }
      // atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      showErrorDialog(context, errorMessage);
    }
    return cramSecret;
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
            return 'Please provide valid backupkey file to continue.';
          } else {
            return _onboardingService.serverStatus == ServerStatus.activated
                ? 'Please provide a relevant backupkey file to authenticate.'
                : 'Please provide a valid QRcode to authenticate.';
          }
        } else if (error == ResponseStatus.TIME_OUT) {
          return 'Server response timed out!\nPlease check your network connection and try again. Contact ${AppConstants.contactAddress} if the issue still persists.';
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

  showErrorDialog(BuildContext context, String errorMessage) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            isErrorDialog: true,
            showClose: true,
            context: context,
            message: errorMessage,
            onClose: () {},
          );
        });
  }

  showlimitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: RichText(
              text: TextSpan(children: [
                TextSpan(
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.toFont,
                      letterSpacing: 0.5),
                  text:
                      'Oops! You already have the maximum number of free @signs. Please login to ',
                ),
                TextSpan(
                    text: 'https://my.atsign.com',
                    style: TextStyle(
                        fontSize: 16.toFont,
                        color: ColorConstants.appColor,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.underline),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () async {
                        var url = 'https://my.atsign.com';
                        String errorMessage = 'Cannot launch $url';
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      }),
                TextSpan(
                  text: '  to select one of your existing @signs.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.toFont,
                      letterSpacing: 0.5),
                ),
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: ColorConstants.appColor),
                  ))
            ],
          );
        });
  }

  Widget _getMessage(var message, bool isErrorDialog) {
    String highLightText = message == ResponseStatus.TIME_OUT
        ? '${AppConstants.contactAddress}'
        : AppConstants.website;
    if (message == null) {
      return null;
    }
    if (isErrorDialog) {
      message = _getErrorMessage(this.message);
    }
    if (!message.contains(highLightText)) {
      return Text(message, style: CustomTextStyles.fontR16primary);
    }
    int startIndex = message.indexOf(highLightText);
    var text1 = message.substring(0, startIndex),
        text3 = message.substring(startIndex + highLightText.length);

    return RichText(
      text: TextSpan(style: CustomTextStyles.fontR16primary, children: [
        TextSpan(
          text: text1,
        ),
        TextSpan(
            text: highLightText,
            style: TextStyle(
                fontSize: 16.toFont,
                fontWeight: FontWeight.bold,
                color: ColorConstants.appColor,
                decoration: TextDecoration.underline),
            recognizer: new TapGestureRecognizer()
              ..onTap = () async {
                final Uri params = Uri(
                  scheme: Strings.mailUrlScheme,
                  path: '${AppConstants.contactAddress}',
                  query: Strings.mailUrlquery, //add subject and body here
                );
                var url = highLightText == AppConstants.contactAddress
                    ? params.toString()
                    : highLightText;
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
                          onClose: () {},
                        );
                      });
                }
              }),
        TextSpan(text: text3, style: TextStyle(color: Colors.black)),
      ]),
    );
  }
}
