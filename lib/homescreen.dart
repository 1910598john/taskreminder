import 'package:vibration/vibration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:wakelock/wakelock.dart';

// import 'package:workmanager/workmanager.dart';

FlutterTts flutterTts = FlutterTts();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool? running;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class Task {
  String id;
  String time;
  String repeat;
  DateTime date;
  String task;
  String honorific;
  String status;
  bool isReminded;

  Task(this.id, this.time, this.date, this.task, this.honorific, this.status,
      this.isReminded, this.repeat);
}

class ScheduledTasksList {
  String status;
  int id;
  ScheduledTasksList(this.id, this.status);
}

class _HomeScreen extends State<HomeScreen> {
  final now = DateTime.now();
  late DataBase handler;
  List<ScheduledTasksList> tasks = [];
  bool speaking = true;
  List<int> idList = [];

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().initialize(
      'resource://mipmap/launcher_icon',
      [
        NotificationChannel(
            channelKey: 'key1',
            channelName: 'Channel Name',
            channelDescription: 'Channel Description',
            importance: NotificationImportance.Max,
            criticalAlerts: true)
      ],
    );
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    //initialize tts
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(.3);
    flutterTts.setSpeechRate(0.5);

    startService();
  }

  void speak(honorific, task) async {
    setState(() {
      running = true;
    });
    setVolume();

    while (running!) {
      await flutterTts.speak("$honorific, It is time for you to $task");
      await flutterTts.awaitSpeakCompletion(true);
    }
  }

  void setVolume() async {
    // Get the current volume, min=0, max=1
    double _val = await VolumeControl.volume;

    if (_val <= 0.4) {
      VolumeControl.setVolume(0.7);
    }
  }

  void insertIntoHistory(task, time, repeat) async {
    TasksHistory data = TasksHistory(task: task, time: time, repeat: repeat);
    List<TasksHistory> lst = [data];
    await handler.insertHistory(lst);
  }

  Future<void> cancelAllTasks() async {
    await AwesomeNotifications().cancelAll();
    await AwesomeNotifications().cancelAllSchedules();
  }

  Future<void> cancelTask(int id) async {
    await AwesomeNotifications().cancelSchedule(id);
    await AwesomeNotifications().cancel(id);
  }

  Future<void> dismissAll() async {
    AwesomeNotifications().dismissAllNotifications();
  }

  void startService() async {
    late String userHonorific;
    var now = DateTime.now();
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
        cancelAllTasks();
        for (int i = 0; i < value.length; i++) {
          bool repeat = true;

          DateTime time = DateFormat("hh:mm a").parse(value[i].time);

          if (value[i].repeat == 'Only once') {
            repeat = false;
            AwesomeNotifications().createNotification(
                content: NotificationContent(
                    id: i,
                    channelKey: 'key1',
                    title: 'Hello, $userHonorific!',
                    body: 'It is time to do your task.',
                    fullScreenIntent: true,
                    wakeUpScreen: true,
                    locked: true,
                    criticalAlert: true,
                    payload: {
                      "id": "${value[i].id}",
                      "task": value[i].task,
                      "time": value[i].time,
                      "honorific": userHonorific,
                      "status": value[i].status,
                      "repeat": value[i].repeat,
                      "reminded": "${value[i].reminded}",
                      "notifID": "$i",
                    }),
                actionButtons: [
                  NotificationActionButton(
                    color: Colors.blue,
                    key: 'dismiss',
                    label: 'Dismiss',
                    buttonType: ActionButtonType.Default,
                  ),
                ],
                schedule: NotificationCalendar(
                    hour: time.hour,
                    minute: time.minute,
                    second: 0,
                    preciseAlarm: true,
                    repeats: repeat));
          } else {
            List<int> weekdays = [];
            int spaceCount = value[i].repeat.split(" ").length - 1;
            String repeat = value[i].repeat;
            for (int k = 0; k < spaceCount; k++) {
              if (value[i].repeat.contains('Sun')) {
                weekdays.add(0);
                repeat.replaceAll('Sun', '');
              } else if (value[i].repeat.contains('Mon')) {
                weekdays.add(1);
                repeat.replaceAll('Mon', '');
              } else if (value[i].repeat.contains('Tue')) {
                weekdays.add(2);
                repeat.replaceAll('Tue', '');
              } else if (value[i].repeat.contains('Wed')) {
                weekdays.add(3);
                repeat.replaceAll('Wed', '');
              } else if (value[i].repeat.contains('Thu')) {
                weekdays.add(4);
                repeat.replaceAll('Thu', '');
              } else if (value[i].repeat.contains('Fri')) {
                weekdays.add(5);
                repeat.replaceAll('Fri', '');
              } else if (value[i].repeat.contains('Sat')) {
                weekdays.add(6);
                repeat.replaceAll('Sat', '');
              }
            }

            for (var weekday in weekdays) {
              AwesomeNotifications().createNotification(
                  content: NotificationContent(
                      id: i,
                      channelKey: 'key1',
                      title: 'Hello, $userHonorific!',
                      body: 'It is time to do your task.',
                      fullScreenIntent: true,
                      wakeUpScreen: true,
                      locked: true,
                      criticalAlert: true,
                      payload: {
                        "id": "${value[i].id}",
                        "task": value[i].task,
                        "time": value[i].time,
                        "honorific": userHonorific,
                        "status": value[i].status,
                        "repeat": value[i].repeat,
                        "reminded": "${value[i].reminded}",
                        "notifID": "$i",
                      }),
                  actionButtons: [
                    NotificationActionButton(
                      color: Colors.blue,
                      key: 'dismiss',
                      label: 'Dismiss',
                      buttonType: ActionButtonType.Default,
                    ),
                  ],
                  schedule: NotificationCalendar(
                      weekday: weekday,
                      hour: time.hour,
                      minute: time.minute,
                      second: 0,
                      preciseAlarm: true,
                      repeats: false));
            }
          }
        }
        AwesomeNotifications().createdStream.listen((notification) {
          final payload = notification.payload;

          if (payload!['status'] == 'disabled') {
            cancelTask(int.parse("${payload['notifID']}"));
          }
        });

        AwesomeNotifications().actionStream.listen((receivedNotification) {
          final payload = receivedNotification.payload;

          speak(userHonorific, payload!['task']);

          Wakelock.enable();
          if (receivedNotification.buttonKeyPressed == 'dismiss') {
            dismissAll();
            startService();
          }

          String weekday;
          var currentWeekday = DateFormat('EEEE');
          weekday = currentWeekday.format(DateTime.now()).toString();
          weekday = weekday.substring(0, 3);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Speech(
                        id: int.parse("${payload['id']}"),
                        notificationID: int.parse("${payload['notifID']}"),
                        task: "${payload['task']}",
                        time: "${payload['time']}",
                        honorific: userHonorific,
                        startservice: initState,
                        cancelAll: cancelAllTasks,
                      )));

          if (payload['reminded'] == '0') {
            handler.isReminded(int.parse("${payload['id']}"), 1);

            insertIntoHistory(
                payload['task'], payload['time'], payload['repeat']);
          }

          if (payload['repeat']!.contains(weekday) ||
              (payload['repeat']!.contains('Only once') &&
                  payload['reminded'] == '0')) {
            // Vibration.vibrate(pattern: [1000, 1500, 1000], repeat: 100);

            if (payload['repeat']!.contains('Only once')) {
              handler.updateTaskStatus(
                  int.parse("${payload['id']}"), 'disabled');
            }

            if (payload['status'] == 'active') {
              tasks.add(ScheduledTasksList(
                  int.parse("${payload['notifID']}"), 'active'));
            } else {
              tasks.add(ScheduledTasksList(
                  int.parse("${payload['notifID']}"), 'disabled'));
            }
          }
        });
      } else {
        cancelAllTasks();
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
                      builder: (context) => SetAlarm(
                            startService: startService,
                            setVolume: setVolume,
                            lst: idList,
                          )));
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
                        builder: (context) => Tasks(
                              start: startService,
                              cancelAll: cancelAllTasks,
                            )));
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
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
          height: 50,
          color: const Color.fromARGB(255, 178, 141, 255),
          child: const Center(
              child: Text(
            'team.taskreminder@gmail.com',
            style: TextStyle(
                color: Color.fromARGB(255, 126, 98, 216), fontSize: 15),
          )),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 178, 141, 255),
    );
  }
}
