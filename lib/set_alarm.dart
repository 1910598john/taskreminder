import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';
import 'package:intl/intl.dart';
import 'package:taskreminder/db_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

FlutterTts flutterTts = FlutterTts();

class SetAlarm extends StatefulWidget {
  final Function startService;
  final Function setVolume;
  final List<int> lst;
  const SetAlarm(
      {Key? key,
      required this.startService,
      required this.setVolume,
      required this.lst})
      : super(key: key);

  @override
  _SetAlarm createState() => _SetAlarm();
}

class _SetAlarm extends State<SetAlarm> {
  late DataBase handler;

  Future<int> insertTask(task, time, weekday) async {
    String repeat = "Remind, ";
    String status = 'active';
    if (weekdays_list.isNotEmpty) {
      for (int i = 0; i < weekdays_list.length; i++) {
        repeat += "${weekdays_list[i]} ";
      }
    } else {
      repeat = "Only once";
    }
    UserTask data = UserTask(
      task: task,
      time: time,
      status: status,
      repeat: repeat,
      reminded: 0,
    );
    List<UserTask> list = [data];
    return await handler.insertTask(list);
  }

  _SetAlarm() {
    initialTime();
  }

  @override
  void initState() {
    super.initState();
    handler = DataBase();
    handler.initializedDB();

    //initialize tts
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(.3);
    flutterTts.setSpeechRate(0.5);

    AwesomeNotifications().initialize(
      'resource://mipmap/launcher_icon',
      [
        NotificationChannel(
          channelKey: 'key1',
          channelName: 'Channel Name',
          channelDescription: 'Channel Description',
        )
      ],
    );
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  //textfield tts assistant
  void speak() async {
    List<String> errorMessages = [
      "You haven't entered your task yet.",
      "You haven't entered anything in the textfield.",
      "Please fill out the textfield.",
      "Please enter your task in the textfield."
    ];

    await flutterTts
        .speak(errorMessages[Random().nextInt(errorMessages.length)]);
    await flutterTts.awaitSpeakCompletion(true);
  }

  String pickedTime = '';
  List<String> weekdays_list = [];
  TextEditingController task = TextEditingController();
  int initialHour = DateTime.now().hour;
  int initialMin = DateTime.now().minute;

  initialTime() {
    int checkHour = initialHour;
    String initialMeridian;
    if (checkHour >= 12) {
      initialMeridian = 'PM';
    } else {
      initialMeridian = 'AM';
    }

    if (initialMin > 59) {
      initialMin -= 60;
      initialHour += 1;
    }
    if (initialHour > 12) {
      initialHour -= 12;
    }
    if (initialHour == 0) {
      initialHour += 12;
    }
    if (initialMin < 10) {
      pickedTime = "$initialHour:0$initialMin $initialMeridian";
    } else {
      pickedTime = "$initialHour:$initialMin $initialMeridian";
    }
    return [];
  }

  void _showTimePicker() {
    int hr = DateTime.now().hour;
    int min = DateTime.now().minute;
    if (min > 59) {
      min -= 60;
      hr += 1;
    }
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hr, minute: min),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              // change the border color
              primary: Color.fromARGB(255, 224, 82, 82),
              // change the text color
              onSurface: Color.fromARGB(255, 224, 82, 82),
            ),
            // button colors
            buttonTheme: const ButtonThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.green,
              ),
            ),
          ),
          child: child!,
        );
      },
    ).then((value) {
      setState(() {
        int hour = value!.hour;
        String meridian;
        int min = value.minute;
        if (hour >= 12) {
          meridian = 'PM';
        } else {
          meridian = 'AM';
        }

        if (hour == 0) {
          hour += 12;
        }
        if (min > 59) {
          min -= 60;
          hour += 1;
        }
        if (hour > 12) {
          hour -= 12;
        }
        if (min < 10) {
          pickedTime = "$hour:0$min $meridian";
        } else {
          pickedTime = "$hour:$min $meridian";
        }
        print(pickedTime);
      });
    });
  }

  List<DayInWeek> weekdays = [
    DayInWeek(
      "Sun",
    ),
    DayInWeek(
      "Mon",
    ),
    DayInWeek("Tue"),
    DayInWeek(
      "Wed",
    ),
    DayInWeek(
      "Thu",
    ),
    DayInWeek(
      "Fri",
    ),
    DayInWeek(
      "Sat",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 128, 0, 0),
        leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: const Color.fromARGB(255, 128, 0, 0),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 30),
              child: Column(
                children: const [
                  Icon(
                    Icons.alarm,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(
                    height: 10,
                    width: 0,
                  ),
                  Text(
                    'SET A REMINDER',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ],
              ),
            ),
            const Divider(),
            Container(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Column(
                  children: [
                    Text(
                      pickedTime,
                      style: const TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(
                      height: 10,
                      width: 0,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 224, 82, 82),
                          foregroundColor: Colors.white),
                      onPressed: () {
                        _showTimePicker();
                      },
                      child: const Text(
                        'Pick time',
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                )),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: SelectWeekDays(
                  padding: 1,
                  days: weekdays,
                  onSelect: (values) {
                    setState(() {
                      weekdays_list = values;
                    });
                  },
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  border: false,
                  selectedDayTextColor: Colors.red,
                  unSelectedDayTextColor: Colors.white,
                  boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      colors: [
                        Color.fromARGB(255, 224, 82, 82),
                        Color.fromARGB(255, 224, 82, 82)
                      ],
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    ),
                  ),
                )),
            const SizedBox(
              height: 15,
              width: 0,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: Column(
                children: [
                  TextField(
                    controller: task,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Your task',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        width: 1,
                        color: Colors.white,
                      )),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        width: 1,
                        color: Colors.white,
                      )),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 224, 82, 82),
                  foregroundColor: Colors.white,
                  fixedSize: const Size(150, 50),
                ),
                onPressed: () {
                  if (task.text.isNotEmpty) {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: Container(
                                width: 250,
                                child: Text(
                                    'Do you wish this app to remind you on your task on $pickedTime?')),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 128, 0, 0),
                                    ),
                                  )),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    if (task.text.isNotEmpty) {
                                      String weekday = '';
                                      for (int i = 0;
                                          i < weekdays_list.length;
                                          i++) {
                                        if (weekdays_list[i] == 'Sun') {
                                          weekday += '0';
                                        } else if (weekdays_list[i] == 'Mon') {
                                          weekday += '1';
                                        } else if (weekdays_list[i] == 'Tue') {
                                          weekday += '2';
                                        } else if (weekdays_list[i] == 'Wed') {
                                          weekday += '3';
                                        } else if (weekdays_list[i] == 'Thu') {
                                          weekday += '4';
                                        } else if (weekdays_list[i] == 'Fri') {
                                          weekday += '5';
                                        } else if (weekdays_list[i] == 'Sat') {
                                          weekday += '6';
                                        }
                                      }

                                      insertTask(
                                          task.text, pickedTime, weekday);

                                      widget.startService();
                                      setState(() {
                                        weekdays.forEach((element) {
                                          element.isSelected = false;
                                        });
                                        task.text = "";
                                      });
                                    }
                                  },
                                  child: const Text(
                                    'YES',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 128, 0, 0),
                                    ),
                                  ))
                            ],
                          );
                        });
                  } else {
                    widget.setVolume();
                    speak();
                  }
                },
                child: const Text(
                  'Remind me',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
