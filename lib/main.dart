import 'package:flutter/material.dart';
import 'package:taskreminder/history.dart';
import 'package:taskreminder/homescreen.dart';
import 'package:taskreminder/set_alarm.dart';
import 'gender.dart';
import 'db_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  FlutterLocalNotificationsPlugin? flutterlocalNotificationPlugin;
  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterlocalNotificationPlugin = new FlutterLocalNotificationsPlugin();
    flutterlocalNotificationPlugin!.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TextButton(
                onPressed: _showNotificationWithSound,
                child: new Text('Show Notification With Sound'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showNotificationWithSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription',
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true);
    var iosPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterlocalNotificationPlugin!.show(
        0, 'TITLE', 'body', platformChannelSpecifics,
        payload: 'Default_Sound');
  }
}
