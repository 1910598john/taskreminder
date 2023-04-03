import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:taskreminder/history.dart';
import 'package:taskreminder/homescreen.dart';
import 'package:taskreminder/set_alarm.dart';
import 'gender.dart';
import 'db_helper.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cron/cron.dart';

void main() {
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'channelKey',
            channelName: 'channelName',
            channelDescription: 'channelDescription')
      ],
      debug: true);
  final cron = Cron();
  cron.schedule(Schedule.parse('*/3 * * * * *'), () async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'channelKey',
        title: "Hello, Ma'am!",
        body: 'It is time to do your task.',
      ),
      actionButtons: [
        NotificationActionButton(
            key: "snooze", label: "Snooze", color: Colors.blue),
        NotificationActionButton(
            key: "dismiss", label: "Dismiss", color: Colors.blue)
      ],
    );
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((value) {
      if (!value) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    /*
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterlocalNotificationPlugin = new FlutterLocalNotificationsPlugin();
    flutterlocalNotificationPlugin!.initialize(initializationSettings);




    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'channelKey',
        title: "Hello, Ma'am!",
        body: 'It is time to do your task.',
      ),
      actionButtons: [
        NotificationActionButton(
            key: "snooze",
            label: "Snooze",
            color: Colors.blue),
        NotificationActionButton(
            key: "dismiss",
            label: "Dismiss",
            color: Colors.blue)
      ]));
    */
  }

  int x = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TextButton(
                onPressed: () {},
                child: new Text('Show Notification $x'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  /*
  Future _showNotificationWithSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription',
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true);
    var iosPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

    return Future.delayed(Duration(seconds: 5), () {
      return flutterlocalNotificationPlugin!.show(
          0, 'TITLE', 'body', platformChannelSpecifics,
          payload: 'Default_Sound');
    });
  }*/
}
