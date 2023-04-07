import 'package:flutter/material.dart';
import 'package:taskreminder/tasks.dart';
import 'set_alarm.dart';
import 'history.dart';
import 'package:taskreminder/db_helper.dart';
import 'package:cron/cron.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin? flutterlocalNotificationPlugin;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  late DataBase handler;

  @override
  void initState() {
    super.initState();
    handler = DataBase();
    handler.initializedDB();

    final cron = Cron();
    cron.schedule(Schedule.parse('*/3 * * * * *'), () async {
      var initializationSettingsAndroid =
          new AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = new IOSInitializationSettings();
      var initializationSettings = new InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      flutterlocalNotificationPlugin = new FlutterLocalNotificationsPlugin();
      flutterlocalNotificationPlugin!.initialize(initializationSettings,
          onSelectNotification: (String? payload) async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Tasks()));
      });

      _showNotificationWithSound();
      /*
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
      ); */
    });
  }

  Future _showNotificationWithSound() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channelId',
      'channelName',
      'channelDescription',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
    );
    var iosPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

    return Future.delayed(Duration(seconds: 5), () {
      return flutterlocalNotificationPlugin!.show(0, "Hello, Sir!",
          'It is time for you to do your task.', platformChannelSpecifics,
          payload: 'Default_Sound');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: const Text(
                "TASK",
                style: TextStyle(
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Color.fromARGB(255, 78, 49, 170),
                      ),
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Color.fromARGB(255, 78, 49, 170),
                      ),
                    ],
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: const Text(
                "REMINDER",
                style: TextStyle(
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Color.fromARGB(255, 78, 49, 170),
                      ),
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Color.fromARGB(255, 78, 49, 170),
                      ),
                    ],
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.w900),
              )),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const SetAlarm()));
            },
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.alarm,
                      color: Color.fromARGB(255, 78, 49, 170),
                      size: 25,
                    ),
                    SizedBox(
                      width: 3,
                      height: 0,
                    ),
                    Text(
                      'Set Reminder',
                      style: TextStyle(
                          color: Color.fromARGB(255, 78, 49, 170),
                          fontSize: 20),
                    )
                  ],
                )),
          ),
          const Divider(
            thickness: 1,
            color: Color.fromARGB(255, 78, 49, 170),
            indent: 70,
            endIndent: 70,
          ),
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Tasks()));
              },
              child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.task,
                        color: Color.fromARGB(255, 78, 49, 170),
                        size: 25,
                      ),
                      SizedBox(
                        width: 3,
                        height: 0,
                      ),
                      Text(
                        'Tasks',
                        style: TextStyle(
                            color: Color.fromARGB(255, 78, 49, 170),
                            fontSize: 20),
                      )
                    ],
                  ))),
          const Divider(
            thickness: 1,
            color: Color.fromARGB(255, 78, 49, 170),
            indent: 70,
            endIndent: 70,
          ),
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const History()));
              },
              child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.history,
                        color: Color.fromARGB(255, 78, 49, 170),
                        size: 25,
                      ),
                      SizedBox(
                        width: 3,
                        height: 0,
                      ),
                      Text(
                        'History',
                        style: TextStyle(
                          color: Color.fromARGB(255, 78, 49, 170),
                          fontSize: 20,
                        ),
                      )
                    ],
                  ))),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 178, 141, 255),
    );
  }
}
