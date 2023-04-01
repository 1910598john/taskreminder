import 'package:flutter/material.dart';
import 'package:taskreminder/history.dart';
import 'package:taskreminder/homescreen.dart';
import 'package:taskreminder/set_alarm.dart';
import 'gender.dart';
import 'db_helper.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
/*
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
*/
  /*
  FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var androidInitialize = new AndroidInitializationSettings('flutter_logo');
    var initializationSettings =
        new InitializationSettings(android: androidInitialize);
    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initializationSettings);
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        'channelId', 'Local Notification', 'HOPE IT WORKS',
        importance: Importance.high);
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails);
    await localNotification.show(
        0, "TITLE", "TEST CONTENT", generalNotificationDetails);
  }
  */
  @override
  Widget build(BuildContext context) {
    //Workmanager().initialize(test);
    return MaterialApp(
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      home: CheckGender(),
      debugShowCheckedModeBanner: false,
    );
  }
}
