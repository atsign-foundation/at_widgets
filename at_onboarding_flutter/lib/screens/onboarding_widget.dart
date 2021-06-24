import 'package:at_onboarding_flutter/screens/pair_atsign.dart';
import 'package:at_onboarding_flutter/services/custom_nav.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_utils/at_logger.dart';

class Onboarding {
  ///Required field as for navigation.
  final BuildContext context;

  ///Onboards the given [atsign] if not null.
  ///if [atsign] is null then takes the atsign from keychain.
  ///if[atsign] is empty then it directly jumps into authenticate without performing onboarding. (or)
  ///if [atsign] is empty then it just presents pairAtSign screen without onboarding the atsign. (or)
  ///Just provide an empty string for ignoring existing atsign in keychain or app's atsign.
  final String? atsign;

  ///The atClientPreference [required] to continue with the onboarding.
  final AtClientPreference atClientPreference;

  ///Default the plugin connects to [root.atsign.org] to perform onboarding.
  final String? domain;

  ///The color of the screen to match with the app's aesthetics. default it is [black].
  final Color? appColor;

  ///if logo is not null then displays the widget in the left side of appbar else displays nothing.
  final Widget? logo;

  ///Function returns atClientServiceMap on successful onboarding along with onboarded @sign.
  late Function(Map<String?, AtClientService>, String?) onboard;

  ///Function returns error when failed in onboarding the existing or given atsign if [nextScreen] is null;
  final Function(Object?) onError;

  ///after successful onboarding will gets redirected to this screen if it is not null.
  final Widget? nextScreen;

  ///after first time succesful onboarding it will get redirected to this screen if not null.
  final Widget? fistTimeAuthNextScreen;

  final AtSignLogger _logger = AtSignLogger('At Onboarding Flutter');

  Onboarding(
      {Key? key,
      required this.context,
      this.atsign,
      required this.onboard,
      required this.onError,
      this.nextScreen,
      this.fistTimeAuthNextScreen,
      required this.atClientPreference,
      this.appColor,
      this.logo,
      this.domain}) {
    _show();
  }
  void _show() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => OnboardingWidget(
              atsign: this.atsign,
              onboard: this.onboard,
              onError: this.onError,
              nextScreen: this.nextScreen,
              fistTimeAuthNextScreen: this.fistTimeAuthNextScreen,
              atClientPreference: this.atClientPreference,
              appColor: this.appColor,
              logo: this.logo,
              domain: this.domain));
    });

    _logger.info('Onboarding...!');
  }
}

class OnboardingWidget extends StatefulWidget {
  ///Onboards the given [atsign] if not null.
  ///if [atsign] is null then takes the atsign from keychain.
  ///if[atsign] is empty then it directly jumps into authenticate without performing onboarding. (or)
  ///if [atsign] is empty then it just presents pairAtSign screen without onboarding the atsign. (or)
  ///Just provide an empty string for ignoring existing atsign in keychain or app's atsign.
  final String? atsign;

  ///The atClientPreference [required] to continue with the onboarding.
  final AtClientPreference atClientPreference;

  ///Default the plugin connects to [root.atsign.org] to perform onboarding.
  final String? domain;

  ///The color of the screen to match with the app's aesthetics. default it is [black].
  final Color? appColor;

  ///if logo is not null then displays the widget in the left side of appbar else displays nothing.
  final Widget? logo;

  ///Function returns atClientServiceMap on successful onboarding along with onboarded @sign.
  final Function(Map<String?, AtClientService>, String?) onboard;

  ///Function returns error when failed in onboarding the existing or given atsign if [nextScreen] is null;
  final Function(Object?) onError;

  ///after successful onboarding will gets redirected to this screen if it is not null.
  final Widget? nextScreen;

  ///after first time succesful onboarding it will get redirected to this screen if not null
  ///else it redirects to nextScreen.
  final Widget? fistTimeAuthNextScreen;

  OnboardingWidget(
      {Key? key,
      this.atsign,
      required this.onboard,
      required this.onError,
      this.nextScreen,
      this.fistTimeAuthNextScreen,
      required this.atClientPreference,
      this.appColor,
      this.logo,
      this.domain});
  @override
  _OnboardingWidgetState createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  var _onboardingService = OnboardingService.getInstance();
  Future<bool>? _future;
  var data;
  var error;
  @override
  void initState() {
    AppConstants.rootDomain = widget.domain;
    _onboardingService.setLogo = widget.logo;
    _onboardingService.setNextScreen = widget.nextScreen;
    _onboardingService.fistTimeAuthScreen = widget.fistTimeAuthNextScreen;
    _onboardingService.onboardFunc = widget.onboard;
    ColorConstants.setAppColor = widget.appColor;
    _onboardingService.setAtClientPreference = widget.atClientPreference;
    _onboardingService.setAtsign = widget.atsign;
    if (widget.atsign != '') {
      _future = _onboardingService.onboard();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (widget.atsign == '') {
      return PairAtsignWidget(
        getAtSign: true,
      );
    }

    return FutureBuilder<bool>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            CustomNav().pop(context);
            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
              widget.onboard(_onboardingService.atClientServiceMap,
                  _onboardingService.currentAtsign);
            });
            if (widget.nextScreen != null) {
              CustomNav().push(widget.nextScreen, context);
            }
            return Center();
          } else if (snapshot.hasError) {
            if (snapshot.error == OnboardingStatus.ATSIGN_NOT_FOUND) {
              return PairAtsignWidget(
                getAtSign: true,
              );
            } else if (snapshot.error == OnboardingStatus.ACTIVATE ||
                snapshot.error == OnboardingStatus.RESTORE) {
              return PairAtsignWidget(
                onboardStatus: snapshot.error as OnboardingStatus?,
              );
            } else {
              CustomNav().pop(context);
              Future.delayed((Duration(milliseconds: 200)), () {
                widget.onError(snapshot.error);
              });
              return Center();
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
