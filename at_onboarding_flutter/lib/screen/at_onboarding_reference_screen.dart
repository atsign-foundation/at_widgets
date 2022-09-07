import 'dart:io';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_sync_ui_flutter/at_sync_material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AtOnboardingReferenceScreen extends StatefulWidget {
  static push({
    required BuildContext context,
    required String? url,
    required String? title,
    required AtOnboardingConfig config,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtOnboardingReferenceScreen(
          url: url,
          title: title,
          config: config,
        ),
      ),
    );
  }

  final String? url;
  final String? title;
  final AtOnboardingConfig config;

  const AtOnboardingReferenceScreen({
    Key? key,
    this.url,
    this.title,
    required this.config,
  }) : super(key: key);

  @override
  State<AtOnboardingReferenceScreen> createState() =>
      _AtOnboardingReferenceScreenState();
}

class _AtOnboardingReferenceScreenState
    extends State<AtOnboardingReferenceScreen> {
  late bool isLoading;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };
  WebViewController? _myController;
  final UniqueKey _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.appColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.appColor,
          ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ?? 'FAQ',
            style: TextStyle(
              color: Platform.isIOS || Platform.isAndroid
                  ? Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white
                  : null,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            WebView(
              key: _key,
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              gestureRecognizers: gestureRecognizers,
              onWebViewCreated: (controller) {
                _myController = controller;
              },
              onPageFinished: (String value) {
                setState(() {
                  isLoading = false;
                });
              },
              backgroundColor: Colors.white,
            ),
            isLoading
                ? const Center(
                    child: AtSyncIndicator(),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
