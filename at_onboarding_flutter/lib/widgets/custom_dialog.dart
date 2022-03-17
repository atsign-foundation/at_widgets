import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/free_atsign_service.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:at_commons/at_commons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import '../at_onboarding_webview_screen.dart';

// ignore: must_be_immutable
class CustomDialog extends StatefulWidget {
  ///will display the dialog with the [title] and the error details if set to true else displays the [message]. By default it is set to true.
  final bool isErrorDialog;

  ///will hide webpage references.
  final bool hideReferences;

  ///will hide qr scanning
  final bool hideQrScan;

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

  const CustomDialog(
      {this.context,
      this.isErrorDialog = false,
      this.hideReferences = false,
      this.hideQrScan = false,
      this.message,
      this.title,
      this.isAtsignForm = false,
      this.showClose = false,
      this.atsign = '',
      this.isQR = false,
      this.onSubmit,
      this.onValidate,
      this.onLimitExceed,
      this.onClose,
      Key? key})
      : super(key: key);

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

  final AtSignLogger _logger = AtSignLogger('Onboarding Service Custom Dialog');
  @override
  Widget build(BuildContext context) {
    if (widget.isQR) {
      otp = true;
      pair = true;
      isfreeAtsign = true;
    }
    double _dialogWidth = double.maxFinite;
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      _dialogWidth = 400;
    }

    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) stateSet) {
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
                            widget.message == ResponseStatus.timeOut
                                ? Icon(Icons.access_time, size: 18.toFont)
                                : Icon(Icons.sentiment_dissatisfied,
                                    size: 18.toFont)
                          ],
                        )
                      : widget.isAtsignForm
                          ? isQrScanner
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.0.toFont),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Scan your QR!',
                                          style: TextStyle(
                                            color: ColorConstants.appColor,
                                            fontSize: 16.toFont,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(height: 20.toHeight),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              128 -
                                              2 * 4.0.toFont, //Dialog have insetPadding = 40, contentPadding = 24
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              128 -
                                              2 * 4.0.toFont, //Dialog have insetPadding = 40, contentPadding = 24
                                          child: QrReaderView(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                128 -
                                                2 * 4.0.toFont, //Dialog have insetPadding = 40, contentPadding = 24
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                128 -
                                                2 * 4.0.toFont, //Dialog have insetPadding = 40, contentPadding = 24
                                            callback: (QrReaderViewController
                                                controller) {
                                              _controller = controller;
                                              _controller!.startCamera(
                                                  (String data,
                                                      List<Offset> offsets) {
                                                onScan(data, offsets, context);
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20.toHeight),
                                        const SizedBox(
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        SizedBox(height: 20.toHeight),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height:
                                                SizeConfig().isTablet(context)
                                                    ? 50.toHeight
                                                    : null,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor: Theme.of(
                                                                  context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? MaterialStateProperty
                                                          .all(Colors.grey[800])
                                                      : MaterialStateProperty
                                                          .all(Colors.white)),
                                              // key: Key(''),
                                              onPressed: () {
                                                setState(() {
                                                  isQrScanner = false;
                                                });
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 15.toFont,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ))
                                      ]),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.0.toFont),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Setting up your account',
                                          style: TextStyle(
                                            color: ColorConstants.appColor,
                                            fontSize: 16.toFont,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(height: 15.toHeight),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                !isfreeAtsign
                                                    ? widget.isQR
                                                        ? 'Enter Verification code'
                                                        : Strings
                                                            .enterAtsignTitle
                                                    : !pair
                                                        ? 'Free @sign'
                                                        : !otp
                                                            ? 'Enter your email'
                                                            : 'Enter Verification Code',
                                                style: SizeConfig()
                                                        .isTablet(context)
                                                    ? Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? CustomTextStyles
                                                            .fontR12secondary
                                                        : CustomTextStyles
                                                            .fontR12primary
                                                    : Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? CustomTextStyles
                                                            .fontR14secondary
                                                        : CustomTextStyles
                                                            .fontR14primary,
                                              ),
                                            ),
                                            widget.hideReferences
                                                ? const SizedBox()
                                                : IconButton(
                                                    icon: Icon(
                                                      Icons.help,
                                                      color: ColorConstants
                                                          .appColor,
                                                      size: 18.toFont,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute<
                                                                  Widget>(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  const AtOnboardingWebviewScreen(
                                                                    title: Strings
                                                                        .faqTitle,
                                                                    url: Strings
                                                                        .faqUrl,
                                                                  )));
                                                    })
                                          ],
                                        ),
                                        otp
                                            ? Text(
                                                !widget.isQR
                                                    ? 'A verification code has been sent to ${_emailController.text}'
                                                    : 'A verification code has been sent to your registered email.',
                                                style: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? CustomTextStyles
                                                        .fontR14secondary
                                                    : CustomTextStyles
                                                        .fontR14primary,
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
                          child: SizedBox(
                            width: _dialogWidth,
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
                                            enabled: isfreeAtsign & !pair
                                                ? false
                                                : true,
                                            style:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? CustomTextStyles
                                                        .fontR14secondary
                                                    : CustomTextStyles
                                                        .fontR14primary,
                                            validator: (String? value) {
                                              if (value == null ||
                                                  value == '') {
                                                return !pair
                                                    ? '@sign cannot be empty'
                                                    : 'Email cannot be empty';
                                              }
                                              return null;
                                            },
                                            onChanged: (String value) {
                                              stateSet(() {});
                                            },
                                            controller: !pair
                                                ? _atsignController
                                                : _emailController,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              LengthLimitingTextInputFormatter(
                                                  80),
                                              !pair
                                                  ? FilteringTextInputFormatter
                                                      .allow(
                                                      RegExp(
                                                        '[a-zA-Z0-9_]|\u00a9|\u00af|[\u2155-\u2900]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]',
                                                      ),
                                                    )
                                                  : FilteringTextInputFormatter
                                                      .allow(
                                                      RegExp('[a-zA-Z0-9.@_]'),
                                                    ),
                                              // This inputFormatter function will convert all the input to lowercase.
                                              TextInputFormatter.withFunction(
                                                  (TextEditingValue oldValue,
                                                      TextEditingValue
                                                          newValue) {
                                                return newValue.copyWith(
                                                  text: newValue.text
                                                      .toLowerCase(),
                                                  selection: newValue.selection,
                                                );
                                              })
                                            ],
                                            textCapitalization:
                                                TextCapitalization.none,
                                            decoration: InputDecoration(
                                              fillColor: Colors.blueAccent,
                                              errorStyle: TextStyle(
                                                fontSize: 12.toFont,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              hintText: !pair
                                                  ? Strings.atsignHintText
                                                  : '',
                                              prefixText: !pair ? '@' : '',
                                              prefixStyle: TextStyle(
                                                color: ColorConstants.appColor,
                                                fontSize: 15.toFont,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      ColorConstants.appColor,
                                                ),
                                              ),
                                            ),
                                          )
                                        : PinCodeTextField(
                                            animationType: AnimationType.none,
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            appContext: context,
                                            length: 4,
                                            onChanged: (String value) {
                                              verificationCode = value;
                                            },
                                            textStyle:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? CustomTextStyles
                                                        .fontR16secondary
                                                    : CustomTextStyles
                                                        .fontR16primary,
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
                                            onCompleted: (String v) {
                                              verificationCode = v;
                                            },
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              UpperCaseInputFormatter(),
                                            ],
                                          )),
                                if (!isfreeAtsign &&
                                    !widget.isQR &&
                                    !isQrScanner) ...<Widget>[
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
                                          style: TextStyle(
                                            color: ColorConstants.appColor,
                                            fontSize: 12.toFont,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15.toWidth),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    ColorConstants.appColor)),
                                        key: const Key(Strings.submitButton),
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            Navigator.pop(context);
                                            //// resetting paired email
                                            BackendService.getInstance()
                                                .setEmail = null;
                                            BackendService.getInstance()
                                                .setOtp = null;

                                            widget.onSubmit!(_atsignController
                                                .text
                                                .toLowerCase());
                                          }
                                        },
                                        child: Text(
                                          Strings.submitButton,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.toFont,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.toHeight),
                                  Text(
                                    'Need an @sign?',
                                    style: Theme.of(context).brightness !=
                                            Brightness.dark
                                        ? CustomTextStyles.fontR12primary
                                        : CustomTextStyles.fontR12secondary,
                                  ),
                                  SizedBox(height: 5.toHeight),
                                  SizedBox(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width
                                          .toWidth,
                                      height: SizeConfig().isTablet(context)
                                          ? 50.toHeight
                                          : null,
                                      child: ElevatedButton(
                                        style: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.grey[800]))
                                            : ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white)),
                                        // key: Key(''),
                                        onPressed: () async {
                                          loading = true;
                                          stateSet(() {});
                                          freeAtsign =
                                              await getFreeAtsign(context);
                                          if (freeAtsign != null) {
                                            _atsignController.text =
                                                freeAtsign!;
                                            isfreeAtsign = true;
                                          }
                                          loading = false;
                                          stateSet(() {});
                                        },
                                        child: Text(
                                          'Generate Free @sign',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 15.toFont,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      )),
                                  SizedBox(height: 20.toHeight),
                                  widget.hideQrScan
                                      ? const SizedBox()
                                      : Text('Have a QR Code?',
                                          style: Theme.of(context).brightness !=
                                                  Brightness.dark
                                              ? CustomTextStyles.fontR12primary
                                              : CustomTextStyles
                                                  .fontR12secondary),
                                  widget.hideQrScan
                                      ? const SizedBox()
                                      : SizedBox(height: 5.toHeight),
                                  widget.hideQrScan
                                      ? const SizedBox()
                                      : (Platform.isAndroid || Platform.isIOS)
                                          ? SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .toWidth,
                                              height:
                                                  SizeConfig().isTablet(context)
                                                      ? 50.toHeight
                                                      : null,
                                              child: ElevatedButton(
                                                style: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .grey[800]))
                                                    : ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white)),
                                                // key: Key(''),
                                                onPressed: () async {
                                                  await _verifyCameraPermissions();
                                                  setState(() {
                                                    isQrScanner = true;
                                                  });
                                                },
                                                child: Text(
                                                  'Scan QR code',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 15.toFont,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ))
                                          : SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height:
                                                  SizeConfig().isTablet(context)
                                                      ? 50.toHeight
                                                      : null,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .grey[800])),
                                                // key: Key(''),
                                                onPressed: () async {
                                                  await _uploadQRFileForDesktop(
                                                      context,
                                                      widget.onValidate);
                                                },
                                                child: Text(
                                                  'Upload QR code',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.toFont,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              )),
                                ],
                                if (isfreeAtsign) ...<Widget>[
                                  SizedBox(height: 15.toHeight),
                                  !otp
                                      ? !pair
                                          ? SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height:
                                                  SizeConfig().isTablet(context)
                                                      ? 50.toHeight
                                                      : null,
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
                                                              context) ??
                                                          '';
                                                  loading = false;
                                                  stateSet(() {});
                                                },
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Center(
                                                          child: Text(
                                                        'Refresh',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.toFont,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      )),
                                                      const Icon(
                                                        Icons.refresh,
                                                        color: Colors.white,
                                                        size: 30,
                                                      )
                                                    ]),
                                              ))
                                          : Column(children: <Widget>[
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all(
                                                                (_emailController
                                                                            .text !=
                                                                        '')
                                                                    ? Colors.grey[
                                                                        800]
                                                                    : Colors.grey[
                                                                        400])),
                                                    // key: Key(''),
                                                    onPressed: () async {
                                                      if (_emailController
                                                              .text !=
                                                          '') {
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
                                                        fontSize: 15.toFont,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
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
                                                          color:
                                                              Colors.grey[700],
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      )))
                                            ])
                                      : Column(children: <Widget>[
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height:
                                                  SizeConfig().isTablet(context)
                                                      ? 50.toHeight
                                                      : null,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all(
                                                            (_emailController
                                                                            .text !=
                                                                        '' ||
                                                                    widget.isQR)
                                                                ? Colors
                                                                    .grey[800]
                                                                : Colors.grey[
                                                                    400])),
                                                onPressed: () async {
                                                  if ((_emailController.text !=
                                                          '') ||
                                                      widget.isQR) {
                                                    loading = true;
                                                    stateSet(() {});

                                                    String? result;
                                                    if (widget.isQR) {
                                                      result =
                                                          await validatewithAtsign(
                                                              widget.atsign,
                                                              verificationCode!,
                                                              context);
                                                    } else {
                                                      result =
                                                          await validatePerson(
                                                              _atsignController
                                                                  .text,
                                                              _emailController
                                                                  .text,
                                                              verificationCode,
                                                              context);
                                                    }

                                                    loading = false;
                                                    stateSet(() {});
                                                    if (result != null &&
                                                        result !=
                                                            limitExceeded) {
                                                      List<String> params =
                                                          result.split(':');
                                                      Navigator.pop(context);
                                                      widget.onValidate!(
                                                          params[0],
                                                          params[1],
                                                          false);
                                                    }
                                                  }
                                                },
                                                child: Center(
                                                    child: Text(
                                                  'Verify & Login',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.toFont,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                )),
                                              )),
                                          SizedBox(height: 10.toHeight),
                                          TextButton(
                                              onPressed: () async {
                                                if ((_emailController.text !=
                                                        '') ||
                                                    widget.isQR) {
                                                  loading = true;
                                                  stateSet(() {});
                                                  if (widget.isQR) {
                                                    await loginWithAtsign(
                                                        widget.atsign, context);
                                                  } else {
                                                    await registerPersona(
                                                        _atsignController.text,
                                                        _emailController.text,
                                                        context);
                                                  }

                                                  loading = false;
                                                  stateSet(() {});
                                                }
                                              },
                                              child: Text(
                                                'Resend Code',
                                                style: TextStyle(
                                                  color:
                                                      ColorConstants.appColor,
                                                  fontSize: 15.toFont,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              )),
                                          SizedBox(height: 10.toHeight),
                                          if (!widget.isQR)
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
                                                    color: Colors.grey,
                                                    fontSize: 15.toFont,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                )),
                                          if (widget.isQR)
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Back',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 15.toFont,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ))
                                        ]),
                                  if (!pair) ...<Widget>[
                                    SizedBox(height: 15.toHeight),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: SizeConfig().isTablet(context)
                                            ? 50.toHeight
                                            : null,
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
                                              fontSize: 15.toFont,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )),
                                        )),
                                    const SizedBox(height: 10),
                                    Center(
                                        child: TextButton(
                                            onPressed: () {
                                              isfreeAtsign = false;
                                              _atsignController.text = '';
                                              stateSet(() {});
                                            },
                                            child: Text(
                                              'Back',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.toFont,
                                                fontWeight: FontWeight.normal,
                                              ),
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
                              style: TextStyle(
                                color: ColorConstants.appColor,
                                fontSize: 14.toFont,
                                fontWeight: FontWeight.normal,
                              ),
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
    if (status.isGranted) {
      return true;
    }
    return (await <Permission>[Permission.camera].request())[0] ==
        PermissionStatus.granted;
  }

  Future<void> onScan(
      String data, List<Offset> offsets, BuildContext context) async {
    // setState(() {
    //   loading = true;
    // });
    try {
      //Relate: https://github.com/atsign-foundation/at_widgets/issues/353
      //If added [await] will make an error because [stopCamera] invoke a channel method which don't have a return and waiting forever.
      //It's an issue in flutter_qr_reader package and no need [await] keyword
      _controller!.stopCamera();
    } catch (e) {
      _logger.warning(e.toString());
    }
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

  Future<bool> registerPersona(
      String atsign, String email, BuildContext context,
      {String? oldEmail}) async {
    dynamic data;
    bool status = false;
    // String atsign;
    dynamic response = await _freeAtsignService.registerPerson(atsign, email,
        oldEmail: oldEmail);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
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

  Future<String?> validatePerson(
      String atsign, String email, String? otp, BuildContext context,
      {bool isConfirmation = false}) async {
    BackendService.getInstance().setEmail = email;
    BackendService.getInstance().setOtp = otp;

    dynamic data;
    String? cramSecret;
    List<String> atsigns = <String>[];
    // String atsign;

    dynamic response = await _freeAtsignService
        .validatePerson(atsign, email, otp, confirmation: isConfirmation);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
      //check for the atsign list and display them.
      if (data['data'] != null &&
          data['data'].length == 2 &&
          data['status'] != 'error') {
        dynamic responseData = data['data'];
        atsigns.addAll(List<String>.from(responseData['atsigns']));

        if (responseData['newAtsign'] == null) {
          Navigator.pop(context);

          widget.onLimitExceed!(atsigns, responseData['message']);
          return limitExceeded;
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

  Future<String> validatewithAtsign(
      String atsign, String otp, BuildContext context,
      {bool isConfirmation = false}) async {
    dynamic data;
    String? cramSecret;

    dynamic response =
        await _freeAtsignService.verificationWithAtsign(atsign, otp);
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
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

  Future<CustomDialog?> showErrorDialog(
      BuildContext context, String? errorMessage) async {
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
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.toFont,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.normal,
                    ),
                    text:
                        'Oops! You already have the maximum number of free @signs. Please login to ',
                  ),
                  TextSpan(
                      text: 'https://my.atsign.com',
                      style: TextStyle(
                        fontSize: 16.toFont,
                        color: ColorConstants.appColor,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.normal,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          String url = 'https://my.atsign.com';
                          if (!widget.hideReferences &&
                              await canLaunchUrl(Uri(path: url))) {
                            await launchUrl(Uri(path: url));
                          }
                        }),
                  TextSpan(
                    text: '  to select one of your existing @signs.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.toFont,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.normal,
                    ),
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
                    style: TextStyle(
                      color: ColorConstants.appColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ))
            ],
          );
        });
  }

  Widget? _getMessage(dynamic message, bool isErrorDialog) {
    String? highLightText = message == ResponseStatus.timeOut
        ? AppConstants.contactAddress
        : AppConstants.website;
    if (message == null) {
      return null;
    }
    if (isErrorDialog) {
      message = _getErrorMessage(widget.message);
    }
    if (!message!.contains(highLightText!)) {
      return Text(message, style: CustomTextStyles.fontR16primary);
    }
    int startIndex = message.indexOf(highLightText);
    String text1 = message.substring(0, startIndex),
        text3 = message.substring(startIndex + highLightText.length);

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
                  String url = highLightText == AppConstants.contactAddress
                      ? params.toString()
                      : highLightText;
                  String errorMessage = 'Cannot launch $url';
                  if (await canLaunchUrl(Uri(path: url))) {
                    if (!widget.hideReferences) await launchUrl(Uri(path: url));
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
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadQRFileForDesktop(
      BuildContext context, dynamic processAESKey) async {
    try {
      String? aesKey, atsign;
      setState(() {
        loading = true;
      });
      String? path = await _desktopKeyPicker();
      if (path == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      File selectedFile = File(path);

      int length = selectedFile.lengthSync();
      if (length < 10) {
        await showErrorDialog(context, 'Incorrect QR file');
        return;
      }

      img.Image image = img.decodePng(selectedFile.readAsBytesSync())!;

      LuminanceSource source = RGBLuminanceSource(image.width, image.height,
          image.getBytes(format: img.Format.abgr).buffer.asInt32List());
      BinaryBitmap bitmap = BinaryBitmap(HybridBinarizer(source));

      QRCodeReader reader = QRCodeReader();
      Result result = reader.decode(bitmap);
      List<String> params = result.text.replaceAll('"', '').split(':');
      atsign = params[0];
      aesKey = params[1];

      if (aesKey.isEmpty && atsign.isEmpty) {
        await showErrorDialog(context, 'Incorrect QR file');
        setState(() {
          loading = false;
        });
        return;
      }
      await processAESKey(atsign, aesKey, false);
      setState(() {
        loading = false;
      });
    } catch (error) {
      _logger.warning(error);
      setState(() {
        loading = false;
      });
      await showErrorDialog(context, 'Failed to process file');
    }
  }

  Future<String?> _desktopKeyPicker() async {
    try {
      // ignore: omit_local_variable_types
      XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        extensions: <String>['png'],
      );
      List<XFile> files =
          await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
      if (files.isEmpty) {
        return null;
      }
      XFile file = files[0];
      return file.path;
    } catch (e) {
      _logger.severe('Error in desktopImagePicker $e');
      return null;
    }
  }
}

class UpperCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
