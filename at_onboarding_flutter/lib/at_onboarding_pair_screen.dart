import 'dart:convert';

import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'at_onboarding.dart';
import 'at_onboarding_otp_screen.dart';
import 'screens/web_view_screen.dart';
import 'services/free_atsign_service.dart';
import 'services/onboarding_service.dart';
import 'widgets/at_onboarding_dialog.dart';
import 'widgets/custom_dialog.dart';

class AtOnboardingPairScreen extends StatefulWidget {
  final String atSign;

  ///will hide webpage references.
  final bool hideReferences;

  final Function({required String atSign, required String secret})?
      onGenerateSuccess;

  const AtOnboardingPairScreen({
    Key? key,
    required this.atSign,
    required this.hideReferences,
    required this.onGenerateSuccess,
  }) : super(key: key);

  @override
  State<AtOnboardingPairScreen> createState() => _AtOnboardingPairScreenState();
}

class _AtOnboardingPairScreenState extends State<AtOnboardingPairScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FreeAtsignService _freeAtsignService = FreeAtsignService();

  bool isParing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isParing,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setting up your account'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _showReferenceWebview,
              icon: const Icon(Icons.help),
            ),
          ],
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AtOnboardingDimens.borderRadius)),
            padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
            margin: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your email',
                  style: TextStyle(
                    fontSize: AtOnboardingDimens.fontLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5.toHeight,
                ),
                TextFormField(
                  enabled: true,
                  focusNode: _focusNode,
                  validator: (String? value) {
                    if (value == null || value == '') {
                      return '@sign cannot be empty';
                    }
                    return null;
                  },
                  controller: _emailController,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(80),
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
                    prefixStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 15.toFont),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorConstants.appColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: AtOnboardingDimens.paddingSmall.toWidth),
                  ),
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                const Text(
                  Strings.emailNote,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AtOnboardingDimens.fontNormal,
                  ),
                ),
                SizedBox(
                  height: 20.toHeight,
                ),
                AtOnboardingPrimaryButton(
                  height: 48,
                  borderRadius: 24,
                  isLoading: isParing,
                  onPressed: _onSendCodePressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Send Code',
                        style:
                            TextStyle(fontSize: AtOnboardingDimens.fontLarge),
                      ),
                      Icon(Icons.arrow_right_alt_rounded)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // actions: <Widget>[
        //   AtOnboardingSecondaryButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     child: const Text(
        //       Strings.cancelButton,
        //       style: TextStyle(
        //         fontSize: AtOnboardingDimens.fontNormal,
        //       ),
        //     ),
        //   ),
        // ],
      ),
    );
  }

  // Future<CustomDialog?> showErrorDialog(
  //     BuildContext context, String? errorMessage) async {
  //   return showDialog<CustomDialog>(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return CustomDialog(
  //           context: context,
  //           isErrorDialog: true,
  //           showClose: true,
  //           message: errorMessage,
  //           onClose: () {},
  //         );
  //       });
  // }

  void _showReferenceWebview() {
    Navigator.push(
        context,
        MaterialPageRoute<Widget>(
            builder: (BuildContext context) => const WebViewScreen(
                  title: Strings.faqTitle,
                  url: Strings.faqUrl,
                )));
  }

  void _onSendCodePressed() async {
    _focusNode.unfocus();
    if (_emailController.text != '') {
      isParing = true;
      setState(() {});
      bool status = false;
      // if (!wrongEmail) {
      status =
          await registerPersona(widget.atSign, _emailController.text, context);
      // } else {
      //   status = await registerPersona(
      //       widget.atSign, _emailController.text, context,
      //       oldEmail: oldEmail);
      // }
      isParing = false;
      setState(() {});
      if (status) {
        _showOTPScreen();
      } else {
        //Todo:
      }
    }
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
        // await showErrorDialog(context, errorMessage);
        AtOnboardingDialog.showError(context: context, message: errorMessage);
      }
    }
    return status;
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          String url = 'https://my.atsign.com';
                          if (!widget.hideReferences && await canLaunch(url)) {
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

  void _showOTPScreen() async {
    final String atSign = widget.atSign;
    final String email = _emailController.text;
    final result = await AtOnboardingOTPScreen.push(
      context: context,
      atSign: atSign,
      email: email,
      hideReferences: false,
    );
    if (result != null && result.secret != null) {
      Navigator.pop(context);
      widget.onGenerateSuccess
          ?.call(atSign: result.atSign, secret: result.secret ?? '');
    } else if (result != null) {
      dynamic data;
      //User choose a difference atsign to onboard
      dynamic response =
          await _freeAtsignService.loginWithAtsign(result.atSign);
      if (response.statusCode == 200) {
        data = response.body;
        data = jsonDecode(data);
      } else {
        data = response.body;
        data = jsonDecode(data);
        String errorMessage = data['message'];
        AtOnboardingDialog.showError(context: context, message: errorMessage);
      }
      final result2 = await AtOnboardingOTPScreen.push(
          context: context, atSign: result.atSign, hideReferences: false);
      if (result2 != null) {
        Navigator.pop(context);
        widget.onGenerateSuccess
            ?.call(atSign: result2.atSign, secret: result2.secret ?? '');
      } else {
        Navigator.pop(context, AtOnboardingResult.cancel);
      }
    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => AtOnboardingOTPScreen(
    //       atSign: atSign,
    //       hideReferences: false,
    //       email: email,
    //       onGenerateSuccess: (
    //           {required String atSign, required String secret}) {
    //         Navigator.pop(context);
    //         widget.onGenerateSuccess?.call(atSign: atSign, secret: secret);
    //       },
    //     ),
    //   ),
    // );
  }

  Future<void> _onAtSignSubmit(String atsign) async {
    bool? isExist = await OnboardingService.getInstance()
        .isExistingAtsign(atsign)
        .catchError((dynamic error) async {
      await _showAlertDialog(error);
    });
    //Todo:
  }

  Future<void> _showAlertDialog(dynamic errorMessage,
          {bool? isPkam,
          String? title,
          bool? getClose,
          Function? onClose}) async =>
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
                context: context,
                hideReferences: widget.hideReferences,
                hideQrScan: true,
                isErrorDialog: true,
                showClose: true,
                message: errorMessage,
                title: title,
                onClose: getClose == true ? onClose : () {});
          });
}
