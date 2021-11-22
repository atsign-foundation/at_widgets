import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/screens/home/home_screen.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter_example/client_sdk_service.dart';
import 'package:at_location_flutter_example/main.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign, receiver;
  Stream<List<KeyLocationModel>?>? newStream;
  MapController mapController = MapController();

  @override
  void initState() {
    try {
      super.initState();
      activeAtSign = clientSdkService
          .atClientServiceInstance!.atClientManager.atClient
          .getCurrentAtSign();
      initializeLocationService(
        NavService.navKey,
        mapKey: '',
        apiKey: '',
        showDialogBox: true,
      );

      newStream = getAllNotification() as Stream<List<KeyLocationModel>?>?;
    } catch (e) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return alertDialogContent();
          },
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          padding: EdgeInsets.all(20),
          children: [
            Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                'Welcome $activeAtSign!',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // any logic
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen(),
                ));
              },
              child: Text('Show maps'),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type an @sign',
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                onChanged: (val) {
                  receiver = val;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var result = await checkAtsign();
                    if (!result) {
                      CustomToast().show('Atsign not valid', context);
                      return;
                    }
                    await sendShareLocationNotification(receiver!, 30);
                  },
                  child: Text('Send Location '),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var result = await checkAtsign();
                    if (!result) {
                      CustomToast().show('Atsign not valid', context);
                      return;
                    }
                    await sendRequestLocationNotification(receiver!);
                  },
                  child: Text('Request Location'),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                var result = await checkAtsign();
                if (!result) {
                  CustomToast().show('Atsign not valid', context);
                  return;
                }
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => AtLocationFlutterPlugin(
                    [receiver],
                    calculateETA: true,
                    addCurrentUserMarker: true,
                    // etaFrom: LatLng(44, -112),
                    // textForCenter: 'Final',
                  ),
                ));
              },
              child: Text('Track Location '),
            ),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      showLocation(UniqueKey(), mapController, locationList: [
                    LatLng(30, 45),
                    LatLng(40, 45),
                  ]),
                ));
              },
              child: Text('Show multiple points '),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'Notifications:',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                  stream: KeyStreamService().atNotificationsStream,
                  builder: (context,
                      AsyncSnapshot<List<KeyLocationModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasError) {
                        return Text('error');
                      } else {
                        return (snapshot.data?.isNotEmpty ?? false)
                            ? renderNotifications(snapshot.data!)
                            : Text('No Data');
                      }
                    } else {
                      if (KeyStreamService()
                          .allLocationNotifications
                          .isNotEmpty) {
                        return renderNotifications(
                            KeyStreamService().allLocationNotifications);
                      }
                      return Text('No Data');
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget renderNotifications(List<KeyLocationModel> _data) {
    return Column(
        children: _data.map((notification) {
      return Padding(
        padding: const EdgeInsets.all(14.0),
        child: Text(
          '${_data.indexOf(notification) + 1}. ${notification.locationNotificationModel!.key}',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
        ),
      );
    }).toList());
  }

  Future<bool> checkAtsign() async {
    if (receiver == null) {
      return false;
    } else if (!receiver!.contains('@')) {
      receiver = '@' + receiver!;
    }
    var checkPresence = await AtLookupImpl.findSecondary(
        receiver!, MixedConstants.ROOT_DOMAIN, 64);
    return checkPresence != null;
  }

  Widget alertDialogContent() {
    return AlertDialog(
      title: Text('you are not authenticated.'),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: Text(
            'Ok',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
