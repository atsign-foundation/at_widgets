import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_login_flutter/domain/at_login_model.dart';
import 'package:at_login_flutter/services/at_login_service.dart';
import 'package:flutter/material.dart';
import 'package:at_login_flutter/utils/strings.dart';

class AtLoginDashboard extends StatefulWidget {
  final AtClientPreference atClientPreference;

  ///color to match with your app theme. Defaults to [orange].
  final Color appColor;

  final String atSign;

  final Widget nextScreen;


  AtLoginDashboard(
      {
        Key key,
        @required this.atClientPreference,
        @required this.atSign,
        @required this.nextScreen,
        this.appColor,
      }): super(key: key);

  @override
  _AtLoginDashboardState createState() => _AtLoginDashboardState(this.atSign);
}

class _AtLoginDashboardState extends State<AtLoginDashboard> {
  String atSign;
  _AtLoginDashboardState(atSign) {
    print('atSign is $atSign');
    this.atSign = atSign;
  }
  bool _loading = false;
  Map<AtKey, AtValue> _atLogins = {};
  AtLoginService _atLoginService;

  @override
  void initState() {
    _atLoginService = AtLoginService();
    _atLoginService.setAtClientPreference = widget.atClientPreference;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_atLogins.isEmpty) {
      _getAtLoginList(atSign);
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              this.atSign == null || this.atSign == ''?
              Strings.dashboardTitle : this.atSign
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => widget.nextScreen
                    ),
                  );
                },
              );
            },
          ),
          actions: [
            // if (atSign != null)
          ],
        ),
        body: Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    ListView(
                      shrinkWrap: true,
                      children: _buildAtLoginWidgets(),
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

  _getAtLoginList(atSign) async {
    Map<AtKey, AtValue> atLoginMap;
    await _atLoginService.setAtsign(atSign);
    atLoginMap = await _atLoginService.getAtLogins();
    return atLoginMap;
  }

  _buildAtLoginWidgets() {
    List<Widget> widgets = [];
    _atLogins.forEach((k,v) =>
        widgets.addAll(_atLoginListTile(k,v))
    );
    return widgets;
  }

  _atLoginListTile(AtKey atKey, AtValue atValue) {
    AtLoginObj atLoginObj = atValue.value;
    // var meta = atValue.metadata;
    return <Widget>[
      ListTile(
        leading: Text(
          atLoginObj.requestorUrl,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  await _atLoginService.delete(atKey);
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => widget.nextScreen
                    ),
                  );

                  setState(() {
                    _loading = false;
                  });
                }),
          ],
        ),
      )
    ];
  }
}

// class AtLoginDashboard extends StatefulWidget {
//   ///Perform operations like delete history items for a particular @sign.
//   final atClientserviceInstance;
//
//   ///color to match with your app theme. Defaults to [orange].
//   final Color appColor;
//
//   ///The atsign received from a website QR code to login with.
//   final String atsign;
//
//   ///requestorUrl received from a website QR code to login with.
//   final String requestorUrl;
//
//   AtLoginDashboard(
//       {
//         @required this.atClientserviceInstance,
//         @required this.atsign,
//         this.appColor,
//         this.requestorUrl,
//       });
//
//   @override
//   _AtLoginDashboardState createState() => _AtLoginDashboardState();
// }
//
// class _AtLoginDashboardState extends State<AtLoginDashboard> {
//   String _atsign;
//   // AtService atService = AtService.getInstance();
//   // NotificationService _notificationService;
//   bool _loading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('AtLogin example app'),
//           actions: [
//             // if (_atsign != null)
//           ],
//         ),
//         body: Builder(builder: (context) {
//           return Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Stack(
//               children: [
//                 Column(
//                   children: [
//                     if (_atsign != null)
//                       ListTile(
//                           leading: Text(
//                             '$_atsign',
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               // IconButton(
//                               //   icon: Icon(Icons.group),
//                               //   onPressed: () async {
//                               //     setState(() {
//                               //       _loading = true;
//                               //     });
//                               //     await _doAtLogin(context);
//                               //     setState(() {
//                               //       _loading = false;
//                               //     });
//                               //   },
//                               // ),
//                               IconButton(
//                                   icon: Icon(Icons.delete),
//                                   onPressed: () async {
//                                     setState(() {
//                                       _loading = true;
//                                     });
//                                     // TODO add confirmation dialog
//                                     // await atService.deleteAtsign(_atsign);
//                                     _atsign = null;
//                                     setState(() {
//                                       _loading = false;
//                                     });
//                                   }),
//                               IconButton(
//                                   icon: Icon(Icons.login),
//                                   onPressed: () async {
//                                     setState(() {
//                                       _loading = true;
//                                     });
//                                     // await _doAtLogin(context);
//                                     // _atsign = null;
//                                     setState(() {
//                                       _loading = false;
//                                     });
//                                   })                            ],
//                           )),
//                     if (_atsign != null) Divider(thickness: 0.8),
//                     if (_atsign == null)
//                       Center(
//                         child: TextButton(
//                             onPressed: () async {
//                               // await _onboard(context);
//                             },
//                             child: Text(Strings.letsGo)),
//                       ),
//                   ],
//                 ),
//                 if (_loading) Center(child: CircularProgressIndicator())
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }