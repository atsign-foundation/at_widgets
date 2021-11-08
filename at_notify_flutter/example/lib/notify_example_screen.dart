import 'package:at_notify_flutter/screens/notify_screen.dart';
import 'package:at_notify_flutter/services/notify_service.dart';
import 'package:at_notify_flutter/utils/init_notify_service.dart';
import 'package:at_notify_flutter/utils/notify_utils.dart';
import 'package:flutter/material.dart';

import 'client_sdk_service.dart';
import 'constants.dart';
import 'package:at_lookup/at_lookup.dart';

class NotifyExampleScreen extends StatefulWidget {
  @override
  _NotifyExampleScreenState createState() => _NotifyExampleScreenState();
}

class _NotifyExampleScreenState extends State<NotifyExampleScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign;

  TextEditingController atSignController = TextEditingController(text: '');
  TextEditingController messageController = TextEditingController(text: '');

  @override
  void initState() {
    getAtSignAndInitializeNotify();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Notify Example'),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome $activeAtSign',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextField(
                  controller: atSignController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: '@atSign'),
                  onChanged: (text) {},
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter Message'),
                  onChanged: (text) {},
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NotifyScreen(notifyService: NotifyService())),
                    );
                  },
                  child: Text(
                    'Get past notifications',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: _sendMessage,
                  child: Text(
                    'Notify Text',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _sendMessage() async {
    if (atSignController.text.isEmpty) {
      print('atSignController isEmpty');
      showSnackBar('Enter atsign');
      return;
    }

    if (messageController.text.isEmpty) {
      print('message isEmpty');
      showSnackBar('Enter message');
      return;
    }

    var _isValidAtsign = await checkAtsign();
    if (!_isValidAtsign) {
      showSnackBar('Atsign not valid');
      return;
    }

    var _res = await notifyText(
      context,
      activeAtSign,
      atSignController.text,
      messageController.text,
    );
    if (_res) {
      messageController.clear();
      showSnackBar('Message sent succesfully', color: Colors.green);
    } else {
      showSnackBar('Something went wrong');
    }
  }

  Future<bool> checkAtsign() async {
    if (atSignController.text.isEmpty) {
      return false;
    } else if (!atSignController.text.contains('@')) {
      atSignController.text = '@' + atSignController.text;
    }
    var checkPresence = await AtLookupImpl.findSecondary(
        atSignController.text, MixedConstants.ROOT_DOMAIN, 64);
    return checkPresence != null;
  }

  void getAtSignAndInitializeNotify() async {
    var currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeNotifyService(
      clientSdkService.atClientServiceInstance!.atClientManager,
      activeAtSign!,
      clientSdkService.atClientPreference,
      rootDomain: MixedConstants.ROOT_DOMAIN,
    );
  }

  showSnackBar(String text, {Color color = Colors.red}) {
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
      backgroundColor: color,
      dismissDirection: DismissDirection.horizontal,
      content: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 0.1,
          fontWeight: FontWeight.normal,
        ),
      ),
    ));
  }
}
