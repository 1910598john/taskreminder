import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';
import 'package:taskreminder/db_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';

FlutterTts flutterTts = FlutterTts();

class SetAlarm extends StatefulWidget {
  final Function startService;

  const SetAlarm({Key? key, required this.startService}) : super(key: key);

  @override
  _SetAlarm createState() => _SetAlarm();
}

enum Snooze { three, five, ten, twenty }

class _SetAlarm extends State<SetAlarm> {
  late DataBase handler;

  Future<int> insertTask(task, time, weekday, snooze) async {
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
      snooze: snooze,
      reminded: 0,
      snooze_minutes: 0,
      snooze_triggered: 0
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
  }

  //textfield tts assistant
  void speak() async {
    List<String> errorMessages = [
      "You haven't entered your task yet.",
      "Textfield must be filled out.",
      "You haven't entered anything in the textfield.",
      "Please fill out the textfield.",
      "Please enter your task in the textfield."
    ];
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(.3);
    await flutterTts.setSpeechRate(0.5);

    await flutterTts
        .speak(errorMessages[Random().nextInt(errorMessages.length)]);
    await flutterTts.awaitSpeakCompletion(true);
  }

  String pickedTime = '';
  List<String> weekdays_list = [];
  bool snooze = true;
  int repeat = 5; //repeat after (minutes)
  final Snooze _snooze = Snooze.three;
  TextEditingController task = TextEditingController();
  int initialHour = DateTime.now().hour;
  int initialMin = DateTime.now().minute + 5;

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
    int min = DateTime.now().minute + 5;
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
              primary: Color.fromARGB(255, 78, 49, 170),
              // change the text color
              onSurface: Color.fromARGB(255, 78, 49, 170),
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
        backgroundColor: const Color.fromARGB(255, 178, 141, 255),
        leading: BackButton(
            color: const Color.fromARGB(255, 78, 49, 170),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: const Color.fromARGB(255, 178, 141, 255),
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
                              const Color.fromARGB(255, 78, 49, 170),
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
                  selectedDayTextColor: const Color.fromARGB(255, 78, 49, 170),
                  unSelectedDayTextColor: Colors.white,
                  boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      colors: [
                        Color.fromARGB(255, 78, 49, 170),
                        Color.fromARGB(255, 78, 49, 170)
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
                      color: Color.fromARGB(255, 78, 49, 170),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Your task',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 78, 49, 170),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        width: 1,
                        color: Color.fromARGB(255, 78, 49, 170),
                      )),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        width: 1,
                        color: Color.fromARGB(255, 78, 49, 170),
                      )),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(35, 0, 30, 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        showDialog<void>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Text('Repeat reminder after:'),
                                  content: Container(
                                      height: 150,
                                      child: Column(children: [
                                        Expanded(
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    repeat = 3;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Text('3 minutes'),
                                                      ],
                                                    )))),
                                        Expanded(
                                            child: InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    repeat = 5;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Text('5 minutes'),
                                                      ],
                                                    )))),
                                        Expanded(
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    repeat = 10;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Text('10 minutes'),
                                                      ],
                                                    )))),
                                        Expanded(
                                            child: InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    repeat = 20;
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: const [
                                                        Text('20 minutes'),
                                                      ],
                                                    )))),
                                      ])),
                                ));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Snooze",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 78, 49, 170),
                            ),
                          ),
                          Text(
                            "10 times, Every $repeat minutes",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 78, 49, 170),
                            ),
                          )
                        ],
                      )),
                  Switch(
                    // This bool value toggles the switch.
                    value: snooze,
                    activeColor: const Color.fromARGB(255, 78, 49, 170),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        snooze = value;
                      });
                    },
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
                  backgroundColor: const Color.fromARGB(255, 78, 49, 170),
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
                                      color: Color.fromARGB(255, 78, 49, 170),
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

                                      if (snooze == true) {
                                        insertTask(task.text, pickedTime,
                                            weekday, repeat);
                                      } else {
                                        insertTask(
                                            task.text, pickedTime, weekday, 0);
                                      }

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
                                      color: Color.fromARGB(255, 78, 49, 170),
                                    ),
                                  ))
                            ],
                          );
                        });
                  } else {
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
