import 'package:flutter/material.dart';
import 'package:taskreminder/tasks.dart';
import 'set_alarm.dart';
import 'history.dart';
import 'package:taskreminder/db_helper.dart';
import 'package:cron/cron.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:volume_control/volume_control.dart';

FlutterTts flutterTts = FlutterTts();
FlutterLocalNotificationsPlugin? flutterlocalNotificationPlugin;
bool? running;

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
  String status;
  int snooze;

  Task(this.id, this.time, this.date, this.task, this.honorific, this.status,
      this.snooze);
}

class ScheduledTasksList {
  ScheduledTask task;
  String status;
  String id;
  ScheduledTasksList(this.id, this.task, this.status);
}

class _HomeScreen extends State<HomeScreen> {
  final now = DateTime.now();
  List<ScheduledTasksList> tasks = [];
  bool speaking = true;

  @override
  void initState() {
    super.initState();
    startService();
    AwesomeNotifications().initialize(
      'resource://mipmap/launcher_icon',
      [
        NotificationChannel(
          channelKey: 'key1',
          channelName: 'Channel Name',
          channelDescription: 'Channel Description',
          importance: NotificationImportance.High,
        )
      ],
    );
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void speak(honorific, task) async {
    setState(() {
      running = true;
    });
    setVolume();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(.3);
    await flutterTts.setSpeechRate(0.5);
    while (running!) {
      await flutterTts.speak("$honorific, It is time for you to $task");
      await flutterTts.awaitSpeakCompletion(true);
      Future.delayed(const Duration(seconds: 8));
    }
  }

  void setVolume() async {
    // Get the current volume, min=0, max=1
    double _val = await VolumeControl.volume;

    if (_val <= 0.4) {
      VolumeControl.setVolume(0.7);
    }
  }

  void startService() async {
    late DataBase handler;
    late String userHonorific;
    handler = DataBase();
    handler.initializedDB();
    //fetch honorific
    await handler.getUserGender().then((value) {
      setState(() {
        userHonorific = value[0].honorific;
      });
    });
    await handler.retrieveTasks().then((value) {
      if (value.isNotEmpty) {
        //
        for (int j = 0; j < tasks.length; j++) {
          tasks[j].task.cancel();
        }
        tasks.clear();
        List<Task> timeList = [];
        for (int i = 0; i < value.length; i++) {
          String weekday;
          var currentWeekday = DateFormat('EEEE');
          weekday = currentWeekday.format(DateTime.now()).toString();
          weekday = weekday.substring(0, 3);

          if (value[i].repeat.contains(weekday) ||
              value[i].repeat.contains('Only once')) {
            //check if time has passed
            DateFormat formatter = DateFormat('hh:mm a');
            DateTime now = DateTime.now();
            var elapsedTime = formatter
                .parse(DateFormat('hh:mm a').format(now).toString())
                .difference(
                    DateFormat('hh:mm a').parse(value[i].time.toString()));
            //if not..
            if (!(elapsedTime.compareTo(const Duration(seconds: 1)) >= 0)) {
              if (value[i].status == 'active') {
                timeList.add(Task(
                    "${value[i].id}",
                    value[i].time,
                    DateFormat('hh:mm a').parse(value[i].time.toString()),
                    value[i].task,
                    userHonorific,
                    'active',
                    value[i].snooze));
              } else {
                timeList.add(Task(
                    "${value[i].id}",
                    value[i].time,
                    DateFormat('hh:mm a').parse(value[i].time.toString()),
                    value[i].task,
                    userHonorific,
                    'disabled',
                    value[i].snooze));
              }
            }
          }
        }
        if (timeList.isNotEmpty) {
          var cron = Cron();
          // timeList.sort((a, b) => a.date.compareTo(b.date));
          for (int i = 0; i < timeList.length; i++) {
            var task = cron.schedule(
              Schedule.parse(
                  '${timeList[i].date.minute} ${timeList[i].date.hour} * * *'),
              () async {
                AwesomeNotifications().createNotification(
                  content: NotificationContent(
                      id: i,
                      channelKey: 'key1',
                      title: 'Hello, ${timeList[i].honorific}!',
                      body: 'It is time to do your task.',
                      wakeUpScreen: true,
                      criticalAlert: true,
                      fullScreenIntent: true),
                  actionButtons: [
                    NotificationActionButton(
                      color: Colors.blue,
                      key: 'snooze',
                      label: 'Snooze',
                      buttonType: ActionButtonType.Default,
                    ),
                    NotificationActionButton(
                      color: Colors.blue,
                      key: 'dismiss',
                      label: 'Dismiss',
                      buttonType: ActionButtonType.Default,
                    ),
                  ],
                );

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
                          builder: (context) => Speech(
                                task: timeList[i].task,
                                time: timeList[i].time,
                                honorific: timeList[i].honorific,
                                len: timeList.length,
                                startservice: initState,
                                snooze: timeList[i].snooze,
                              )));
                });
                speak(timeList[i].honorific, timeList[i].task);
                await handler.isReminded(int.parse(timeList[i].id));
              },
            );
            if (timeList[i].status == 'active') {
              tasks.add(ScheduledTasksList(timeList[i].id, task, 'active'));
            } else {
              tasks.add(ScheduledTasksList(timeList[i].id, task, 'disabled'));
            }
          }

          for (int j = 0; j < tasks.length; j++) {
            if (tasks[j].status == 'disabled') {
              tasks[j].task.cancel();
            }
          }
        }
      }
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
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SetAlarm(startService: startService)));
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
                        builder: (context) => Tasks(start: startService)));
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const History()));
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
