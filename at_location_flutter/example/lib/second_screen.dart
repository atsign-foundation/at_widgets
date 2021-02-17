import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/screens/home/home_screen.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter_example/main.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:atsign_authentication_helper/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter_example/client_sdk_service.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String activeAtSign, receiver;
  Stream<List<KeyLocationModel>> newStream;
  @override
  void initState() {
    super.initState();
    activeAtSign =
        clientSdkService.atClientServiceInstance.atClient.currentAtSign;
    initializeLocationService(clientSdkService.atClientServiceInstance.atClient,
        activeAtSign, NavService.navKey);
    newStream = getAllNotification();
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
        title: Text("Second Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    bool result = await checkAtsign();
                    if (!result) {
                      CustomToast().show('Atsign not valid', context);
                      return;
                    }
                    sendShareLocationNotification(receiver, 30);
                  },
                  child: Text('Send Location '),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool result = await checkAtsign();
                    if (!result) {
                      CustomToast().show('Atsign not valid', context);
                      return;
                    }
                    sendRequestLocationNotification(receiver);
                  },
                  child: Text('Request Location'),
                ),
              ],
            ),
            SizedBox(
              height: 10,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                    stream: newStream,
                    builder: (context,
                        AsyncSnapshot<List<KeyLocationModel>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasError) {
                          return Text('error');
                        } else {
                          return ListView(
                              children: snapshot.data.map((notification) {
                            return Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(
                                '${snapshot.data.indexOf(notification) + 1}. ${notification.key}',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList());
                        }
                      } else {
                        return Text('No Data');
                      }
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> checkAtsign() async {
    if (receiver == null) {
      return false;
    } else if (!receiver.contains('@')) {
      receiver = '@' + receiver;
    }
    var checkPresence = await AtLookupImpl.findSecondary(
        receiver, MixedConstants.ROOT_DOMAIN, 64);
    return checkPresence != null;
  }
}
