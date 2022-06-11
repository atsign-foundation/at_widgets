import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_sync_ui_flutter/at_sync_ui.dart';
import 'package:flutter/material.dart';

class SwitchAtsignService {
  static final SwitchAtsignService _singleton = SwitchAtsignService._internal();
  SwitchAtsignService._internal();

  factory SwitchAtsignService() {
    return _singleton;
  }

  Future<void> switchAtsign({
    required AtClientPreference atClientPreference,
    required Function onboardSuccessCallback,
  }) async {
    var _atSignList = await KeychainUtil.getAtsignList();
    if (_atSignList == null) return;

    if (_atSignList.length > 1) {
      var _currentAtsign =
          AtClientManager.getInstance().atClient.getCurrentAtSign();
      var _switchToAtsign =
          (_atSignList[0] != _currentAtsign) ? _atSignList[0] : _atSignList[1];

      var _context = AtSyncUI.instance.appNavigatorKey!.currentContext!;
      Onboarding(
        atsign: _switchToAtsign,
        context: _context,
        atClientPreference: atClientPreference,
        domain: atClientPreference.rootDomain,
        rootEnvironment: RootEnvironment.Production,
        appColor: const Color.fromARGB(255, 240, 94, 62),
        onboard: (value, atsign) async {
          await onboardSuccessCallback(value, atsign!, atClientPreference);
        },
        onError: (error) {
          ScaffoldMessenger.of(_context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xffF86060),
              content: Text('Onboarding failed.'),
            ),
          );
        },
        appAPIKey: '',
      );
    }
  }
}
