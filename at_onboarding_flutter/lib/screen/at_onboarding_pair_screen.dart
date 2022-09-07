import 'dart:convert';
import 'dart:io';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_otp_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reference_screen.dart';
import 'package:at_onboarding_flutter/services/free_atsign_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AtOnboardingPairScreen extends StatefulWidget {
  final String atSign;

  ///will hide webpage references.
  final bool hideReferences;

  final Function({
    required String atSign,
    required String secret,
  })? onGenerateSuccess;

  final AtOnboardingConfig config;

  const AtOnboardingPairScreen({
    Key? key,
    required this.atSign,
    required this.hideReferences,
    required this.onGenerateSuccess,
    required this.config,
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
    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.appColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.appColor,
          ),
    );

    return AbsorbPointer(
      absorbing: isParing,
      child: Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              AtOnboardingStrings.onboardingTitle,
              style: TextStyle(
                color: Platform.isIOS || Platform.isAndroid
                    ? Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white
                    : null,
              ),
            ),
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
                  color: theme.primaryColor.withOpacity(0.1),
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
                  const SizedBox(height: 5),
                  TextFormField(
                    enabled: true,
                    focusNode: _focusNode,
                    validator: (String? value) {
                      if (value == null || value == '') {
                        return 'atSign cannot be empty';
                      }
                      return null;
                    },
                    controller: _emailController,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(80),
                      // This inputFormatter function will convert all the input to lowercase.
                      TextInputFormatter.withFunction(
                          (TextEditingValue oldValue,
                              TextEditingValue newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toLowerCase(),
                          selection: newValue.selection,
                        );
                      })
                    ],
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      fillColor: Colors.blueAccent,
                      errorStyle: const TextStyle(fontSize: 12),
                      prefixStyle:
                          TextStyle(color: theme.primaryColor, fontSize: 15),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[500]!,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AtOnboardingDimens.paddingSmall),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AtOnboardingStrings.emailNote,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AtOnboardingDimens.fontNormal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AtOnboardingPrimaryButton(
                    height: 48,
                    borderRadius: 24,
                    isLoading: isParing,
                    onPressed: _onSendCodePressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send Code',
                          style: TextStyle(
                            fontSize: AtOnboardingDimens.fontLarge,
                            color: Platform.isIOS || Platform.isAndroid
                                ? Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.black
                                : null,
                          ),
                        ),
                        const Icon(Icons.arrow_right_alt_rounded)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReferenceWebview() {
    if (Platform.isAndroid || Platform.isIOS) {
      AtOnboardingReferenceScreen.push(
        context: context,
        title: AtOnboardingStrings.faqTitle,
        url: AtOnboardingStrings.faqUrl,
        config: widget.config,
      );
    } else {
      launchUrl(
        Uri.parse(
          AtOnboardingStrings.faqUrl,
        ),
      );
    }
  }

  void _onSendCodePressed() async {
    _focusNode.unfocus();
    if (_emailController.text != '') {
      isParing = true;
      setState(() {});
      bool status = false;
      status =
          await registerPersona(widget.atSign, _emailController.text, context);
      isParing = false;
      setState(() {});
      if (status) {
        _showOTPScreen();
      } else {
        AtOnboardingDialog.showError(
          context: context,
          title: "Failed to send OTP!",
          message: "Please try again.",
          onCancel: () {
            Navigator.pop(context);
          },
        );
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
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      if (errorMessage.contains('Invalid Email')) {
        oldEmail = email;
      }
      if (errorMessage.contains('maximum number of free atSigns')) {
        await showlimitDialog();
      } else {
        AtOnboardingDialog.showError(context: context, message: errorMessage);
      }
    }
    return status;
  }

  Future<AlertDialog?> showlimitDialog() async {
    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.appColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.appColor,
          ),
    );

    return showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                const TextSpan(
                  style: TextStyle(
                      color: Colors.black, fontSize: 16, letterSpacing: 0.5),
                  text:
                      'Oops! You already have the maximum number of free atSigns. Please login to ',
                ),
                TextSpan(
                    text: 'https://my.atsign.com',
                    style: TextStyle(
                        fontSize: 16,
                        color: theme.primaryColor,
                        letterSpacing: 0.5,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        String url = 'https://my.atsign.com';
                        if (!widget.hideReferences &&
                            await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      }),
                const TextSpan(
                  text: '  to select one of your existing atSigns.',
                  style: TextStyle(
                      color: Colors.black, fontSize: 16, letterSpacing: 0.5),
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
                style: TextStyle(color: theme.primaryColor),
              ),
            )
          ],
        );
      },
    );
  }

  void _showOTPScreen() async {
    final String atSign = widget.atSign;
    final String email = _emailController.text;
    final result = await AtOnboardingOTPScreen.push(
      context: context,
      atSign: atSign,
      email: email,
      hideReferences: false,
      config: widget.config,
    );
    if (result != null && result.secret != null) {
      if (!mounted) return;
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
        context: context,
        atSign: result.atSign,
        hideReferences: false,
        config: widget.config,
      );
      if (result2 != null) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onGenerateSuccess
            ?.call(atSign: result2.atSign, secret: result2.secret ?? '');
      } else {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
  }
}
