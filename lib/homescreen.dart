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
            importance: NotificationImportance.High)
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
        AwesomeNotifications().cancelAll();
        tasks.clear();
        List<Task> taskList = [];
        for (int i = 0; i < value.length; i++) {
          if (value[i].status == 'active') {
            if (value[i].reminded == 0) {
              taskList.add(Task(
                  "${value[i].id}",
                  value[i].time,
                  DateFormat('hh:mm a').parse(value[i].time),
                  value[i].task,
                  userHonorific,
                  'active',
                  false,
                  value[i].repeat));
            } else {
              taskList.add(Task(
                  "${value[i].id}",
                  value[i].time,
                  DateFormat('hh:mm a').parse(value[i].time),
                  value[i].task,
                  userHonorific,
                  'active',
                  true,
                  value[i].repeat));
            }
          } else {
            if (value[i].reminded == 0) {
              taskList.add(Task(
                  "${value[i].id}",
                  value[i].time,
                  DateFormat('hh:mm a').parse(value[i].time),
                  value[i].task,
                  userHonorific,
                  'disabled',
                  false,
                  value[i].repeat));
            } else {
              taskList.add(Task(
                  "${value[i].id}",
                  value[i].time,
                  DateFormat('hh:mm a').parse(value[i].time),
                  value[i].task,
                  userHonorific,
                  'disabled',
                  true,
                  value[i].repeat));
            }
          }
        }
        if (taskList.isNotEmpty) {
          var cron = Cron();
          for (int i = 0; i < taskList.length; i++) {
            AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: i,
                  channelKey: 'key1',
                  title: 'Hello, $userHonorific!',
                  body: 'It is time to do your task.',
                  fullScreenIntent: true,
                ),
                actionButtons: [
                  NotificationActionButton(
                    color: Colors.blue,
                    key: 'dismiss',
                    label: 'Dismiss',
                    buttonType: ActionButtonType.Default,
                  ),
                ],
                schedule: NotificationCalendar(
                    hour: taskList[i].date.hour,
                    minute: taskList[i].date.minute,
                    second: 0));

            AwesomeNotifications().actionStream.listen((event) {
              if (event.buttonKeyPressed == 'dismiss') {
                AwesomeNotifications().dismiss(i);
                SystemNavigator.pop();
                startService();
              }
            });
            AwesomeNotifications().actionStream.listen((event) {
              if (event.createdSource == NotificationSource.Local) {
                String weekday;
                var currentWeekday = DateFormat('EEEE');
                weekday = currentWeekday.format(DateTime.now()).toString();
                weekday = weekday.substring(0, 3);
                if (taskList[i].repeat.contains(weekday) ||
                    (taskList[i].repeat.contains('Only once') &&
                        taskList[i].isReminded == false)) {
                  speak(userHonorific, taskList[i].task);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Speech(
                                id: int.parse(taskList[i].id),
                                notificationID: i,
                                task: taskList[i].task,
                                time: taskList[i].time,
                                honorific: userHonorific,
                                startservice: initState,
                              )));

                  Vibration.vibrate(pattern: [1000, 1500, 1000], repeat: 100);
                  handler.isReminded(int.parse(taskList[i].id), 1);

                  if (taskList[i].repeat.contains('Only once')) {
                    handler.updateTaskStatus(
                        int.parse(taskList[i].id), 'disabled');
                  }

                  insertIntoHistory(
                      taskList[i].task, taskList[i].time, taskList[i].repeat);

                  if (taskList[i].status == 'active') {
                    tasks.add(ScheduledTasksList(i, 'active'));
                  } else {
                    tasks.add(ScheduledTasksList(i, 'disabled'));
                  }
                }
              }
            });

            AwesomeNotifications().createdStream.listen((notification) {});
          }

          for (int j = 0; j < tasks.length; j++) {
            if (tasks[j].status == 'disabled') {
              AwesomeNotifications().cancel(tasks[j].id);
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
                      builder: (context) => SetAlarm(
                            startService: startService,
                            setVolume: setVolume,
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
