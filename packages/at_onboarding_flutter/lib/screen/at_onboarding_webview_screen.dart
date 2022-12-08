import 'dart:io';

import 'package:at_backupkey_flutter/utils/color_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AtOnboardingWebviewScreen extends StatefulWidget {
  final String? url;
  final String? title;

  const AtOnboardingWebviewScreen({
    Key? key,
    this.url,
    this.title,
  }) : super(key: key);

  @override
  State<AtOnboardingWebviewScreen> createState() =>
      _AtOnboardingWebviewScreenState();
}

class _AtOnboardingWebviewScreenState extends State<AtOnboardingWebviewScreen> {
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? 'FAQ',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        elevation: 1.0,
        centerTitle: true,
        backgroundColor: ColorConstants.appColor,
      ),
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            gestureRecognizers: {
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer()..onUpdate = (_) {},
              )
            },
            onPageFinished: (String value) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                    ColorConstants.appColor,
                  )),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
