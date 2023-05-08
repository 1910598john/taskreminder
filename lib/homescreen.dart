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
    //initialize awesome_notifications
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

  void startService() async {
    late DataBase handler;
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
        //
        for (int j = 0; j < tasks.length; j++) {
          tasks[j].task.cancel();
        }
        tasks.clear();
        List<Task> taskList = [];
        for (int i = 0; i < value.length; i++) {
          //check if time has passed
          DateFormat formatter = DateFormat('hh:mm a');
          DateTime now = DateTime.now();
          /*var elapsedTime = formatter
              .parse(DateFormat('hh:mm a').format(now).toString())
              .difference(
                  DateFormat('hh:mm a').parse(value[i].time.toString()));  */
          //if not..

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
          // taskList.sort((a, b) => a.date.compareTo(b.date));
          for (int i = 0; i < taskList.length; i++) {
            var task = cron.schedule(
              Schedule.parse(
                  '${taskList[i].date.minute} ${taskList[i].date.hour} * * *'),
              () async {
                String weekday;
                var currentWeekday = DateFormat('EEEE');
                weekday = currentWeekday.format(DateTime.now()).toString();
                weekday = weekday.substring(0, 3);
                if (taskList[i].repeat.contains(weekday) ||
                    (taskList[i].repeat.contains('Only once') &&
                        taskList[i].isReminded == false)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Speech(
                                id: int.parse(taskList[i].id),
                                task: taskList[i].task,
                                time: taskList[i].time,
                                honorific: taskList[i].honorific,
                                startservice: initState,
                              )));

                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: i,
                      channelKey: 'key1',
                      title: 'Hello, ${taskList[i].honorific}!',
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
                  );

                  speak(taskList[i].honorific, taskList[i].task);
                  await handler.isReminded(int.parse(taskList[i].id), 1);

                  if (taskList[i].repeat.contains('Only once')) {
                    await handler.updateTaskStatus(
                        int.parse(taskList[i].id), 'disabled');
                  }
                }
              },
            );

            if (taskList[i].status == 'active') {
              tasks.add(ScheduledTasksList(taskList[i].id, task, 'active'));
            } else {
              tasks.add(ScheduledTasksList(taskList[i].id, task, 'disabled'));
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
