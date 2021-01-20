import 'package:at_onboarding_flutter/screens/pair_atsign.dart';
import 'package:at_onboarding_flutter/services/custom_nav.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

class OnboardingWidget extends StatefulWidget {
  ///The atsign to onboard if not null else takes the atsign from keychain.
  final String atsign;

  ///The namespace that the app's data get appended with.
  /// ```
  /// Example : persona, buzz, mosphere
  /// ```
  final String namespace;

  ///Default the plugin connects to [root.atsign.org] to perform onboarding.
  final String domain;

  ///The color of the screen to match with the app's aesthetics. default it is [black].
  final Color appColor;

  ///if logo is not null then displays the widget in the left side of appbar else displays nothing.
  final Widget logo;

  ///Function returns atClientServiceMap on successful onboarding.
  ///Function returns error when failed in onboarding the existing or given atsign if [nextScreen] is null;
  final Function onboard;

  ///after successful onboarding will gets redirected to this screen if it is not null.
  final Widget nextScreen;

  OnboardingWidget(
      {Key key,
      this.atsign,
      this.onboard,
      this.nextScreen,
      this.namespace,
      this.appColor,
      this.logo,
      this.domain});
  @override
  _OnboardingWidgetState createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  var _onboardingService = OnboardingService.getInstance();
  Future<bool> _future;
  @override
  void initState() {
    // print("received atsign is ${widget.atsign}");
    AppConstants.rootDomain = widget.domain;
    _onboardingService.setLogo = widget.logo;
    _onboardingService.setNextScreen = widget.nextScreen;
    _onboardingService.onboardFunc = widget.onboard;
    ColorConstants.setAppColor = widget.appColor;
    _onboardingService.namespace = widget.namespace;
    _future = _onboardingService.onboard();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return FutureBuilder<bool>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (widget.nextScreen == null) {
              CustomNav().pop(context);
              return Container();
            }
            CustomNav().push(widget.nextScreen, context);
            // return widget.nextScreen;
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   Navigator.pushReplacement(context,
            //       MaterialPageRoute(builder: (context) => widget.nextScreen));
            // });
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => widget.nextScreen));
          } else if (snapshot.hasError) {
            if (widget.nextScreen == null) {
              widget.onboard(snapshot.error);
              CustomNav().pop(context);
              return Container();
            }
            if (snapshot.error == OnboardingStatus.ACTIVATE) {
              return PairAtsignWidget(
                onboardStatus: OnboardingStatus.ACTIVATE,
              );
            } else if (snapshot.error == OnboardingStatus.ATSIGN_NOT_FOUND) {
              return PairAtsignWidget(
                getAtSign: true,
              );
            }
            return PairAtsignWidget();
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
