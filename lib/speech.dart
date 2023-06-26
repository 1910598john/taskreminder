import 'dart:async';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
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
  final Function cancelAll;
  const Speech({
    Key? key,
    required this.id,
    required this.notificationID,
    required this.task,
    required this.time,
    required this.honorific,
    required this.startservice,
    required this.cancelAll,
  }) : super(key: key);

  @override
  _Speech createState() => _Speech();
}

class _Speech extends State<Speech> {
  late DataBase handler;
  ScrollController controller = ScrollController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    handler = DataBase();
    handler.initializedDB();

    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (controller.hasClients) {
        controller.animateTo(controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    });
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
                padding: const EdgeInsets.fromLTRB(0, 150, 0, 10),
                child: Image.asset(
                  "assets/images/speech.gif",
                ),
              ),
              Container(
                child: Text(
                  widget.time,
                  style: const TextStyle(
                      fontSize: 50,
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
                  child: SingleChildScrollView(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      child: AnimatedTextKit(
                        onFinished: () => timer!.cancel(),
                        animatedTexts: [
                          TyperAnimatedText('Hello, ${widget.honorific}.',
                              textStyle: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontFamily: 'WorkSans')),
                          TyperAnimatedText('It is time to ${widget.task}',
                              textStyle: const TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontFamily: 'WorkSans',
                              ),
                              speed: const Duration(milliseconds: 30)),
                        ],
                        repeatForever: true,
                      ))),
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
                                  backgroundColor:
                                      const Color.fromARGB(255, 205, 61, 61),
                                  foregroundColor: Colors.white,
                                  fixedSize: const Size(120, 40),
                                ),
                                onPressed: () async {
                                  SystemNavigator.pop();
                                  setState(() {
                                    running = false;
                                  });
                                  Vibration.cancel();
                                  await flutterTts.stop();
                                  await widget.startservice();
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
