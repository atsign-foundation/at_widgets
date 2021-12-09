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

  ///hides the references to webpages if set to true
  final bool? hideReferences;

  ///hides the qr functionality if set to true
  final bool? hideQrScan;

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

  /// API authentication key for getting free atsigns
  final String? appAPIKey;

  /// Setting up [RootEnvironment] to **Staging** will use the staging environment for onboarding.
  ///
  ///```dart
  /// RootEnvironment.Staging
  ///```
  ///
  /// Setting up RootEnvironment to **Production** will use the production environment for onboarding.
  ///
  ///```dart
  /// RootEnvironment.Production
  ///```
  ///
  /// Setting up RootEnvironment to **Testing** will use the testing(docker) environment for onboarding.
  ///
  ///```dart
  /// RootEnvironment.Testing
  ///```
  ///
  /// **Note:**
  /// API Key is required when you set [rootEnvironment] to production.
  final RootEnvironment rootEnvironment;
  final AtSignLogger _logger = AtSignLogger('At Onboarding Flutter');

  Onboarding(
      {Key? key,
      required this.context,
      this.hideReferences,
      this.hideQrScan,
      this.atsign,
      required this.onboard,
      required this.onError,
      this.nextScreen,
      this.fistTimeAuthNextScreen,
      required this.atClientPreference,
      this.appColor,
      this.logo,
      this.domain,
      required this.rootEnvironment,
      this.appAPIKey}) {
    AppConstants.rootEnvironment = rootEnvironment;
    if (AppConstants.rootEnvironment == RootEnvironment.production &&
        appAPIKey == null) {
      throw ('App API Key is required for production environment');
    } else {
      _show();
    }
  }
  void _show() {
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => OnboardingWidget(
          atsign: atsign,
          onboard: onboard,
          onError: onError,
          hideReferences: hideReferences,
          hideQrScan: hideQrScan,
          nextScreen: nextScreen,
          fistTimeAuthNextScreen: fistTimeAuthNextScreen,
          atClientPreference: atClientPreference,
          appColor: appColor,
          logo: logo,
          domain: domain ?? AppConstants.rootEnvironment.domain,
          appAPIKey: appAPIKey ?? AppConstants.rootEnvironment.apikey!,
        ),
      );
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

  ///hides the references to webpages if set to true
  final bool? hideReferences;
  final bool? hideQrScan;

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

  /// API authentication key for getting free atsigns
  final String appAPIKey;

  const OnboardingWidget(
      {Key? key,
      this.atsign,
      this.hideReferences,
      this.hideQrScan,
      required this.onboard,
      required this.onError,
      this.nextScreen,
      this.fistTimeAuthNextScreen,
      required this.atClientPreference,
      this.appColor,
      this.logo,
      this.domain,
      required this.appAPIKey})
      : super(key: key);
  @override
  _OnboardingWidgetState createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  final OnboardingService _onboardingService = OnboardingService.getInstance();
  Future<bool>? _future;
  dynamic data;
  dynamic error;
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

    AppConstants.setApiKey(widget.appAPIKey);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (widget.atsign == '') {
      return PairAtsignWidget(
        getAtSign: true,
        hideReferences: widget.hideReferences ?? false,
        hideQrScan: widget.hideQrScan ?? false,
      );
    }

    return FutureBuilder<bool>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            CustomNav().pop(context);
            WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
              widget.onboard(_onboardingService.atClientServiceMap,
                  _onboardingService.currentAtsign);
            });
            if (widget.nextScreen != null) {
              CustomNav().push(widget.nextScreen, context);
            }
            return const Center();
          } else if (snapshot.hasError) {
            if (snapshot.error == OnboardingStatus.ATSIGN_NOT_FOUND) {
              return PairAtsignWidget(
                getAtSign: true,
                hideReferences: widget.hideReferences ?? false,
                hideQrScan: widget.hideQrScan ?? false,
              );
            } else if (snapshot.error == OnboardingStatus.ACTIVATE ||
                snapshot.error == OnboardingStatus.RESTORE) {
              return PairAtsignWidget(
                onboardStatus: snapshot.error as OnboardingStatus?,
                hideReferences: widget.hideReferences ?? false,
                hideQrScan: widget.hideQrScan ?? false,
              );
            } else {
              CustomNav().pop(context);
              Future<dynamic>.delayed((const Duration(milliseconds: 200)), () {
                widget.onError(snapshot.error);
              });
              return const Center();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
