import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_error_util.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_dialog.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:flutter/material.dart';

import '../at_onboarding.dart';
import 'at_onboarding_backup_screen.dart';
import 'at_onboarding_otp_screen.dart';
import '../services/free_atsign_service.dart';
import 'at_onboarding_reference_screen.dart';

class AtOnboardingActivateAccountScreen extends StatefulWidget {
  ///will hide webpage references.
  final bool hideReferences;
  final String? atSign;

  const AtOnboardingActivateAccountScreen({
    Key? key,
    required this.hideReferences,
    this.atSign,
  }) : super(key: key);

  @override
  State<AtOnboardingActivateAccountScreen> createState() =>
      _AtOnboardingActivateAccountScreenState();
}

class _AtOnboardingActivateAccountScreenState
    extends State<AtOnboardingActivateAccountScreen> {
  final FreeAtsignService _freeAtsignService = FreeAtsignService();

  bool isVerifing = false;
  bool isResendingCode = false;

  String limitExceeded = 'limitExceeded';

  final OnboardingService _onboardingService = OnboardingService.getInstance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      loginWithAtsignAfterReset(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isVerifing,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setting up your account'),
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
                Text('Please wait while fetching @sign status'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //It will validate the person with atsign, email and the OTP.
  //If the validation is successful, it will return a cram secret for the user to login
  void loginWithAtsignAfterReset(BuildContext context) async {
    String? atsign = _onboardingService.currentAtsign;
    atsign ??= await _onboardingService.getAtSign();
    if (atsign != null) {
      atsign = atsign.split('@').last;
    }
    dynamic data;

    dynamic response = await _freeAtsignService
        .loginWithAtsign(atsign ?? (widget.atSign ?? ''));
    if (response.statusCode == 200) {
      data = response.body;
      data = jsonDecode(data);
    } else {
      data = response.body;
      data = jsonDecode(data);
      String errorMessage = data['message'];
      await showErrorDialog(context, errorMessage);
    }
    final result = await AtOnboardingOTPScreen.push(
        context: context, atSign: atsign ?? (widget.atSign ?? ''), hideReferences: false);
    if (result != null) {
      String? secret = result.secret?.split(':')?.last ?? '';
      _processSharedSecret(atsign: result.atSign, secret: secret);
    } else {
      Navigator.pop(context, AtOnboardingResult.cancel);
    }
  }

  Future<void> showErrorDialog(
      BuildContext context, String? errorMessage) async {
    return AtOnboardingDialog.showError(
        context: context, message: errorMessage ?? '');
  }

  void _showReferenceWebview() {
    AtOnboardingReferenceScreen.push(
      context: context,
      title: AtOnboardingStrings.faqTitle,
      url: AtOnboardingStrings.faqUrl,
    );
  }

  Future<dynamic> _processSharedSecret(
      {required String atsign, required String secret}) async {
    dynamic authResponse;
    try {
      bool isExist = await _onboardingService.isExistingAtsign(atsign);
      if (isExist) {
        await _showAlertDialog(AtOnboardingErrorToString().pairedAtsign(atsign));
        return;
      }
      authResponse = await _onboardingService.authenticate(atsign,
          cramSecret: secret, status: OnboardingStatus.ACTIVATE);
      if (authResponse == AtOnboardingResponseStatus.authSuccess) {
        await AtOnboardingBackupScreen.push(context: context);
        Navigator.pop(context, AtOnboardingResult.success);
      } else {
        //Todo:
      }
    } catch (e) {
      if (e == AtOnboardingResponseStatus.authFailed) {
        await _showAlertDialog(e, title: 'Auth Failed');
      } else if (e == AtOnboardingResponseStatus.serverNotReached) {
        await _processSharedSecret(atsign: atsign, secret: secret);
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
      context: context,
      title: title,
      message: messageString,
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }
}
