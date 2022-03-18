import 'package:flutter/material.dart';

/// This class helps with responsiveness in various screen sizes
class AtOnboardingSizeConfig {
  AtOnboardingSizeConfig._();

  static final AtOnboardingSizeConfig _instance = AtOnboardingSizeConfig._();

  factory AtOnboardingSizeConfig() => _instance;
  late MediaQueryData _mediaQueryData;
  double? screenWidth;
  late double screenHeight;
  late double blockSizeHorizontal;
  late double blockSizeVertical;
  double? deviceTextFactor;

  late double _safeAreaHorizontal;
  late double _safeAreaVertical;
  late double safeBlockHorizontal;
  late double safeBlockVertical;

  double? profileDrawerWidth;
  late double refHeight;
  late double refWidth;

  bool isReady = false;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    refHeight = 812;
    refWidth = 375;

    deviceTextFactor = _mediaQueryData.textScaleFactor;

    if (screenHeight < 1200) {
      blockSizeHorizontal = screenWidth! / 100;
      blockSizeVertical = screenHeight / 100;

      _safeAreaHorizontal =
          _mediaQueryData.padding.left + _mediaQueryData.padding.right;
      _safeAreaVertical =
          _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
      safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal) / 100;
      safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    } else {
      blockSizeHorizontal = screenWidth! / 120;
      blockSizeVertical = screenHeight / 120;

      _safeAreaHorizontal =
          _mediaQueryData.padding.left + _mediaQueryData.padding.right;
      _safeAreaVertical =
          _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
      safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal) / 120;
      safeBlockVertical = (screenHeight - _safeAreaVertical) / 120;
    }

    isReady = true;
  }

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;
  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700 &&
      MediaQuery.of(context).size.width < 1200;
  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  double getWidthRatio(double val) {
    if (screenWidth! >= 1200) {
      return val;
    }

    double res = (val / refWidth) * 100;
    double temp = res * blockSizeHorizontal;

    return temp;
  }

  double getHeightRatio(double val) {
    if (screenWidth! >= 1200) {
      return val;
    }

    double res = (val / refHeight) * 100;
    double temp = res * blockSizeVertical;
    return temp;
  }

  double getFontRatio(double val) {
    if (screenWidth! >= 1200) {
      return val;
    }

    double res = (val / refWidth) * 100;
    double temp = 0.0;
    if (screenWidth! < screenHeight) {
      temp = res * safeBlockHorizontal;
    } else {
      temp = res * safeBlockVertical;
    }
    return temp;
  }
}

extension SizeUtils on num {
  double get toWidth => AtOnboardingSizeConfig().getWidthRatio(toDouble());

  double get toHeight => AtOnboardingSizeConfig().getHeightRatio(toDouble());

  double get toFont => AtOnboardingSizeConfig().getFontRatio(toDouble());
}
