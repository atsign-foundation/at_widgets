import 'dart:io';

import 'package:at_follows_flutter/utils/app_constants.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  WebViewScreen({
    required this.url,
    required this.title,
  });
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late bool isLoading;
  final AtSignLogger _logger = AtSignLogger('WebView Widget');

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
      appBar: CustomAppBar(
        showBackButton: true,
        title: widget.title,
        showTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest navReq) async {
              if (navReq.url.startsWith(AppConstants.appUrl)) {
                _logger.info('Navigation decision is taken by urlLauncher');
                await _launchURL(navReq.url);
                return NavigationDecision.prevent;
              }
              _logger.info('Navigation decision is taken by webView');
              return NavigationDecision.navigate;
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
                      valueColor: AlwaysStoppedAnimation<Color?>(
                    ColorConstants.activeColor,
                  )),
                )
              : const SizedBox()
        ],
      ),
    );
  }

 Future<void> _launchURL(String url) async {
    // url = Uri.encodeFull(url);
    if (await canLaunch(url)) {
      Navigator.pop(context);
      Navigator.pop(context);
      await launch(url);
    } else {
      _logger.severe('unable to launch $url');
    }
  }
}
