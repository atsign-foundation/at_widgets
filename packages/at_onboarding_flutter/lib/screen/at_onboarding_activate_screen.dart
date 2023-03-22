import 'dart:convert';
import 'dart:io';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_result.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_backup_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_otp_screen.dart';
import 'package:at_onboarding_flutter/screen/at_onboarding_reference_screen.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_config.dart';
import 'package:at_onboarding_flutter/services/free_atsign_service.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_error_util.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:at_server_status/at_server_status.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AtOnboardingActivateScreen extends StatefulWidget {
  ///will hide webpage references.
  final bool hideReferences;
  final String? atSign;
  final AtOnboardingConfig config;

  const AtOnboardingActivateScreen({
    Key? key,
    required this.hideReferences,
    this.atSign,
    required this.config,
  }) : super(key: key);

  @override
  State<AtOnboardingActivateScreen> createState() =>
      _AtOnboardingActivateScreenState();
}

class _AtOnboardingActivateScreenState
    extends State<AtOnboardingActivateScreen> {
  final FreeAtsignService _freeAtsignService = FreeAtsignService();

  bool isVerifing = false;
  bool isResendingCode = false;
  ServerStatus? atSignStatus;
  String limitExceeded = 'limitExceeded';

  final OnboardingService _onboardingService = OnboardingService.getInstance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loginWithAtsignAfterReset(context);
    });
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
      absorbing: isVerifing,
      child: Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              AtOnboardingStrings.onboardingTitle,
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
              padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
              margin: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  AtSyncIndicator(),
                  SizedBox(height: 10),
                  Text('Please wait while fetching atSign status'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //It will validate the person with atsign, email and the OTP.
  //If the validation is successful, it will return a cram secret for the user to login
  void loginWithAtsignAfterReset(BuildContext context) async {
    String? atsign = widget.atSign ?? _onboardingService.currentAtsign;
    atsign ??= await _onboardingService.getAtSign();
    if (atsign != null) {
      atsign = atsign.split('@').last;
    }

    // check if atSign already activated
    AtSignStatus? atsignStatus =
        await OnboardingService.getInstance().checkAtsignStatus(atsign: atsign);
    if (atsignStatus == AtSignStatus.activated) {
      bool isPaired = await _onboardingService.isExistingAtsign(atsign);
      await showErrorDialog(isPaired
          ? 'This atSign has already been activated and paired with this device'
          : 'This atSign has already been activated. Please upload your atkeys to pair it with this device');
      return;
    }

    dynamic data;

    dynamic response = await _freeAtsignService
        .loginWithAtsign(atsign ?? (widget.atSign ?? ''));
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);

      // ignore: use_build_context_synchronously
      final result = await AtOnboardingOTPScreen.push(
        context: context,
        atSign: atsign ?? (widget.atSign ?? ''),
        hideReferences: false,
        config: widget.config,
      );

      if (result != null) {
        String? secret = result.secret?.split(':').last ?? '';
        _processSharedSecret(atsign: result.atSign, secret: secret);
      } else {
        if (!mounted) return;
        Navigator.pop(context, AtOnboardingResult.cancelled());
      }
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      await showErrorDialog(errorMessage);
    }
  }

  Future<void> showErrorDialog(String? errorMessage) async {
    return AtOnboardingDialog.showError(
      context: context,
      title: "Notice",
      message: errorMessage ?? '',
      onCancel: () {
        Navigator.of(context).pop();
      },
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

  Future<dynamic> _processSharedSecret({
    required String atsign,
    required String secret,
  }) async {
    dynamic authResponse;
    try {
      atsign = atsign.startsWith('@') ? atsign : '@$atsign';

      bool isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist) {
        await _showAlertDialog(
            AtOnboardingErrorToString().pairedAtsign(atsign));
        return;
      }

      //Delay for waiting for ServerStatus change to teapot when activating an atsign
      await Future.delayed(const Duration(seconds: 10));

      _onboardingService.setAtClientPreference =
          widget.config.atClientPreference;

      authResponse = await _onboardingService.authenticate(atsign,
          cramSecret: secret, status: OnboardingStatus.ACTIVATE);

      int round = 1;
      atSignStatus = await _onboardingService.checkAtSignServerStatus(atsign);
      while (atSignStatus != ServerStatus.activated) {
        if (round > 10) {
          break;
        }

        await Future.delayed(const Duration(seconds: 3));
        round++;
        atSignStatus = await _onboardingService.checkAtSignServerStatus(atsign);
        debugPrint("currentAtSignStatus: $atSignStatus");
      }

      if (authResponse == AtOnboardingResponseStatus.authSuccess) {
        if (atSignStatus == ServerStatus.teapot) {
          await _showAlertDialog(
            AtOnboardingStrings.atsignNull,
          );
          return;
        }

        await AtOnboardingBackupScreen.push(
          context: context,
          config: widget.config,
        );

        if (!mounted) return;
        Navigator.pop(context, AtOnboardingResult.success(atsign: atsign));
      } else if (authResponse == AtOnboardingResponseStatus.serverNotReached) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNotFound,
        );
      } else if (authResponse == AtOnboardingResponseStatus.authFailed) {
        await _showAlertDialog(
          AtOnboardingStrings.atsignNull,
        );
      } else {
        await showErrorDialog('Your session expired');
      }
    } catch (e) {
      if (e == AtOnboardingResponseStatus.authFailed) {
        await _showAlertDialog(e, title: 'Authentication Failed');
      } else if (e == AtOnboardingResponseStatus.serverNotReached) {
        await _showAlertDialog(e, title: 'Server not found');
      } else if (e == AtOnboardingResponseStatus.timeOut) {
        await _showAlertDialog(e, title: 'Your session expired');
      }
    }
    return authResponse;
  }

  Future<void> _showAlertDialog(dynamic errorMessage, {String? title}) async {
    String? messageString =
        AtOnboardingErrorToString().getErrorMessage(errorMessage);

    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.appColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.appColor,
          ),
    );

    return AtOnboardingDialog.showError(
      context: context,
      title: title,
      message: messageString,
      themeData: theme,
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }
}
