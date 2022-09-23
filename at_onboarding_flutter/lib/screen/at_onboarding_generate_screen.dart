import 'dart:convert';
import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_backup_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_pair_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reference_screen.dart';
import 'package:at_onboarding_flutter/services/free_atsign_service.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_error_util.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AtOnboardingGenerateScreen extends StatefulWidget {
  final Function({
    required String atSign,
    required String secret,
  })? onGenerateSuccess;

  final AtOnboardingConfig config;

  const AtOnboardingGenerateScreen({
    Key? key,
    required this.config,
    this.onGenerateSuccess,
  }) : super(key: key);

  @override
  State<AtOnboardingGenerateScreen> createState() =>
      _AtOnboardingGenerateScreenState();
}

class _AtOnboardingGenerateScreenState
    extends State<AtOnboardingGenerateScreen> {
  final TextEditingController _atsignController = TextEditingController();
  final FreeAtsignService _freeAtsignService = FreeAtsignService();
  late AtSyncDialog _inprogressDialog;
  bool _isGenerating = false;

  final OnboardingService _onboardingService = OnboardingService.getInstance();
  final AtSignLogger _logger = AtSignLogger('At Onboarding');

  @override
  void initState() {
    _inprogressDialog = AtSyncDialog(context: context);
    super.initState();
    _getFreeAtsign();
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
      absorbing: _isGenerating,
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Generate a free atSign',
                    style: TextStyle(
                      fontSize: AtOnboardingDimens.fontLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    enabled: false,
                    validator: (String? value) {
                      if (value == null || value == '') {
                        return 'atSign cannot be empty';
                      }
                      return null;
                    },
                    controller: _atsignController,
                    decoration: InputDecoration(
                      hintText: AtOnboardingStrings.atsignHintText,
                      prefix: Text(
                        '@',
                        style: TextStyle(color: theme.primaryColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AtOnboardingDimens.paddingSmall),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Refresh until you see an atSign that you like, then press Pair",
                    style: TextStyle(
                      fontSize: AtOnboardingDimens.fontNormal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AtOnboardingSecondaryButton(
                    height: 48,
                    borderRadius: 24,
                    onPressed: () async {
                      _getFreeAtsign();
                    },
                    isLoading: _isGenerating,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Center(
                            child: Text(
                          'Refresh',
                          style:
                              TextStyle(fontSize: AtOnboardingDimens.fontLarge),
                        )),
                        Icon(
                          Icons.refresh,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AtOnboardingPrimaryButton(
                    height: 48,
                    borderRadius: 24,
                    onPressed: _showPairScreen,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pair',
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
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Text(
                      "Already have an atSign?",
                      style: TextStyle(
                        fontSize: AtOnboardingDimens.fontNormal,
                        fontWeight: FontWeight.w500,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: _showReferenceWebview,
                    child: Text(
                      'Learn more about atSigns',
                      style: TextStyle(
                        fontSize: AtOnboardingDimens.fontNormal,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        // color: theme.primaryColor,
                      ),
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

  void _getFreeAtsign() async {
    setState(() {
      _isGenerating = true;
    });
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
      await showErrorDialog(errorMessage);
    }
    setState(() {
      _isGenerating = false;
    });
    if ((atsign ?? '').isNotEmpty) {
      _atsignController.text = atsign ?? '';
    }
  }

  Future<void> showErrorDialog(dynamic errorMessage, {String? title}) async {
    String? messageString =
        AtOnboardingErrorToString().getErrorMessage(errorMessage);
    return AtOnboardingDialog.showError(
        context: context, message: messageString);
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

  void _showPairScreen() async {
    final String atSign = _atsignController.text;
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => AtOnboardingPairScreen(
          atSign: atSign,
          hideReferences: false,
          onGenerateSuccess: ({
            required String atSign,
            required String secret,
          }) {
            if (widget.onGenerateSuccess != null) {
              Navigator.pop(context);
              widget.onGenerateSuccess?.call(atSign: atSign, secret: secret);
            } else {
              _processSharedSecret(atSign: atSign, secret: secret);
            }
          },
          config: widget.config,
        ),
      ),
    );
  }

  Future<dynamic> _processSharedSecret({
    required String atSign,
    required String secret,
  }) async {
    dynamic authResponse;
    String cramSecret = secret.split(':').last;
    String verifiedAtSign = atSign.startsWith('@') ? atSign : '@$atSign';

    try {
      _inprogressDialog.show(message: 'Processing...');
      await Future.delayed(const Duration(milliseconds: 400));
      bool isExist = await _onboardingService.isExistingAtsign(verifiedAtSign);

      if (isExist) {
        _inprogressDialog.close();
        await _showAlertDialog(
            AtOnboardingErrorToString().pairedAtsign(verifiedAtSign));
        return;
      }

      await Future.delayed(const Duration(seconds: 10));

      authResponse = await _onboardingService.authenticate(
        verifiedAtSign,
        cramSecret: cramSecret,
        status: OnboardingStatus.ACTIVATE,
      );
      _inprogressDialog.close();
      if (authResponse == AtOnboardingResponseStatus.authSuccess) {
        await AtOnboardingBackupScreen.push(
          context: context,
          config: widget.config,
        );
        if (!mounted) return;
        Navigator.pop(
            context, AtOnboardingResult.success(atsign: verifiedAtSign));
      } else if (authResponse == AtOnboardingResponseStatus.serverNotReached) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNotFound,
        );
      } else if (authResponse == AtOnboardingResponseStatus.authFailed) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNull,
        );
      } else {
        await showErrorDialog('Response Time out');
      }
    } catch (e) {
      _inprogressDialog.close();
      if (e == AtOnboardingResponseStatus.authFailed) {
        _logger.severe('Error in authenticateWith cram secret');
        await _showAlertDialog(e, title: 'Auth Failed');
      } else if (e == AtOnboardingResponseStatus.serverNotReached) {
        await _processSharedSecret(
          atSign: atSign,
          secret: secret,
        );
      } else if (e == AtOnboardingResponseStatus.timeOut) {
        await _showAlertDialog(e, title: 'Response Time out');
      }
    }
    return authResponse;
  }

  Future<void> _showAlertDialog(dynamic errorMessage, {String? title}) async {
    String? messageString =
        AtOnboardingErrorToString().getErrorMessage(errorMessage);
    return AtOnboardingDialog.showError(
        context: context, title: title, message: messageString);
  }
}
