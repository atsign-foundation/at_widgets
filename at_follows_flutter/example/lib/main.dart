import 'package:at_follows_flutter/screens/connections.dart';
import 'package:at_follows_flutter_example/services/at_service.dart';
import 'package:at_follows_flutter_example/services/notification_service.dart';
import 'package:at_follows_flutter_example/utils/app_constants.dart';
import 'package:at_follows_flutter_example/utils/app_strings.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final _formKey = GlobalKey<FormState>();
  // final _atsignController = TextEditingController();
  AtService atService = AtService.getInstance();
  NotificationService _notificationService;
  bool _loading = false;
  // List<String> _atsignsList = [];
  String _atsign;
  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.setOnNotificationClick(onNotificationClick);
  }

  onNotificationClick(String payload) {
    print(
        'clicked inside on notification click and received atsign is $payload');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AtFollows example app'),
          actions: [
            // if (_atsign != null)
          ],
        ),
        body: Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    if (_atsign != null)
                      ListTile(
                          leading: Text(
                            '$_atsign',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.group),
                                onPressed: () async {
                                  setState(() {
                                    _loading = true;
                                  });
                                  await _getFollows(context);
                                  setState(() {
                                    _loading = false;
                                  });
                                },
                              ),
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    setState(() {
                                      _loading = true;
                                    });
                                    await atService.deleteAtsign(_atsign);
                                    _atsign = null;
                                    setState(() {
                                      _loading = false;
                                    });
                                  }),
                            ],
                          )),
                    if (_atsign != null) Divider(thickness: 0.8),
                    if (_atsign == null)
                      Center(
                        child: TextButton(
                            onPressed: () async {
                              await _onboard(context);
                            },
                            child: Text(AppStrings.onboard)),
                      ),
                  ],
                ),
                if (_loading) Center(child: CircularProgressIndicator())
              ],
            ),
          );
        }),
      ),
    );
  }

  _getFollows(ctxt) async {
    try {
      await atService.startMonitor();
      Navigator.push(
          ctxt,
          MaterialPageRoute(
              builder: (context) => Connections(
                  atClientserviceInstance: atService.atClientServiceInstance,
                  appColor: Colors.blue)));
    } catch (e) {
      print('Fetching follows throws $e exception');
      setState(() {
        _loading = false;
      });
    }
  }

  _onboard(context) async {
    var atService = AtService.getInstance();
    var preference = await atService.getAtClientPreference();

    Onboarding(
      domain: AppConstants.rootDomain,
      context: context,
      onboard: (value, atsign) async {
        atService.atClientServiceInstance = value[atsign];
        atService.atClientInstance = atService.atClientServiceInstance.atClient;
        _atsign = await atService.getAtSign();
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {});
        });
      },
      onError: (error) {
        Center(child: Text('Onboarding throws $error'));
      },
      nextScreen: null,
      atClientPreference: preference,
    );
  }
}
