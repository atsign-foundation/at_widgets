import 'package:at_login_flutter/widgets/at_login_dashboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_login_flutter/services/at_login_service.dart';
import 'package:at_login_flutter/at_login_flutter.dart';
import 'package:at_login_flutter/widgets/at_login_widget.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:at_login_flutter_example/services/my_app_service.dart';
import 'package:at_login_flutter_example/services/notification_service.dart';
import 'package:at_login_flutter_example/utils/app_strings.dart';
import 'package:at_login_flutter_example/utils/app_constants.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  AtClientPreference _atClientPrefernce;
  NotificationService _notificationService;
  MyAppService _myAppService = MyAppService.getInstance();
  var _logger = AtSignLogger('HomeWidget');
  bool _loading = false;
  List<String> _atSignsList = [];
  @override
  void initState() {
    _getAtsignsList();
    _myAppService
        .getAtClientPreference()
        .then((preference) => _atClientPrefernce = preference);
    super.initState();
    _notificationService = NotificationService();
    _notificationService.setOnNotificationClick(onNotificationClick);
  }

  onNotificationClick(String payload) {
    print(
        'clicked inside on notification click and received atSign is $payload');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appTitle),
          actions: [
            // if (_atSign != null)
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child:
          Column(
            children: [
              SizedBox(height: 40),
              Text(
                AppStrings.welcome,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_atSignsList.isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: 40),
                    Text(
                      AppStrings.hasAtsignPre,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(thickness: 0.8),
                    Column(
                      children: <Widget>[
                        ListView(
                          shrinkWrap: true,
                          children: _buildAtSignWidgets(),
                        ),
                      ],
                    ),
                    Divider(thickness: 0.8),
                    SizedBox(height: 20),
                    Text(
                      AppStrings.loginNext,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 0.8),
                    SizedBox(height: 20),
                    Center(
                      child:
                      ElevatedButton(
                        child: const Text(AppStrings.tryIt),
                        onPressed: () async {
                          _doLogin(context);
                        },
                      ),
                    ),
                  ],
                )
              else if (_atSignsList.isEmpty)
                Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      AppStrings.overview,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      AppStrings.linkListener,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      AppStrings.onboardNext,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 0.8),
                    SizedBox(height: 20),
                    Center(
                      child:
                      ElevatedButton(
                        child: const Text(AppStrings.letsGo),
                        onPressed: () {
                          _doOnboard(context);
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  _getAtsignsList() async {
    List<String> atSignsList;
    atSignsList = await AtLoginService().getAtsignList();
    _logger.info('_getAtsignsList found ${atSignsList.length} atSigns');
    setState(() {
      _atSignsList = atSignsList;
    });
  }

  _buildAtSignWidgets() {
    List<Widget> widgets = [];
    for (int i = 0; i < _atSignsList.length; i++) {
      widgets.addAll(_atSignListTile(_atSignsList[i]));
    }
    return widgets;
  }

  _atSignListTile(String atSign) {
    return <Widget>[
      ListTile(
        leading: Text(
          atSign,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.alarm_sharp),
              onPressed: () async {
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AtLoginDashboardWidget(
                          atClientPreference: _atClientPrefernce,
                          atSign: atSign,
                          nextScreen: HomeWidget(),
                      )
                  ),
                );
              },
            ),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  //TODO - add confirmation dialog
                  await _myAppService.deleteAtsign(atSign);
                  setState(() {
                    _loading = false;
                  });
                }),
          ],
        ),
      )
    ];
  }

  _doOnboard(ctxt) async {
    var preference = await _myAppService.getAtClientPreference();
    Onboarding(
      domain: AppConstants.rootDomain,
      context: ctxt,
      nextScreen: null,
      atClientPreference: preference,
      onboard: (value, atSign) async {
        _myAppService.atClientServiceInstance = value[atSign];
        _myAppService.atClientInstance = _myAppService.atClientServiceInstance.atClient;
        // _atSign = await _myAppService.getAtSign();
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {});
        });
      },
      onError: (error) {
        Center(child: Text('Onboarding throws $error'));
      },
    );
  }

  _doLogin(ctxt) async {
    var preference = await _myAppService.getAtClientPreference();
    AtLogin(
      domain: AppConstants.rootDomain,
      context: ctxt,
      atClientPreference: preference,
      nextScreen: AtLoginDashboardWidget(
        atClientPreference:preference,
        atSign: await _myAppService.getAtSign(),
        nextScreen: HomeWidget(),
      ),
      login: (value, atSign) async {
        _myAppService.atClientServiceInstance = value[atSign];
        _myAppService.atClientInstance = _myAppService.atClientServiceInstance.atClient;
        // _atSign = await _myAppService.getAtSign();
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {});
        });
      },
      onError: (error) {
        Center(child: Text('Onboarding throws $error'));
      },
    );
  }
}
