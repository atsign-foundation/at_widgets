import 'dart:convert';

import 'package:at_follows_flutter_example/services/at_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final notificationService = NotificationService._internal();
  NotificationService._internal() {
    init();
  }

  factory NotificationService() => notificationService;
  InitializationSettings initializationSettings;
  FlutterLocalNotificationsPlugin _notificationsPlugin;

  // ReceivedNotification didReceiveNotification =

  init() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isIOS) {
      _requestIOSPermissions();
    }
    initializePlatformSpecifics();
    print('initialiazed notification service');
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
    });
  }

  initializePlatformSpecifics() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        print('id $id, title $title, body $body, payload $payload');
        // ReceivedNotification receivedNotification = ReceivedNotification(
        //     id: id, title: title, body: body, payload: payload);
        // didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );

    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  }

  _requestIOSPermissions() {
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  showNotification(AtNotification atNotification) async {
    print('inside show notification...');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    var iosChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosChannelSpecifics);
    // NotificationPayload payload = NotificationPayload(
    //     file: fileName, name: from, size: double.parse(fileSize));
    await _notificationsPlugin.show(
        0,
        '${atNotification.from} is following your ${atNotification.to}',
        'Open the app to follow them back',
        platformChannelSpecifics,
        // payload: jsonEncode(payload)
        payload: jsonEncode(atNotification.toJson()));

    // await flutterLocalNotificationsPlugin.show(
    //     0, 'plain title', 'plain body', platformChannelSpecifics,
    //     payload: 'item x');
  }

//   Future onDidReceiveLocalNotification(
//     int id, String title, String body, String payload) async {
//   // display a dialog with the notification details, tap ok to go to another page
//   showDialog(
//     context: context,
//     builder: (BuildContext context) => CupertinoAlertDialog(
//       title: Text(title),
//       content: Text(body),
//       actions: [
//         CupertinoDialogAction(
//           isDefaultAction: true,
//           child: Text('Ok'),
//           onPressed: () async {
//             Navigator.of(context, rootNavigator: true).pop();
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SecondScreen(payload),
//               ),
//             );
//           },
//         )
//       ],
//     ),
//   );
// }

  cancelNotification() async {
    await _notificationsPlugin.cancelAll();
  }
}
