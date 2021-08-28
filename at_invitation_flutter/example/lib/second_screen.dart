import 'package:at_invitation_flutter/at_invitation_flutter.dart';
import 'package:flutter/material.dart';
import 'client_sdk_service.dart';
import 'constants.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String activeAtSign = '';
  GlobalKey<NavigatorState> scaffoldKey = GlobalKey();
  String chatWithAtSign = '';
  bool showOptions = false;

  // for goup chat
  String groupId = '';
  String member1 = '';
  String member2 = '';

  @override
  void initState() {
    initializeInvitationWidget();
    scaffoldKey = GlobalKey<NavigatorState>();
    _handleIncomingLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Second Screen')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Welcome $activeAtSign!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  Text('Use this button to invite any of your contacts to this app using their email or phone number'),
            ),
            SizedBox(
              height: 10.0,
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
              ),
              onPressed: () {
                shareAndInvite(context, 'welcome');
              },
              child: Text(
                'Share with a friend',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
              ),
              onPressed: () {
                _checkForInvite();
              },
              child: Text(
                'Check for invite',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initializeInvitationWidget() async {
    var currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign ?? '';
    });
    initializeInvitationService(
        navkey: scaffoldKey,
        atClientInstance: clientSdkService.atClientServiceInstance?.atClient,
        currentAtSign: activeAtSign,
        webPage: 'https://3cb8767f51fa.ngrok.io',
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  void _checkForInvite() async {
    String _url = "https://3cb8767f51fa.ngrok.io";
    await canLaunch(_url) ? await launch(_url, forceSafariVC: false) : throw 'Could not launch $_url';
  }

  void _handleIncomingLinks() {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    uriLinkStream.listen((Uri? uri) {
      print('got uri: $uri');
      if (!mounted) {
        print('not mounted');
      } else {
        if (uri != null) {
          var queryParameters = uri.queryParameters;
          print(queryParameters);
          fetchInviteData(context, queryParameters['key'] ?? '', queryParameters['atsign'] ?? '');
        }
      }
    }, onError: (Object err) {
      print('got err: $err');
    });
  }
}
