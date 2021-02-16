// import 'package:at_contacts_flutter/at_contacts_flutter.dart';
// import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_location_flutter/at_location_flutter.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/screens/home/home_screen.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter_example/main.dart';
import 'package:atsign_authentication_helper/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter_example/client_sdk_service.dart';
// import 'package:at_contacts_flutter/screens/contacts_screen.dart';
// import 'package:at_contacts_flutter/screens/blocked_screen.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String activeAtSign;
  Stream newStream;
  @override
  void initState() {
    super.initState();
    activeAtSign =
        clientSdkService.atClientServiceInstance.atClient.currentAtSign;
    // AtLocationNotificationListener().init(
    //     clientSdkService.atClientServiceInstance.atClient,
    //     clientSdkService.atClientServiceInstance.atClient.currentAtSign,
    //     NavService.navKey);
    initializeLocationService(
        clientSdkService.atClientServiceInstance.atClient,
        clientSdkService.atClientServiceInstance.atClient.currentAtSign,
        NavService.navKey);
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
            ElevatedButton(
              onPressed: () {},
              child: Text('Show blocked contacts'),
            ),
            ElevatedButton(
              onPressed: () {
                sendShareLocationNotification('@ashish🛠', 30);
              },
              child: Text('Send Location '),
            ),
            ElevatedButton(
              onPressed: () {
                sendRequestLocationNotification('@ashish🛠');
              },
              child: Text('Request Location'),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: KeyStreamService().atNotificationsStream,
                  builder: (context,
                      AsyncSnapshot<List<KeyLocationModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasError) {
                        return Text('error');
                      } else {
                        return ListView(
                            children: snapshot.data.map((notification) {
                          return Text(notification.key);
                        }).toList());
                      }
                    } else {
                      return Text('No Data');
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
