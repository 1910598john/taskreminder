import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'package:taskreminder/db_helper.dart';
import 'package:vibration/vibration.dart';

class Speech extends StatefulWidget {
  final int id;
  final int notificationID;
  final String task;
  final String time;
  final String honorific;
  final Function startservice;
  const Speech({
    Key? key,
    required this.id,
    required this.notificationID,
    required this.task,
    required this.time,
    required this.honorific,
    required this.startservice,
  }) : super(key: key);

  @override
  _Speech createState() => _Speech();
}

class _Speech extends State<Speech> {
  late DataBase handler;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    handler = DataBase();
    handler.initializedDB();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: MaterialApp(
            home: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
                child: Image.asset(
                  "assets/images/speech.gif",
                ),
              ),
              Container(
                child: Text(
                  widget.time,
                  style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontFamily: 'WorkSans'),
                ),
              ),
              const SizedBox(
                height: 50,
                width: 0,
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText('Hello, ${widget.honorific}.',
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'WorkSans')),
                      TyperAnimatedText('It is time to ${widget.task}.',
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'WorkSans',
                              overflow: TextOverflow.ellipsis),
                          speed: const Duration(milliseconds: 30)),
                    ],
                    repeatForever: true,
                  )),
              const SizedBox(
                height: 100,
                width: 0,
              ),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  fixedSize: Size(120, 40),
                                ),
                                onPressed: () async {
                                  SystemNavigator.pop();
                                  setState(() {
                                    running = false;
                                  });
                                  Vibration.cancel();
                                  await flutterTts.stop();
                                  widget.startservice();
                                },
                                child: const Text(
                                  'Dismiss',
                                  style: TextStyle(
                                      fontFamily: 'WanSans', fontSize: 15),
                                )),
                          ])))
            ],
          ),
        )));
  }
}
