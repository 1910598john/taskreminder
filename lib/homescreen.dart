import 'package:flutter/material.dart';
import 'package:taskreminder/tasks.dart';
import 'set_alarm.dart';
import 'history.dart';
import 'package:taskreminder/db_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'speech.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:volume_control/volume_control.dart';
import 'package:wakelock/wakelock.dart';

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
  List<TasksHistory> history = [];

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

    startService();
  }

  void speak(honorific, task) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(.3);
    await flutterTts.setSpeechRate(0.5);

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
      VolumeControl.setVolume(1);
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
    history.clear();
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
          DateTime time = DateFormat("hh:mm a").parse(value[i].time);
          //if (value[i].repeat == 'Only once') {
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
                  color: const Color.fromARGB(255, 224, 82, 82),
                  key: 'dismiss',
                  label: 'Open',
                  buttonType: ActionButtonType.Default,
                ),
              ],
              schedule: NotificationCalendar(
                  hour: time.hour,
                  minute: time.minute,
                  second: 0,
                  preciseAlarm: true,
                  repeats: false));
          //} else {
          List<int> weekdays = [];
          int spaceCount = value[i].repeat.split(" ").length;
          String repeat = value[i].repeat;
          for (int k = 0; k < spaceCount; k++) {
            if (repeat.contains('Sun')) {
              weekdays.add(0);
              repeat = repeat.replaceAll("Sun", "");
            } else if (repeat.contains('Mon')) {
              weekdays.add(1);
              repeat = repeat.replaceAll("Mon", "");
            } else if (repeat.contains('Tue')) {
              weekdays.add(2);
              repeat = repeat.replaceAll("Tue", "");
            } else if (repeat.contains('Wed')) {
              weekdays.add(3);
              repeat = repeat.replaceAll("Wed", "");
            } else if (repeat.contains('Thu')) {
              weekdays.add(4);
              repeat = repeat.replaceAll("Thu", "");
            } else if (repeat.contains('Fri')) {
              weekdays.add(5);
              repeat = repeat.replaceAll("Fri", "");
            } else if (repeat.contains('Sat')) {
              weekdays.add(6);
              repeat = repeat.replaceAll("Sat", "");
            }
          }
          /*
            for (int y = 0; y < weekdays.length; y++) {
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
                        "task": "${weekdays.length}",
                        "time": value[i].time,
                        "honorific": userHonorific,
                        "status": value[i].status,
                        "repeat": value[i].repeat,
                        "reminded": "${value[i].reminded}",
                        "notifID": "$i",
                      }),
                  actionButtons: [
                    NotificationActionButton(
                      color: const Color.fromARGB(255, 224, 82, 82),
                      key: 'dismiss',
                      label: 'Open',
                      buttonType: ActionButtonType.Default,
                    ),
                  ],
                  schedule: NotificationCalendar(
                      weekday: weekdays[y],
                      hour: time.hour,
                      minute: time.minute,
                      second: 0,
                      preciseAlarm: true,
                      repeats: false));
            }
            */
          //}
        }
        AwesomeNotifications().displayedStream.listen((receivedNotification) {
          final payload = receivedNotification.payload;

          String weekday;
          var currentWeekday = DateFormat('EEEE');
          weekday = currentWeekday.format(DateTime.now()).toString();
          weekday = weekday.substring(0, 3);

          if (payload!['repeat']!.contains(weekday) ||
              (payload['repeat']!.contains('Only once') &&
                  payload['reminded'] == '0')) {
            speak(userHonorific, payload['task']);

            Wakelock.enable();
            // Vibration.vibrate(pattern: [1000, 1500, 1000], repeat: 100);
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
          } else {
            AwesomeNotifications()
                .cancelSchedule(int.parse("${payload['notifID']}"));
          }
        });

        AwesomeNotifications().createdStream.listen((notification) {
          final payload = notification.payload;

          if (payload!['status'] == 'disabled') {
            cancelTask(int.parse("${payload['notifID']}"));
          }
        });

        AwesomeNotifications().actionStream.listen((event) {
          final payload = event.payload;
          if (payload!['reminded'] == '0') {
            handler.isReminded(int.parse("${payload['id']}"), 1);

            insertIntoHistory(
                payload['task'], payload['time'], payload['repeat']);
          }
        });
      } else {
        cancelAllTasks();
      }
    });

    await handler.retrieveDoneTasks().then((value) {
      if (value.isNotEmpty) {
        for (int i = 0; i < value.length; i++) {
          TasksHistory task = TasksHistory(
              task: value[i].task,
              time: value[i].time,
              repeat: value[i].repeat);
          history.add(task);
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
                        color: Color.fromARGB(255, 224, 82, 82),
                      ),
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Color.fromARGB(255, 224, 82, 82),
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
                        color: Color.fromARGB(255, 224, 82, 82),
                      ),
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Color.fromARGB(255, 224, 82, 82),
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
                      color: Colors.white,
                      size: 25,
                    ),
                    SizedBox(
                      width: 3,
                      height: 0,
                    ),
                    Text(
                      'Set Reminder',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                )),
          ),
          const Divider(
            thickness: 1,
            color: Colors.white,
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
                        color: Colors.white,
                        size: 25,
                      ),
                      SizedBox(
                        width: 3,
                        height: 0,
                      ),
                      Text(
                        'Tasks',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    ],
                  ))),
          const Divider(
            thickness: 1,
            color: Colors.white,
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
                        builder: (context) => History(
                              history: history,
                            )));
              },
              child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 25,
                      ),
                      SizedBox(
                        width: 3,
                        height: 0,
                      ),
                      Text(
                        'History',
                        style: TextStyle(
                          color: Colors.white,
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
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          height: 50,
          color: const Color.fromARGB(255, 128, 0, 0),
          child: const Center(
              child: Text(
            'team.taskreminder@gmail.com',
            style: TextStyle(
                color: Color.fromARGB(255, 242, 121, 121), fontSize: 15),
          )),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 128, 0, 0),
    );
  }
}
