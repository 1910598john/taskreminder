import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';
import 'package:taskreminder/db_helper.dart';

class SetAlarm extends StatefulWidget {
  const SetAlarm({Key? key}) : super(key: key);

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
    Tasks2 data =
        Tasks2(task: task, time: time, status: status, repeat: repeat);
    List<Tasks2> list = [data];
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

  String pickedTime = '';
  List<String> weekdays_list = [];
  bool snooze = true;
  TextEditingController task = TextEditingController();

  initialTime() {
    int initialHour = DateTime.now().hour;
    int initialMin = DateTime.now().minute;
    int checkHour = initialHour;
    String initialMeridian;
    checkHour > 12 ? initialMeridian = 'PM' : initialMeridian = 'AM';

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
  }

  void _showTimePicker() {
    int initialHour = DateTime.now().hour;
    int initialMin = DateTime.now().minute + 5;
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMin),
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
        String meridian = 'AM';
        if (hour > 12) {
          hour -= 12;
          meridian = 'PM';
        }
        if (hour == 0) {
          hour += 12;
        }
        if (value.minute < 10) {
          pickedTime = "$hour:0${value.minute} $meridian";
        } else {
          pickedTime = "$hour:${value.minute} $meridian";
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
        physics: BouncingScrollPhysics(),
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
                    style: TextStyle(
                      color: Color.fromARGB(255, 78, 49, 170),
                    ),
                    decoration: InputDecoration(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Snooze",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 78, 49, 170),
                        ),
                      ),
                      Text(
                        "3 times, Every 5 minutes",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 78, 49, 170),
                        ),
                      )
                    ],
                  ),
                  Switch(
                    // This bool value toggles the switch.
                    value: snooze,
                    activeColor: Color.fromARGB(255, 78, 49, 170),
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        snooze = value;
                        print(snooze);
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
                  shadowColor: const Color.fromARGB(255, 78, 49, 170),
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 78, 49, 170),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  String weekday = '';
                  for (int i = 0; i < weekdays_list.length; i++) {
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

                  await insertTask(task.text, pickedTime, weekday);
                  setState(() {
                    weekdays.forEach((element) {
                      element.isSelected = false;
                    });
                    task.text = "";
                  });
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
