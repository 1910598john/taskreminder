import 'package:flutter/material.dart';
import 'package:taskreminder/speech.dart';
import 'package:taskreminder/tasks.dart';
import 'set_alarm.dart';
import 'history.dart';
import 'package:taskreminder/db_helper.dart';
import 'package:cron/cron.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:volume_control/volume_control.dart';
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();
FlutterLocalNotificationsPlugin? flutterlocalNotificationPlugin;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class Task {
  String id;
  String time;
  DateTime date;
  String task;
  String honorific;
  bool status;
  int snooze;

  Task(this.id, this.time, this.date, this.task, this.honorific, this.status,
      this.snooze);
}

class _HomeScreen extends State<HomeScreen> {
  late DataBase handler;
  final now = DateTime.now();
  //map tasks
  List<Task> timeList = [];
  late String userHonorific;
  bool speaking = true;

  @override
  void initState() {
    super.initState();
    handler = DataBase();
    handler.initializedDB();
    startService();
  }

  void setVolume() async {
    // Get the current volume, min=0, max=1
    double _val = await VolumeControl.volume;

    if (_val <= 0.4) {
      VolumeControl.setVolume(0.7);
    }
  }

  void startService() async {
    //fetch honorific
    handler.getUserGender().then((value) {
      setState(() {
        userHonorific = value[0].honorific;
      });
    });
    handler.retrieveTasks().then((value) {
      if (value.isNotEmpty) {
        for (int i = 0; i < value.length; i++) {
          String weekday;
          var currentWeekday = DateFormat('EEEE');
          weekday = currentWeekday.format(DateTime.now()).toString();
          weekday = weekday.substring(0, 3);
          if (value[i].status == 'active' &&
              (value[i].repeat.contains(weekday) ||
                  value[i].repeat.contains('Only once'))) {
            //check if time has passed
            DateFormat formatter = DateFormat('hh:mm a');
            DateTime now = DateTime.now();
            var elapsedTime = formatter
                .parse(DateFormat('hh:mm a').format(now).toString())
                .difference(
                    DateFormat('hh:mm a').parse(value[i].time.toString()));
            //if not..
            if (!(elapsedTime.compareTo(const Duration(seconds: 1)) >= 0)) {
              //list tasks
              timeList.add(Task(
                  "${value[i].id}",
                  value[i].time,
                  DateFormat('hh:mm a').parse(value[i].time.toString()),
                  value[i].task,
                  userHonorific,
                  true,
                  int.parse(value[i].snooze)));
            }
          }
        }
        if (timeList.isNotEmpty) {
          timeList.sort((a, b) => a.date.compareTo(b.date));
          for (int i = 0; i < timeList.length; i++) {
            var cron = Cron();
            cron.schedule(
              Schedule.parse(
                  '${timeList[i].date.minute} ${timeList[i].date.hour} * * *'),
              () async {
                var initializationSettingsAndroid =
                    const AndroidInitializationSettings(
                        '@mipmap/launcher_icon');
                var initializationSettingsIOS =
                    const IOSInitializationSettings();
                var initializationSettings = InitializationSettings(
                    android: initializationSettingsAndroid,
                    iOS: initializationSettingsIOS);
                flutterlocalNotificationPlugin =
                    FlutterLocalNotificationsPlugin();
                await flutterlocalNotificationPlugin!
                    .initialize(initializationSettings,
                        onSelectNotification: (String? payload) async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Speech(
                                task: timeList[i].task,
                                time: timeList[i].time,
                                honorific: timeList[i].honorific,
                                flutterTts: flutterTts,
                              )));
                });

                await showNotification();
                await speak(timeList[i].honorific, timeList[i].task);
              },
            );
          }
        }
      }
    });
  }

  Future<void> speak(userHonorific, userTask) async {
    setVolume();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    while (true) {
      await flutterTts.speak("$userHonorific, It is time for you to $userTask");
      await flutterTts.awaitSpeakCompletion(true);
      Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel',
      'channelName',
      'channelDescription',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
    );
    var iosPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

    await flutterlocalNotificationPlugin!.show(0, "Hello, Sir!",
        'It is time to do your task.', platformChannelSpecifics,
        payload: 'Default_Sound');
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
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          SetAlarm(startService: initState)));
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
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
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
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
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
