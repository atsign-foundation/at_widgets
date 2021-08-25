import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/screens/atsign_list_screen.dart';
import 'package:at_onboarding_flutter/screens/web_view_screen.dart';
import 'package:at_onboarding_flutter/services/free_atsign_service.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class CustomDialog extends StatefulWidget {
  ///will display the dialog with the [title] and the error details if set to true else displays the [message]. By default it is set to true.
  final bool isErrorDialog;

  ///if set to true will display the close button.
  final bool showClose;

  ///This is mandate field to display in the dialog.
  final dynamic message;

  ///if set to true will displays the textfield for atsign.
  final bool isAtsignForm;

  ///title of the dialog.
  final String? title;

  ///reference for the dialog if the atsign not activated.
  final bool isQR;

  ///Entered atsign.
  final String atsign;

  ///Returns a valid atsign if atsignForm is made true.
  final Function(String)? onSubmit;

  ///Returns a valid atsign if atsignForm is made true.
  final Function(String, String, bool)? onValidate;

  final Function(List<String>, String)? onLimitExceed;

  ///The context to open this widget.
  final BuildContext? context;

  ///function call on close button press.
  final Function? onClose;

  CustomDialog(
      {this.context,
      this.isErrorDialog = false,
      this.message,
      this.title,
      this.isAtsignForm = false,
      this.showClose = false,
      this.atsign = '',
      this.isQR = false,
      this.onSubmit,
      this.onValidate,
      this.onLimitExceed,
      this.onClose});

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _atsignController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final FreeAtsignService _freeAtsignService = FreeAtsignService();

  String? freeAtsign;

  bool otp = false;

  bool pair = false;

  bool isfreeAtsign = false;

  String? verificationCode;

  bool loading = false;

  bool wrongEmail = false;

  String? oldEmail;

  String limitExceeded = 'limitExceeded';

  bool isQrScanner = false;

  QrReaderViewController? _controller;

  Future<bool>? scanResult;

  @override
  Widget build(BuildContext context) {
    if (widget.isQR) {
      otp = true;
      pair = true;
      isfreeAtsign = true;
    }
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) stateSet) {
      return Stack(children: <Widget>[
        Opacity(
            opacity: loading ? 0.3 : 1,
            child: AbsorbPointer(
                absorbing: loading,
                child: AlertDialog(
                  title: widget.isErrorDialog
                      ? Row(
                          children: <Widget>[
                            Text(
                              widget.title ?? Strings.errorTitle,
                              style: CustomTextStyles.fontR16primary,
                            ),
                            widget.message == ResponseStatus.TIME_OUT
                                ? Icon(Icons.access_time, size: 18.toFont)
                                : Icon(Icons.sentiment_dissatisfied, size: 18.toFont)
                          ],
                        )
                      : widget.isAtsignForm
                          ? isQrScanner
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.0.toFont),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                    Text(
                                      'Scan your QR!',
                                      style: TextStyle(color: ColorConstants.appColor, fontSize: 16.toFont),
                                    ),
                                    SizedBox(height: 20.toHeight),
                                    Container(
                                      width: 300.toWidth,
                                      height: 350.toHeight,
                                      child: QrReaderView(
                                        width: 300.toWidth,
                                        height: 350.toHeight,
                                        callback: (QrReaderViewController controller) {
                                          _controller = controller;
                                          _controller!.startCamera((String data, List<Offset> offsets) {
                                            onScan(data, offsets, context);
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20.toHeight),
                                    loading
                                        ? Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.grey[800])),
                                              // key: Key(''),
                                              onPressed: () {
                                                setState(() {
                                                  isQrScanner = false;
                                                });
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(color: Colors.white, fontSize: 15.toFont),
                                              ),
                                            ))
                                        : const SizedBox(
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          )
                                  ]),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.0.toFont),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                    Text(
                                      'Setting up your account',
                                      style: TextStyle(color: ColorConstants.appColor, fontSize: 16.toFont),
                                    ),
                                    SizedBox(height: 15.toHeight),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            !isfreeAtsign
                                                ? widget.isQR
                                                    ? 'Enter Verification code'
                                                    : Strings.enterAtsignTitle
                                                : !pair
                                                    ? 'Free @sign'
                                                    : !otp
                                                        ? 'Enter your email'
                                                        : 'Enter Verification Code',
                                            style: CustomTextStyles.fontR16primary,
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
                                                  MaterialPageRoute<Widget>(
                                                      builder: (BuildContext context) => WebViewScreen(
                                                            title: Strings.faqTitle,
                                                            url: Strings.faqUrl,
                                                          )));
                                            })
                                      ],
                                    ),
                                    otp
                                        ? Text(
                                            !widget.isQR
                                                ? 'A verification code has been sent to ${_emailController.text}'
                                                : 'A verification code has been sent to your registered email.',
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.toFont),
                                          )
                                        : Container()
                                  ]))
                          : widget.title != null
                              ? Text(
                                  widget.title!,
                                  style: CustomTextStyles.fontR16primary,
                                )
                              : widget.title as Widget?,
                  content: widget.isAtsignForm && !isQrScanner
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
                              children: <Widget>[
                                Form(
                                    key: _formKey,
                                    child: !otp
                                        ? TextFormField(
                                            enabled: isfreeAtsign & !pair ? false : true,
                                            style: TextStyle(fontSize: 14.toFont, height: 1.0.toHeight),
                                            validator: (String? value) {
                                              if (value == null || value == '') {
                                                return !pair ? '@sign cannot be empty' : 'Email cannot be empty';
                                              }
                                              return null;
                                            },
                                            onChanged: (String value) {
                                              stateSet(() {});
                                            },
                                            controller: !pair ? _atsignController : _emailController,
                                            inputFormatters: <TextInputFormatter>[
                                              LengthLimitingTextInputFormatter(80),
                                              !pair
                                                  ? FilteringTextInputFormatter.allow(
                                                      RegExp(
                                                        '[a-zA-Z0-9_]|\u00a9|\u00af|[\u2155-\u2900]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]',
                                                      ),
                                                    )
                                                  : FilteringTextInputFormatter.allow(
                                                      RegExp('[a-zA-Z0-9.@_]'),
                                                    ),
                                              // This inputFormatter function will convert all the input to lowercase.
                                              TextInputFormatter.withFunction(
                                                  (TextEditingValue oldValue, TextEditingValue newValue) {
                                                return newValue.copyWith(
                                                  text: newValue.text.toLowerCase(),
                                                  selection: newValue.selection,
                                                );
                                              })
                                            ],
                                            textCapitalization: TextCapitalization.none,
                                            decoration: InputDecoration(
                                              fillColor: Colors.blueAccent,
                                              errorStyle: TextStyle(
                                                fontSize: 12.toFont,
                                              ),
                                              hintText: !pair ? Strings.atsignHintText : '',
                                              prefixText: !pair ? '@' : '',
                                              prefixStyle: TextStyle(color: ColorConstants.appColor),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: ColorConstants.appColor,
                                                ),
                                              ),
                                            ),
                                          )
                                        : PinCodeTextField(
                                            animationType: AnimationType.none,
                                            textCapitalization: TextCapitalization.characters,
                                            appContext: context,
                                            length: 4,
                                            onChanged: (String value) {
                                              verificationCode = value;
                                            },
                                            textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                            pinTheme: PinTheme(
                                              selectedColor: Colors.black,
                                              inactiveColor: Colors.grey[500],
                                              activeColor: ColorConstants.appColor,
                                              shape: PinCodeFieldShape.box,
                                              borderRadius: BorderRadius.circular(5),
                                              fieldHeight: 50,
                                              fieldWidth: 45.toWidth,
                                            ),
                                            cursorHeight: 15.toFont,
                                            cursorColor: Colors.grey,
                                            // controller: _otpController,
                                            keyboardType: TextInputType.text,
                                            onCompleted: (String v) {
                                              verificationCode = v;
                                            },
                                          )),
                                if (!isfreeAtsign && !widget.isQR && !isQrScanner) ...<Widget>[
                                  SizedBox(height: 15.toHeight),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      TextButton(
                                        key: const Key(Strings.cancelButton),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          Strings.cancelButton,
                                          style: TextStyle(color: ColorConstants.appColor, fontSize: 12.toFont),
                                        ),
                                      ),
                                      SizedBox(width: 15.toWidth),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(ColorConstants.appColor)),
                                        key: const Key(Strings.submitButton),
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            Navigator.pop(context);
                                            widget.onSubmit!(_atsignController.text.toLowerCase());
                                          }
                                        },
                                        child: Text(
                                          Strings.submitButton,
                                          style: TextStyle(color: Colors.white, fontSize: 12.toFont),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.toHeight),
                                  const Text('Need an @sign?'),
                                  SizedBox(height: 5.toHeight),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        style:
                                            ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[800])),
                                        // key: Key(''),
                                        onPressed: () async {
                                          loading = true;
                                          stateSet(() {});
                                          freeAtsign = await getFreeAtsign(context);
                                          if (freeAtsign != null) {
                                            _atsignController.text = freeAtsign!;
                                            isfreeAtsign = true;
                                          }
                                          loading = false;
                                          stateSet(() {});
                                        },
                                        child: Text(
                                          'Generate Free @sign',
                                          style: TextStyle(color: Colors.white, fontSize: 15.toFont),
                                        ),
                                      )),
                                  SizedBox(height: 20.toHeight),
                                  const Text('Have a QR Code?'),
                                  SizedBox(height: 5.toHeight),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        style:
                                            ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[800])),
                                        // key: Key(''),
                                        onPressed: () async {
                                          await _verifyCameraPermissions();
                                          setState(() {
                                            isQrScanner = true;
                                          });
                                        },
                                        child: Text(
                                          'Scan QR code',
                                          style: TextStyle(color: Colors.white, fontSize: 15.toFont),
                                        ),
                                      )),
                                ],
                                if (isfreeAtsign) ...<Widget>[
                                  SizedBox(height: 15.toHeight),
                                  !otp
                                      ? !pair
                                          ? Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(Colors.grey[800])),
                                                // key: Key(''),
                                                onPressed: () async {
                                                  loading = true;
                                                  stateSet(() {});
                                                  _atsignController.text = await getFreeAtsign(context) ?? '';
                                                  loading = false;
                                                  stateSet(() {});
                                                },
                                                child:
                                                    Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                                  Center(
                                                      child: Text(
                                                    'Refresh',
                                                    style: TextStyle(color: Colors.white, fontSize: 15.toFont),
                                                  )),
                                                  const Icon(
                                                    Icons.refresh,
                                                    color: Colors.white,
                                                  )
                                                ]),
                                              ))
                                          : Column(children: <Widget>[
                                              Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(
                                                            (_emailController.text != '')
                                                                ? Colors.grey[800]
                                                                : Colors.grey[400])),
                                                    // key: Key(''),
                                                    onPressed: () async {
                                                      if (_emailController.text != '') {
                                                        loading = true;
                                                        stateSet(() {});
                                                        bool status = false;
                                                        if (!wrongEmail) {
                                                          status = await registerPersona(
                                                              _atsignController.text, _emailController.text, context);
                                                        } else {
                                                          status = await registerPersona(
                                                              _atsignController.text, _emailController.text, context,
                                                              oldEmail: oldEmail);
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
                                                      style: TextStyle(color: Colors.white, fontSize: 15.toFont),
                                                    )),
                                                  )),
                                              SizedBox(
                                                height: 10.toHeight,
                                              ),
                                              Text(
                                                Strings.emailNote,
                                                style: TextStyle(fontSize: 13.toFont, fontWeight: FontWeight.w600),
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
                                                        style: TextStyle(color: Colors.grey[700]),
                                                      )))
                                            ])
                                      : Column(children: <Widget>[
                                          Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor: MaterialStateProperty.all(
                                                        (_emailController.text != '' || widget.isQR)
                                                            ? Colors.grey[800]
                                                            : Colors.grey[400])),
                                                onPressed: () async {
                                                  if ((_emailController.text != '') || widget.isQR) {
                                                    loading = true;
                                                    stateSet(() {});

                                                    String? result;
                                                    if (widget.isQR) {
                                                      result = await validatewithAtsign(
                                                          widget.atsign, verificationCode!, context);
                                                    } else {
                                                      result = await validatePerson(_atsignController.text,
                                                          _emailController.text, verificationCode, context);
                                                    }

                                                    loading = false;
                                                    stateSet(() {});
                                                    if (result != null && result != limitExceeded) {
                                                      List<String> params = result.split(':');
                                                      Navigator.pop(context);
                                                      widget.onValidate!(params[0], params[1], false);
                                                    }
                                                  }
                                                },
                                                child: Center(
                                                    child: Text(
                                                  'Verify & Login',
                                                  style: TextStyle(color: Colors.white, fontSize: 15.toFont),
                                                )),
                                              )),
                                          SizedBox(height: 10.toHeight),
                                          TextButton(
                                              onPressed: () async {
                                                if ((_emailController.text != '') || widget.isQR) {
                                                  loading = true;
                                                  stateSet(() {});
                                                  if (widget.isQR) {
                                                    await loginWithAtsign(widget.atsign, context);
                                                  } else {
                                                    await registerPersona(
                                                        _atsignController.text, _emailController.text, context);
                                                  }

                                                  loading = false;
                                                  stateSet(() {});
                                                }
                                              },
                                              child: Text(
                                                'Resend Code',
                                                style: TextStyle(color: ColorConstants.appColor),
                                              )),
                                          SizedBox(height: 10.toHeight),
                                          if (!widget.isQR)
                                            TextButton(
                                                onPressed: () {
                                                  otp = false;
                                                  wrongEmail = true;
                                                  oldEmail = _emailController.text;
                                                  stateSet(() {});
                                                },
                                                child: const Text(
                                                  'Wrong email?',
                                                  style: TextStyle(color: Colors.grey),
                                                ))
                                        ]),
                                  if (!pair) ...<Widget>[
                                    SizedBox(height: 15.toHeight),
                                    Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(ColorConstants.appColor)),
                                          onPressed: () async {
                                            pair = true;
                                            _emailController.text = '';
                                            stateSet(() {});
                                          },
                                          child: Center(
                                              child: Text(
                                            'Pair',
                                            style: TextStyle(color: Colors.white, fontSize: 15.toFont),
                                          )),
                                        )),
                                    Center(
                                        child: TextButton(
                                            onPressed: () {
                                              isfreeAtsign = false;
                                              _atsignController.text = '';
                                              stateSet(() {});
                                            },
                                            child: const Text(
                                              'Back',
                                              style: TextStyle(color: Colors.grey),
                                            )))
                                  ]
                                ]
                              ],
                            ),
                          ))
                      : _getMessage(widget.message, widget.isErrorDialog),
                  actions: widget.showClose
                      ? <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onClose!();
                            },
                            child: Text(
                              Strings.closeTitle,
                              style: TextStyle(color: ColorConstants.appColor, fontSize: 14.toFont),
                            ),
                          ),
                        ]
                      : null,
                ))),
      ]);
    });
  }

  Future<bool> _verifyCameraPermissions() async {
    PermissionStatus status = await Permission.camera.status;
    print('camera status => $status');
    if (status.isGranted) {
      return true;
    }
    return (await <Permission>[Permission.camera].request())[0] == PermissionStatus.granted;
  }

  Future<void> onScan(String data, List<Offset> offsets, BuildContext context) async {
    setState(() {
      loading = true;
    });
    await _controller!.stopCamera();
    print('SCANNED: => $data');
    List<String> values = data.split(':');
    await widget.onValidate!(values[0], values[1], true);

    // try again
    await _controller!.startCamera((String data, List<Offset> offsets) {
      onScan(data, offsets, context);
    });
  }

  Future<String?> getFreeAtsign(BuildContext context) async {
    dynamic data;
    String? atsign;
    dynamic response = await _freeAtsignService.getFreeAtsigns();
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
      atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String? errorMessage = data['message'];
      await showErrorDialog(context, errorMessage);
    }
    return atsign;
  }

  Future<bool> registerPersona(String atsign, String email, BuildContext context, {String? oldEmail}) async {
    dynamic data;
    bool status = false;
    // String atsign;
    dynamic response = await _freeAtsignService.registerPerson(atsign, email, oldEmail: oldEmail);
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
        await showlimitDialog(context);
      } else {
        await showErrorDialog(context, errorMessage);
      }
    }
    return status;
  }

  Future<String?> validatePerson(String atsign, String email, String? otp, BuildContext context,
      {bool isConfirmation = false}) async {
    dynamic data;
    String? cramSecret;
    List<String> atsigns = <String>[];
    // String atsign;

    dynamic response = await _freeAtsignService.validatePerson(atsign, email, otp, confirmation: isConfirmation);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
      print(data['data']);
      //check for the atsign list and display them.
      if (data['data'] != null && data['data'].length == 2 && data['status'] != 'error') {
        dynamic responseData = data['data'];
        atsigns.addAll(List<String>.from(responseData['atsigns']));

        if (responseData['newAtsign'] == null) {
          Navigator.pop(context);

          widget.onLimitExceed!(atsigns, responseData['message']);
          return limitExceeded;
        }
        //displays list of atsign along with newAtsign
        else {
          await Navigator.push(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (_) => AtsignListScreen(
                        atsigns: atsigns,
                        newAtsign: responseData['newAtsign'],
                      ))).then((dynamic value) async {
            if (value == responseData['newAtsign']) {
              cramSecret = await validatePerson(value, email, otp, context, isConfirmation: true);
              return cramSecret;
            } else {
              if (value != null) {
                Navigator.pop(context);
                widget.onSubmit!(value);
              }
              return null;
            }
          });
        }
      } else if (data['status'] != 'error') {
        cramSecret = data['cramkey'];
      } else {
        String? errorMessage = data['message'];
        await showErrorDialog(context, errorMessage);
      }
      // atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String? errorMessage = data['message'];
      await showErrorDialog(context, errorMessage);
    }
    return cramSecret;
  }

  Future<String> validatewithAtsign(String atsign, String otp, BuildContext context,
      {bool isConfirmation = false}) async {
    dynamic data;
    String? cramSecret;

    dynamic response = await _freeAtsignService.verificationWithAtsign(atsign, otp);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
      print(data['data']);
      //check for the atsign list and display them.
      if (data['message'] == 'Verified') {
        cramSecret = data['cramkey'];
      } else {
        String errorMessage = data['message'];
        await showErrorDialog(context, errorMessage);
      }
      // atsign = data['data']['atsign'];
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      await showErrorDialog(context, errorMessage);
    }
    return cramSecret ?? '';
  }

  Future<bool> loginWithAtsign(String atsign, BuildContext context) async {
    dynamic data;
    bool status = false;

    dynamic response = await _freeAtsignService.loginWithAtsign(atsign);
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
      await showErrorDialog(context, errorMessage);
    }
    return status;
  }

  ///Returns corresponding errorMessage for [error].
  String? _getErrorMessage(dynamic error) {
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
        if (error == ResponseStatus.AUTH_FAILED) {
          if (_onboardingService.isPkam!) {
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

  Future<CustomDialog?> showErrorDialog(BuildContext context, String? errorMessage) async {
    return showDialog<CustomDialog>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            context: context,
            isErrorDialog: true,
            showClose: true,
            message: errorMessage,
            onClose: () {},
          );
        });
  }

  Future<AlertDialog?> showlimitDialog(BuildContext context) async {
    return showDialog<AlertDialog>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 16.toFont, letterSpacing: 0.5),
                    text: 'Oops! You already have the maximum number of free @signs. Please login to ',
                  ),
                  TextSpan(
                      text: 'https://my.atsign.com',
                      style: TextStyle(
                          fontSize: 16.toFont,
                          color: ColorConstants.appColor,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          String url = 'https://my.atsign.com';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        }),
                  TextSpan(
                    text: '  to select one of your existing @signs.',
                    style: TextStyle(color: Colors.black, fontSize: 16.toFont, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
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

  Widget? _getMessage(dynamic message, bool isErrorDialog) {
    String? highLightText = message == ResponseStatus.TIME_OUT ? AppConstants.contactAddress : AppConstants.website;
    if (message == null) {
      return null;
    }
    if (isErrorDialog) {
      message = _getErrorMessage(widget.message);
    }
    if (!message.contains(highLightText)) {
      return Text(message, style: CustomTextStyles.fontR16primary);
    }
    int startIndex = message.indexOf(highLightText);
    String text1 = message.substring(0, startIndex), text3 = message.substring(startIndex + highLightText!.length);

    return RichText(
      text: TextSpan(
        style: CustomTextStyles.fontR16primary,
        children: <InlineSpan>[
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
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  Uri params = Uri(
                    scheme: Strings.mailUrlScheme,
                    path: AppConstants.contactAddress,
                    query: Strings.mailUrlquery, //add subject and body here
                  );
                  String url = highLightText == AppConstants.contactAddress ? params.toString() : highLightText;
                  String errorMessage = 'Cannot launch $url';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    await showDialog(
                        barrierDismissible: false,
                        context: widget.context!,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            context: context,
                            isErrorDialog: true,
                            showClose: true,
                            message: errorMessage,
                            onClose: () {},
                          );
                        });
                  }
                }),
          TextSpan(
            text: text3,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
